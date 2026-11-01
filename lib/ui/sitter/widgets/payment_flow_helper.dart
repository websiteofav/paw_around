import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/core/di/service_locator.dart';
import 'package:paw_around/repositories/payment_repository.dart';
import 'package:paw_around/services/payment_service.dart';
import 'package:paw_around/utils/app_toast.dart';

/// Kicks off order creation as soon as the review screen loads, instead of
/// waiting for the user to tap "Pay" — the createRazorpayOrder round-trip
/// (Cloud Function cold start + Razorpay API call) was previously the
/// visible delay before Checkout opened, which read as "Razorpay is slow"
/// even though Checkout itself opens instantly once the order is ready.
Future<RazorpayOrder> prefetchRazorpayOrder({required int totalAmount}) {
  return sl<PaymentRepository>().createOrder(amountInPaise: totalAmount * 100);
}

class PaymentFlowResult {
  final String paymentId;
  final String razorpayOrderId;

  const PaymentFlowResult({
    required this.paymentId,
    required this.razorpayOrderId,
  });
}

/// Runs order-creation -> Checkout -> server-side verification as one
/// step, so BookSittersScreen only has to handle a single yes/no outcome.
/// Shows its own error snackbar and returns null on any failure —
/// cancelling, a failed charge, or a verification mismatch all look the
/// same to the caller: "no booking should be created".
class PaymentFlowHelper {
  PaymentFlowHelper._();

  static Future<PaymentFlowResult?> collectPayment({
    required BuildContext context,
    required int totalAmount,
    required String description,
    String? contactPhone,
    Future<RazorpayOrder>? prefetchedOrder,
  }) async {
    final paymentRepository = sl<PaymentRepository>();
    final paymentService = PaymentService();
    try {
      final order = await (prefetchedOrder ??
          paymentRepository.createOrder(amountInPaise: totalAmount * 100));

      final result = await paymentService.openCheckout(
        keyId: order.keyId,
        orderId: order.orderId,
        amountInPaise: order.amount,
        description: description,
        contactPhone: contactPhone,
      );

      if (!result.success) {
        _showError(context, result.errorMessage ?? AppStrings.paymentFailed);
        return null;
      }

      final verified = await paymentRepository.verifyPayment(
        orderId: result.orderId!,
        paymentId: result.paymentId!,
        signature: result.signature!,
      );

      if (!verified) {
        _showError(context, AppStrings.paymentVerificationFailed);
        return null;
      }

      return PaymentFlowResult(
        paymentId: result.paymentId!,
        razorpayOrderId: result.orderId!,
      );
    } catch (_) {
      _showError(context, AppStrings.paymentFailed);
      return null;
    } finally {
      paymentService.dispose();
    }
  }

  static void _showError(BuildContext context, String message) {
    if (!context.mounted) return;
    AppToast.showError(context, message);
  }
}
