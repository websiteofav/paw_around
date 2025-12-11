import 'package:flutter/material.dart';
import 'package:paw_around/core/error/failures.dart';

class ErrorHandler {
  static void handleError(BuildContext context, Failure failure) {
    String message;

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
      default:
        message = 'An unexpected error occurred: ${failure.message}';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
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
