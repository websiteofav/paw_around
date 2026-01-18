import 'dart:async';
import 'dart:developer';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:paw_around/router/app_router.dart';

/// Singleton class to manage deep links across the app.
/// Handles both pre-auth and post-auth scenarios.
///
/// Usage:
///   1. Call `DeepLinkService.instance.init()` once during app startup
///   2. Call `DeepLinkService.instance.setAuthenticated(true, context)` from Dashboard
///   3. Call `DeepLinkService.instance.handlePendingUri()` from Dashboard after auth
///   4. Call `DeepLinkService.instance.dispose()` to clean up resources
class DeepLinkService {
  DeepLinkService._();
  static final DeepLinkService instance = DeepLinkService._();

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;
  Uri? _pendingUri;
  bool _isAuthenticated = false;
  BuildContext? _currentContext;

  void init() async {
    // Cold start - check for initial deep link and store it
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _pendingUri = initialUri;
        log('DeepLink cold start stored: $initialUri');
      }
    } catch (e) {
      log('DeepLink getInitialLink error: $e');
    }

    // Warm start - listen for links when app is already running
    _sub = _appLinks.uriLinkStream.listen(
      (uri) {
        log('DeepLink warm start received: $uri');
        _pendingUri = uri;

        // If app is authenticated and we have context, navigate immediately
        if (_isAuthenticated && _currentContext != null && _currentContext!.mounted) {
          _processUri(_currentContext!);
        }
      },
      onError: (err) {
        log('DeepLink stream error: $err');
      },
    );
  }

  /// Call this from Dashboard after authentication to enable immediate deep link processing.
  /// This handles the case where deep links arrive while app is in background.
  void setAuthenticated(bool isAuthenticated, BuildContext? context) {
    _isAuthenticated = isAuthenticated;
    _currentContext = context;

    // If we have a pending URI and we're now authenticated, process it
    if (isAuthenticated && _pendingUri != null && context != null && context.mounted) {
      _processUri(context);
    }
  }

  /// Process any pending deep link URI.
  /// Call this from Dashboard after it's built.
  void handlePendingUri() {
    if (_pendingUri == null) {
      return;
    }

    if (_currentContext != null && _currentContext!.mounted) {
      _processUri(_currentContext!);
    }
  }

  /// Navigate to the pending URI path using push (so Dashboard stays as base).
  void _processUri(BuildContext context) {
    if (_pendingUri == null) {
      return;
    }

    final uri = _pendingUri!;
    _pendingUri = null;

    log('DeepLink processing: ${uri.path}');

    // Use push so back button returns to Dashboard
    AppRouter.router.push(uri.path);
  }

  /// Check if there's a pending deep link
  bool get hasPendingUri => _pendingUri != null;

  /// Clear any pending deep link
  void clearPendingUri() {
    _pendingUri = null;
  }

  void dispose() {
    _pendingUri = null;
    _currentContext = null;
    _isAuthenticated = false;
    _sub?.cancel();
  }
}
