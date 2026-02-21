import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:paw_around/models/navigation/pending_intent.dart';
import 'package:paw_around/services/pending_intent_service.dart';

class NotificationHandler {
  static Future<void> handleNotificationTap(
    NotificationResponse response, {
    bool resolveNow = true,
  }) async {
    if (response.payload == null || response.payload!.isEmpty) {
      debugPrint('Notification tapped but no payload');
      return;
    }

    try {
      final payload = jsonDecode(response.payload!) as Map<String, dynamic>;
      await storePayload(
        payload,
        source: PendingIntentSource.localNotification,
        resolveNow: resolveNow,
      );
    } catch (e) {
      debugPrint('Error handling notification tap: $e');
    }
  }

  static Future<void> storePayload(
    Map<String, dynamic> payload, {
    required PendingIntentSource source,
    bool resolveNow = true,
  }) async {
    final route = (payload['route'] ?? payload['path']) as String?;
    if (route != null && route.isNotEmpty) {
      final requiresAuthRaw = payload['requiresAuth'];
      final requiresAuth = requiresAuthRaw is bool
          ? requiresAuthRaw
          : PendingIntentService.instance.routeRequiresAuth(route);

      final routeIntent = PendingIntent(
        source: source,
        type: PendingIntentType.route,
        requiresAuth: requiresAuth,
        payload: {'path': route},
        createdAt: DateTime.now(),
      );
      await PendingIntentService.instance.save(routeIntent);
      if (resolveNow) {
        await PendingIntentService.instance.resolveIfPossible();
      }
      return;
    }

    final petId = payload['petId'] as String?;
    final reminderType = payload['reminderType'] as String?;
    if (petId == null || reminderType == null) {
      debugPrint('Notification payload format not supported');
      return;
    }

    final intent = PendingIntent(
      source: source,
      type: PendingIntentType.actionReminder,
      requiresAuth: true,
      payload: {
        'petId': petId,
        'reminderType': reminderType,
        if (payload['vaccineId'] != null) 'vaccineId': payload['vaccineId'],
      },
      createdAt: DateTime.now(),
    );
    await PendingIntentService.instance.save(intent);

    if (resolveNow) {
      await PendingIntentService.instance.resolveIfPossible();
    }
  }
}
