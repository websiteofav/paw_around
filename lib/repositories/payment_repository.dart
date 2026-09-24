import 'package:cloud_functions/cloud_functions.dart';

/// A Razorpay order created server-side — the app opens Checkout with
/// these, and never sees the account's key secret.
class RazorpayOrder {
  final String orderId;
  final int amount;
  final String currency;
  final String keyId;

  const RazorpayOrder({
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.keyId,
  });
}

/// Calls the createRazorpayOrder/verifyRazorpayPayment Cloud Functions —
/// the key secret and signature check live server-side, never on-device.
class PaymentRepository {
  final FirebaseFunctions _functions;

  PaymentRepository({FirebaseFunctions? functions})
      : _functions = functions ?? FirebaseFunctions.instance;

  Future<RazorpayOrder> createOrder({required int amountInPaise}) async {
    final callable = _functions.httpsCallable('createRazorpayOrder');
    final result =
        await callable.call<Map<String, dynamic>>({'amountInPaise': amountInPaise});
    final data = result.data;
    return RazorpayOrder(
      orderId: data['orderId'] as String,
      amount: data['amount'] as int,
      currency: data['currency'] as String,
      keyId: data['keyId'] as String,
    );
  }

  Future<bool> verifyPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    final callable = _functions.httpsCallable('verifyRazorpayPayment');
    final result = await callable.call<Map<String, dynamic>>({
      'orderId': orderId,
      'paymentId': paymentId,
      'signature': signature,
    });
    return result.data['verified'] as bool;
  }
}
