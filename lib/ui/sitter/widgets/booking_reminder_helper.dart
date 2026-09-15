import 'package:flutter/material.dart';
import 'package:paw_around/models/sitters/booking_model.dart';
import 'package:paw_around/services/notification_service.dart';

/// Requests notification permission (if needed) and schedules the
/// "sitter arriving soon" reminder for a just-created booking — mirrors
/// VaccineFormHelper.scheduleOrCancel's request-then-schedule pattern.
class BookingReminderHelper {
  BookingReminderHelper._();

  static Future<void> scheduleForBooking({
    required BuildContext context,
    required BookingModel booking,
    required String bookingId,
  }) async {
    final notificationService = NotificationService();
    final hasPermission = await notificationService.requestPermissionIfNeeded(
      context,
      booking.petName,
      ReminderType.sitterBooking,
    );
    if (!hasPermission) return;

    await notificationService.scheduleBookingReminder(
      bookingId: bookingId,
      petName: booking.petName,
      professionalName: booking.professionalName,
      sessionDateTime: booking.scheduledDateTime,
    );
  }
}
