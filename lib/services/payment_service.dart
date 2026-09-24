import 'dart:async';

import 'package:razorpay_flutter/razorpay_flutter.dart';

/// Outcome of one Razorpay Checkout session.
class PaymentResult {
  final bool success;
  final String? paymentId;
  final String? orderId;
  final String? signature;
  final String? errorMessage;

  const PaymentResult._({
    required this.success,
    this.paymentId,
    this.orderId,
    this.signature,
    this.errorMessage,
  });

  factory PaymentResult.success({
    required String paymentId,
    required String orderId,
    required String signature,
  }) {
    return PaymentResult._(
      success: true,
      paymentId: paymentId,
      orderId: orderId,
      signature: signature,
    );
  }

  factory PaymentResult.failure(String message) {
    return PaymentResult._(success: false, errorMessage: message);
  }
}

/// Thin wrapper around razorpay_flutter's event-callback API, turning one
/// Checkout session into a single awaitable result.
class PaymentService {
  final Razorpay _razorpay = Razorpay();

  Future<PaymentResult> openCheckout({
    required String keyId,
    required String orderId,
    required int amountInPaise,
    required String description,
    String? contactPhone,
  }) {
    final completer = Completer<PaymentResult>();

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (PaymentSuccessResponse r) {
      if (r.paymentId == null || r.orderId == null || r.signature == null) {
        completer.complete(
            PaymentResult.failure('Incomplete payment response'));
        return;
      }
      completer.complete(PaymentResult.success(
        paymentId: r.paymentId!,
        orderId: r.orderId!,
        signature: r.signature!,
      ));
    });

    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (PaymentFailureResponse r) {
      completer.complete(PaymentResult.failure(r.message ?? 'Payment failed'));
    });

    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, (ExternalWalletResponse r) {
      completer.complete(PaymentResult.failure('Payment cancelled'));
    });

    _razorpay.open({
      'key': keyId,
      'order_id': orderId,
      'amount': amountInPaise,
      'name': 'Paw Around',
      'description': description,
      if (contactPhone != null && contactPhone.isNotEmpty)
        'prefill': {'contact': contactPhone},
    });

    return completer.future;
  }

  void dispose() {
    _razorpay.clear();
  }
}
