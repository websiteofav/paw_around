import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:paw_around/firebase_options.dart';
import 'package:paw_around/models/navigation/pending_intent.dart';
import 'package:paw_around/services/notification_service.dart';
import 'package:paw_around/services/pending_intent_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

class PushMessageService {
  PushMessageService._();
  static final PushMessageService instance = PushMessageService._();

  bool _isInitialized = false;

  static void registerBackgroundHandler() {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  Future<void> init() async {
    if (_isInitialized) {
      return;
    }

    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(alert: true, badge: true, sound: true);
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleOpenedMessage);

    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      await _storeMessageIntent(initialMessage);
    }

    _isInitialized = true;
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final localPayload = _buildLocalNotificationPayload(message);
    if (localPayload == null) {
      return;
    }

    await NotificationService().showInstantNotification(
      title: message.notification?.title ?? 'Paw Around',
      body: message.notification?.body ?? '',
      payload: localPayload,
    );
  }

  Future<void> _handleOpenedMessage(RemoteMessage message) async {
    await _storeMessageIntent(message);
    await PendingIntentService.instance.resolveIfPossible();
  }

  Future<void> _storeMessageIntent(RemoteMessage message) async {
    final intent = _intentFromMessage(message);
    if (intent == null) {
      return;
    }

    await PendingIntentService.instance.save(intent);
  }

  PendingIntent? _intentFromMessage(RemoteMessage message) {
    final data = Map<String, dynamic>.from(message.data);
    if (data.isEmpty) {
      return null;
    }

    final route = data['route'] as String?;
    if (route != null && route.isNotEmpty) {
      final requiresAuthRaw = data['requiresAuth']?.toString();
      final requiresAuth = requiresAuthRaw == null
          ? PendingIntentService.instance.routeRequiresAuth(route)
          : requiresAuthRaw.toLowerCase() == 'true';

      return PendingIntent(
        source: PendingIntentSource.pushNotification,
        type: PendingIntentType.route,
        requiresAuth: requiresAuth,
        payload: {'path': route},
        createdAt: DateTime.now(),
      );
    }

    if (data['petId'] == null || data['reminderType'] == null) {
      return null;
    }

    return PendingIntent(
      source: PendingIntentSource.pushNotification,
      type: PendingIntentType.actionReminder,
      requiresAuth: true,
      payload: {
        'petId': data['petId'],
        'reminderType': data['reminderType'],
        if (data['vaccineId'] != null) 'vaccineId': data['vaccineId'],
      },
      createdAt: DateTime.now(),
    );
  }

  String? _buildLocalNotificationPayload(RemoteMessage message) {
    final intent = _intentFromMessage(message);
    if (intent == null) {
      return null;
    }
    return NotificationService.encodePayload(intent.payload);
  }
}
