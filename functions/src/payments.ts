import * as crypto from "crypto";
import {onCall, HttpsError} from "firebase-functions/v2/https";
import {defineSecret} from "firebase-functions/params";

const razorpayKeyId = defineSecret("RAZORPAY_KEY_ID");
const razorpayKeySecret = defineSecret("RAZORPAY_KEY_SECRET");

interface CreateOrderRequest {
  amountInPaise: number;
}

interface CreateOrderResponse {
  orderId: string;
  amount: number;
  currency: string;
  keyId: string;
}

/**
 * Creates a Razorpay order for the given amount (in paise) and returns the
 * order id plus the publishable key id — the app opens Razorpay Checkout
 * with these, it never sees the key secret.
 */
export const createRazorpayOrder = onCall<CreateOrderRequest>(
  {secrets: [razorpayKeyId, razorpayKeySecret]},
  async (request): Promise<CreateOrderResponse> => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Sign in required.");
    }

    const amountInPaise = request.data?.amountInPaise;
    if (typeof amountInPaise !== "number" || !Number.isFinite(amountInPaise) ||
        amountInPaise <= 0) {
      throw new HttpsError(
        "invalid-argument",
        "amountInPaise must be a positive number."
      );
    }

    const keyId = razorpayKeyId.value();
    const keySecret = razorpayKeySecret.value();
    const basicAuth = Buffer.from(`${keyId}:${keySecret}`).toString("base64");

    const receipt = `booking_${request.auth.uid}_${Date.now()}`;
    const response = await fetch("https://api.razorpay.com/v1/orders", {
      method: "POST",
      headers: {
        "Authorization": `Basic ${basicAuth}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        amount: Math.round(amountInPaise),
        currency: "INR",
        receipt,
      }),
    });

    if (!response.ok) {
      const body = await response.text();
      console.error("Razorpay order creation failed:", response.status, body);
      throw new HttpsError("internal", "Could not create payment order.");
    }

    const order = await response.json() as {
      id: string;
      amount: number;
      currency: string;
    };

    return {
      orderId: order.id,
      amount: order.amount,
      currency: order.currency,
      keyId,
    };
  }
);

interface VerifyPaymentRequest {
  orderId: string;
  paymentId: string;
  signature: string;
}

interface VerifyPaymentResponse {
  verified: boolean;
}

/**
 * Verifies a completed Razorpay checkout by recomputing the HMAC-SHA256
 * signature server-side (order_id|payment_id, signed with the key secret)
 * and comparing it to what the client received — this is what actually
 * proves the payment happened, since the client-side "success" callback
 * alone can't be trusted.
 */
export const verifyRazorpayPayment = onCall<VerifyPaymentRequest>(
  {secrets: [razorpayKeySecret]},
  async (request): Promise<VerifyPaymentResponse> => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Sign in required.");
    }

    const {orderId, paymentId, signature} = request.data ?? {};
    if (!orderId || !paymentId || !signature) {
      throw new HttpsError(
        "invalid-argument",
        "orderId, paymentId, and signature are required."
      );
    }

    const expectedSignature = crypto
      .createHmac("sha256", razorpayKeySecret.value())
      .update(`${orderId}|${paymentId}`)
      .digest("hex");

    return {verified: expectedSignature === signature};
  }
);
