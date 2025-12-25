import 'package:flutter/material.dart';
import 'package:paw_around/core/error/failures.dart';
import 'package:paw_around/services/auth_error_interceptor.dart';

export 'failures.dart';

class ErrorHandler {
  static Future<void> handleError(BuildContext context, Failure failure) async {
    String message;

    // Handle unauthorized errors specially - logout and show message
    if (failure is UnauthorizedFailure) {
      await AuthErrorInterceptor().handleUnauthorizedError();
      message = failure.message;
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    switch (failure.runtimeType) {
      case ServerFailure:
        message = 'Server error: ${failure.message}';
        break;
      case CacheFailure:
        message = 'Storage error: ${failure.message}';
        break;
      case ValidationFailure:
        message = 'Validation error: ${failure.message}';
        break;
      case AuthFailure:
        message = failure.message;
        break;
      default:
        message = 'An unexpected error occurred: ${failure.message}';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Handle any exception - checks for unauthorized errors and handles accordingly
  static Future<void> handleException(BuildContext context, dynamic error) async {
    final interceptor = AuthErrorInterceptor();

    if (interceptor.isUnauthorizedError(error)) {
      await interceptor.handleUnauthorizedError();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session expired. Please login again.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    // Handle as generic error
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
