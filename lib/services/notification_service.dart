import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:paw_around/models/vaccines/vaccine_model.dart';
import 'package:paw_around/models/pets/care_settings_model.dart';
import 'package:paw_around/ui/widgets/notification_permission_dialog.dart';
import 'package:paw_around/utils/notification_handler.dart';

/// Types of care reminders
enum ReminderType {
  vaccine,
  grooming,
  tickFlea,
}

extension ReminderTypeExtension on ReminderType {
  String get displayName {
    switch (this) {
      case ReminderType.vaccine:
        return 'vaccination';
      case ReminderType.grooming:
        return 'grooming';
      case ReminderType.tickFlea:
        return 'tick & flea treatment';
    }
  }

  int get typeOffset {
    switch (this) {
      case ReminderType.vaccine:
        return 0;
      case ReminderType.grooming:
        return 10000000;
      case ReminderType.tickFlea:
        return 20000000;
    }
  }
}

/// Service for managing local notifications for pet care reminders
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'pet_care_reminders';
  static const String _channelName = 'Pet Care Reminders';
  static const String _channelDescription =
      'Reminders for vaccines, grooming, and tick/flea care';

  bool _isInitialized = false;

  /// Initialize the notification plugin (no permission request)
  Future<void> init() async {
    if (_isInitialized) return;

    tz_data.initializeTimeZones();

    // Create Android notification channel explicitly
    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      await android.createNotificationChannel(androidChannel);
    }

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse:
          NotificationHandler.handleNotificationTap,
    );

    _isInitialized = true;
  }

  /// Check if we have notification permission
  Future<bool> hasPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.areNotificationsEnabled();
      return granted ?? false;
    }

    // For iOS, check permission status
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final granted = await ios.checkPermissions();
      return granted?.isEnabled ?? false;
    }

    return false;
  }

  /// Request notification permission
  Future<bool> requestPermission() async {
    // Android 13+
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }

    // iOS
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final granted = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return false;
  }

  /// Request permission with contextual dialog
  /// Returns true if permission was granted
  Future<bool> requestPermissionIfNeeded(
    BuildContext context,
    String petName,
    ReminderType type,
  ) async {
    // Check if already have permission
    if (await hasPermission()) {
      return true;
    }

    // Show contextual dialog
    final shouldRequest = await showNotificationPermissionDialog(
      context: context,
      petName: petName,
      reminderType: type,
    );

    if (!shouldRequest) {
      return false;
    }

    return await requestPermission();
  }

  /// Schedule countdown reminders (8 notifications: 7 days before through due day)
  Future<void> _scheduleCountdownReminders({
    required int baseId,
    required String petId,
    required String petName,
    required String careName,
    required DateTime dueDate,
    required ReminderType reminderType,
    String? vaccineId,
  }) async {
    for (int daysBefore = 7; daysBefore >= 0; daysBefore--) {
      final notificationDate = dueDate.subtract(Duration(days: daysBefore));

      final body = daysBefore == 0
          ? "$petName's $careName is due today!"
          : daysBefore == 1
              ? "$petName's $careName is due tomorrow"
              : "$petName's $careName is due in $daysBefore days";

      // Schedule at 10:00 AM
      final scheduledDate = DateTime(
        notificationDate.year,
        notificationDate.month,
        notificationDate.day,
        20,
        15,
      );

      // Skip if scheduled time has passed
      if (scheduledDate.isBefore(DateTime.now())) continue;

      // Create payload for navigation
      final payload = {
        'petId': petId,
        'reminderType': reminderType.name,
        if (vaccineId != null) 'vaccineId': vaccineId,
      };

      await _scheduleNotification(
        id: baseId + daysBefore,
        title: 'Care Reminder',
        body: body,
        scheduledDate: scheduledDate,
        payload: jsonEncode(payload),
      );
    }
  }

  /// Cancel all countdown reminders for a base ID
  Future<void> _cancelCountdownReminders(int baseId) async {
    try {
      for (int i = 0; i <= 7; i++) {
        await _plugin.cancel(baseId + i);
      }
    } catch (e) {
      debugPrint('Error cancelling reminders: $e');
      // Don't rethrow - allow app to continue
    }
  }

  /// Schedule a single notification
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    try {
      final androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      final iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tzScheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: null,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
      rethrow;
    }
  }

  // ============ VACCINE REMINDERS ============

  /// Generate base ID for vaccine reminder
  /// Uses modulo to ensure IDs fit within 32-bit integer range
  /// Each vaccine gets 8 IDs (for countdown: 0-7)
  int _vaccineBaseId(String petId, String vaccineId) {
    // XOR the hashes and constrain to safe range (0 to ~10 million)
    // Multiply by 10 to give each vaccine its own block of 10 IDs
    final combinedHash = (petId.hashCode ^ vaccineId.hashCode).abs();
    return (combinedHash % 1000000) * 10;
  }

  /// Schedule vaccine reminder countdown
  Future<void> scheduleVaccineReminder({
    required String petId,
    required String petName,
    required VaccineModel vaccine,
  }) async {
    if (!vaccine.setReminder) return;

    try {
      final baseId = _vaccineBaseId(petId, vaccine.id);

      // Cancel any existing reminders first
      await _cancelCountdownReminders(baseId);

      // Schedule new countdown
      await _scheduleCountdownReminders(
        baseId: baseId,
        petId: petId,
        petName: petName,
        careName: vaccine.vaccineName,
        dueDate: vaccine.nextDueDate ??
            DateTime.now().add(const Duration(days: 365)),
        reminderType: ReminderType.vaccine,
        vaccineId: vaccine.id,
      );
    } catch (e) {
      debugPrint('Error scheduling vaccine reminder: $e');
      // Don't rethrow - allow app to continue even if notification fails
    }
  }

  /// Cancel vaccine reminder
  Future<void> cancelVaccineReminder({
    required String petId,
    required String vaccineId,
  }) async {
    final baseId = _vaccineBaseId(petId, vaccineId);
    await _cancelCountdownReminders(baseId);
  }

  // ============ CARE REMINDERS (GROOMING / TICK-FLEA) ============

  /// Generate base ID for care reminder
  /// Uses modulo to ensure IDs fit within 32-bit integer range
  int _careBaseId(String petId, ReminderType type) {
    // Constrain petId hash to safe range and add type offset
    final petHash = petId.hashCode.abs() % 1000000;
    return (petHash * 10) + type.typeOffset;
  }

  /// Schedule care reminder countdown
  Future<void> scheduleCareReminder({
    required String petId,
    required String petName,
    required ReminderType type,
    required CareSettingsModel settings,
  }) async {
    if (!settings.hasReminder) return;

    final dueDate = settings.nextDueDate;
    if (dueDate == null) return;

    try {
      final baseId = _careBaseId(petId, type);

      // Cancel any existing reminders first
      await _cancelCountdownReminders(baseId);

      // Schedule new countdown
      await _scheduleCountdownReminders(
        baseId: baseId,
        petId: petId,
        petName: petName,
        careName: type.displayName,
        dueDate: dueDate,
        reminderType: type,
      );
    } catch (e) {
      debugPrint('Error scheduling care reminder: $e');
      // Don't rethrow - allow app to continue even if notification fails
    }
  }

  /// Cancel care reminder
  Future<void> cancelCareReminder({
    required String petId,
    required ReminderType type,
  }) async {
    final baseId = _careBaseId(petId, type);
    await _cancelCountdownReminders(baseId);
  }

  // ============ BULK OPERATIONS ============

  /// Cancel all reminders for a pet
  Future<void> cancelAllRemindersForPet(String petId) async {
    // Cancel all care type reminders
    for (final type in ReminderType.values) {
      await cancelCareReminder(petId: petId, type: type);
    }
  }

  /// Cancel all reminders for a pet including vaccines
  Future<void> cancelAllRemindersForPetWithVaccines(
    String petId,
    List<String> vaccineIds,
  ) async {
    try {
      // Cancel care reminders
      await cancelAllRemindersForPet(petId);

      // Cancel vaccine reminders
      for (final vaccineId in vaccineIds) {
        await cancelVaccineReminder(petId: petId, vaccineId: vaccineId);
      }
    } catch (e) {
      debugPrint('Error cancelling all reminders: $e');
      // Don't rethrow - allow app to continue
    }
  }
}
