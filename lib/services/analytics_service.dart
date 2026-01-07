import 'dart:developer';
import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final FirebaseAnalytics _firebaseAnalytics = FirebaseAnalytics.instance;

  /// Log an analytics event
  static Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    try {
      final eventName = name.replaceAll('-', '_').replaceAll(':', '_');
      await _firebaseAnalytics.logEvent(name: eventName, parameters: parameters);
      log('📊 Analytics: $eventName | $parameters');
    } catch (e) {
      log('Analytics error: $e');
    }
  }

  /// Set a user property
  static Future<void> setUserProperty(String name, String value) async {
    try {
      await _firebaseAnalytics.setUserProperty(name: name, value: value);
      log('📊 Analytics Property: $name = $value');
    } catch (e) {
      log('Analytics setUserProperty error: $e');
    }
  }

  /// Set the user ID for analytics
  static Future<void> setUserId(String? userId) async {
    try {
      await _firebaseAnalytics.setUserId(id: userId);
      log('📊 Analytics UserId: $userId');
    } catch (e) {
      log('Analytics setUserId error: $e');
    }
  }

  /// Get the analytics observer for GoRouter
  static FirebaseAnalyticsObserver get observer => FirebaseAnalyticsObserver(analytics: _firebaseAnalytics);
}
