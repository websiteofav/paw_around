import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:paw_around/core/di/service_locator.dart';
import 'package:paw_around/core/error/failures.dart';
import 'package:paw_around/repositories/auth_repository.dart';

/// Service to intercept and handle auth-related errors globally
class AuthErrorInterceptor {
  static final AuthErrorInterceptor _instance = AuthErrorInterceptor._internal();
  factory AuthErrorInterceptor() => _instance;
  AuthErrorInterceptor._internal();

  /// Check if an error is an unauthorized/unauthenticated error
  bool isUnauthorizedError(dynamic error) {
    // Firebase Auth errors
    if (error is FirebaseAuthException) {
      return _isAuthError(error.code);
    }

    // Firebase Firestore errors
    if (error is FirebaseException) {
      return _isAuthError(error.code);
    }

    // Check error message for common patterns
    if (error is Exception) {
      final message = error.toString().toLowerCase();
      return message.contains('401') ||
          message.contains('unauthorized') ||
          message.contains('unauthenticated') ||
          message.contains('permission-denied') ||
          message.contains('permission denied') ||
          message.contains('token') && message.contains('expired');
    }

    return false;
  }

  bool _isAuthError(String code) {
    const authErrorCodes = [
      'permission-denied',
      'unauthenticated',
      'unauthorized',
      'user-not-found',
      'user-disabled',
      'user-token-expired',
      'invalid-user-token',
      'requires-recent-login',
    ];
    return authErrorCodes.contains(code.toLowerCase());
  }

  /// Handle unauthorized error by logging out the user
  Future<void> handleUnauthorizedError() async {
    try {
      final authRepository = sl<AuthRepository>();
      await authRepository.signOut();
    } catch (e) {
      // Ignore errors during sign out
    }
  }

  /// Wrap an async operation with auth error handling
  /// Returns the result or throws UnauthorizedFailure for auth errors
  Future<T> wrapWithAuthCheck<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } catch (e) {
      if (isUnauthorizedError(e)) {
        await handleUnauthorizedError();
        throw const UnauthorizedFailure();
      }
      rethrow;
    }
  }
}

/// Extension to easily use auth error handling on any Future
extension AuthErrorHandling<T> on Future<T> {
  Future<T> withAuthErrorHandling() async {
    try {
      return await this;
    } catch (e) {
      final interceptor = AuthErrorInterceptor();
      if (interceptor.isUnauthorizedError(e)) {
        await interceptor.handleUnauthorizedError();
        throw const UnauthorizedFailure();
      }
      rethrow;
    }
  }
}
