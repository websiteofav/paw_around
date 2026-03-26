import 'dart:async';
import 'dart:developer';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:paw_around/models/navigation/pending_intent.dart';
import 'package:paw_around/services/pending_intent_service.dart';

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

  void init() async {
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        log('DeepLink cold start stored: $initialUri');
        await _storeUri(initialUri);
        await PendingIntentService.instance.resolveIfPossible();
      }
    } catch (e) {
      log('DeepLink getInitialLink error: $e');
    }

    _sub = _appLinks.uriLinkStream.listen(
      (uri) async {
        log('DeepLink warm start received: $uri');
        await _storeUri(uri);
        await PendingIntentService.instance.resolveIfPossible();
      },
      onError: (err) {
        log('DeepLink stream error: $err');
      },
    );
  }

  void setAuthenticated(bool isAuthenticated, BuildContext? context) {
    if (context != null && !context.mounted) {
      return;
    }
    if (isAuthenticated) {
      PendingIntentService.instance.resolveIfPossible();
    }
  }

  void handlePendingUri() {
    PendingIntentService.instance.resolveIfPossible();
  }

  Future<void> _storeUri(Uri uri) async {
    // Firebase Auth uses deep links for reCAPTCHA and email verification callbacks.
    // These contain a `deep_link_id` param pointing to firebaseapp.com/__/auth/*.
    // They are handled internally by the Firebase SDK and must NOT be routed by GoRouter.
    final deepLinkId = uri.queryParameters['deep_link_id'];
    if (deepLinkId != null) {
      final inner = Uri.tryParse(deepLinkId);
      if (inner != null && inner.path.contains('/__/auth/')) {
        log('DeepLink skipped (Firebase Auth callback): $uri');
        return;
      }
    }

    final path = uri.path.isEmpty ? '/' : uri.path;
    final requiresAuth = PendingIntentService.instance.routeRequiresAuth(path);
    final intent = PendingIntent(
      source: PendingIntentSource.deepLink,
      type: PendingIntentType.route,
      requiresAuth: requiresAuth,
      payload: {'path': uri.toString()},
      createdAt: DateTime.now(),
    );
    await PendingIntentService.instance.save(intent);
  }

  void clearPendingUri() {
    PendingIntentService.instance.clear();
  }

  void dispose() {
    _sub?.cancel();
  }
}
