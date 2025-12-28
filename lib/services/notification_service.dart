import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/models/vaccines/vaccine_model.dart';
import 'package:paw_around/models/pets/care_settings_model.dart';

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

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static const String _declinedKey = 'notifications_declined';
  static const String _channelId = 'pet_care_reminders';
  static const String _channelName = 'Pet Care Reminders';
  static const String _channelDescription = 'Reminders for vaccines, grooming, and tick/flea care';

  bool _isInitialized = false;

  /// Initialize the notification plugin (no permission request)
  Future<void> init() async {
    if (_isInitialized) return;

    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

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
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - can navigate to specific screen
    debugPrint('Notification tapped: ${response.payload}');
  }

  /// Check if user has already declined notifications
  Future<bool> userDeclinedNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_declinedKey) ?? false;
  }

  /// Mark that user has declined notifications
  Future<void> setUserDeclinedNotifications(bool declined) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_declinedKey, declined);
  }

  /// Check if we have notification permission
  Future<bool> hasPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.areNotificationsEnabled();
      return granted ?? false;
    }

    // For iOS, check permission status
    final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final granted = await ios.checkPermissions();
      return granted?.isEnabled ?? false;
    }

    return false;
  }

  /// Request notification permission
  Future<bool> requestPermission() async {
    // Android 13+
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }

    // iOS
    final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
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
    // Check if already declined
    if (await userDeclinedNotifications()) {
      return false;
    }

    // Check if already have permission
    if (await hasPermission()) {
      return true;
    }

    // Show contextual dialog
    final shouldRequest = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_active_outlined,
                size: 32,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Never Miss $petName's Care",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "Get reminders so you never forget $petName's ${type.displayName}.",
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Not Now',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Enable Reminders',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (shouldRequest != true) {
      await setUserDeclinedNotifications(true);
      return false;
    }

    return await requestPermission();
  }

  /// Schedule countdown reminders (8 notifications: 7 days before through due day)
  Future<void> _scheduleCountdownReminders({
    required int baseId,
    required String petName,
    required String careName,
    required DateTime dueDate,
  }) async {
    for (int daysBefore = 7; daysBefore >= 0; daysBefore--) {
      final notificationDate = dueDate.subtract(Duration(days: daysBefore));

      // Skip if date is in the past
      if (notificationDate.isBefore(DateTime.now())) continue;

      final body = daysBefore == 0
          ? "$petName's $careName is due today!"
          : daysBefore == 1
              ? "$petName's $careName is due tomorrow"
              : "$petName's $careName is due in $daysBefore days";

      // Schedule at 9:00 AM
      final scheduledDate = DateTime(
        notificationDate.year,
        notificationDate.month,
        notificationDate.day,
        9,
        0,
      );

      // Skip if scheduled time has passed
      if (scheduledDate.isBefore(DateTime.now())) continue;

      await _scheduleNotification(
        id: baseId + daysBefore,
        title: 'Care Reminder',
        body: body,
        scheduledDate: scheduledDate,
      );
    }
  }

  /// Cancel all countdown reminders for a base ID
  Future<void> _cancelCountdownReminders(int baseId) async {
    for (int i = 0; i <= 7; i++) {
      await _plugin.cancel(baseId + i);
    }
  }

  /// Schedule a single notification
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
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
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: null,
    );
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

    final baseId = _vaccineBaseId(petId, vaccine.id);

    // Cancel any existing reminders first
    await _cancelCountdownReminders(baseId);

    // Schedule new countdown
    await _scheduleCountdownReminders(
      baseId: baseId,
      petName: petName,
      careName: vaccine.vaccineName,
      dueDate: vaccine.nextDueDate,
    );
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

    final baseId = _careBaseId(petId, type);

    // Cancel any existing reminders first
    await _cancelCountdownReminders(baseId);

    // Schedule new countdown
    await _scheduleCountdownReminders(
      baseId: baseId,
      petName: petName,
      careName: type.displayName,
      dueDate: dueDate,
    );
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
    // Cancel care reminders
    await cancelAllRemindersForPet(petId);

    // Cancel vaccine reminders
    for (final vaccineId in vaccineIds) {
      await cancelVaccineReminder(petId: petId, vaccineId: vaccineId);
    }
  }
}
