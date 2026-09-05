import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:paw_around/utils/date_utils.dart';

/// Status of a sitter booking. Stored in Firestore as its [name].
enum BookingStatus { confirmed, cancelled }

/// A pet-sitter booking, stored at `users/{uid}/bookings/{id}`.
///
/// Pet/professional/address fields are snapshotted at booking time (not
/// live references), so later edits or deletes to the pet, professional
/// roster, or address don't retroactively change a past booking.
class BookingModel extends Equatable {
  final String id;
  final String petId;
  final String petName;
  final String petBreed;
  final String petAgeLabel;
  final String? petImagePath;
  final String professionalId;
  final String professionalName;
  final String professionalRole;
  final double professionalRating;
  final int professionalReviewCount;
  final String addressLabel;
  final String addressText;
  final DateTime scheduledDate;
  final String scheduledTimeSlot;
  final double durationHours;
  final int totalAmount;
  final BookingStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BookingModel({
    required this.id,
    required this.petId,
    required this.petName,
    required this.petBreed,
    required this.petAgeLabel,
    this.petImagePath,
    required this.professionalId,
    required this.professionalName,
    required this.professionalRole,
    required this.professionalRating,
    required this.professionalReviewCount,
    required this.addressLabel,
    required this.addressText,
    required this.scheduledDate,
    required this.scheduledTimeSlot,
    required this.durationHours,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Builds a new booking with fresh timestamps and `status: confirmed` —
  /// [id] is a placeholder; Firestore assigns the real id on write.
  factory BookingModel.create({
    required String petId,
    required String petName,
    required String petBreed,
    required String petAgeLabel,
    String? petImagePath,
    required String professionalId,
    required String professionalName,
    required String professionalRole,
    required double professionalRating,
    required int professionalReviewCount,
    required String addressLabel,
    required String addressText,
    required DateTime scheduledDate,
    required String scheduledTimeSlot,
    required double durationHours,
    required int totalAmount,
  }) {
    final now = DateTime.now();
    return BookingModel(
      id: '',
      petId: petId,
      petName: petName,
      petBreed: petBreed,
      petAgeLabel: petAgeLabel,
      petImagePath: petImagePath,
      professionalId: professionalId,
      professionalName: professionalName,
      professionalRole: professionalRole,
      professionalRating: professionalRating,
      professionalReviewCount: professionalReviewCount,
      addressLabel: addressLabel,
      addressText: addressText,
      scheduledDate: DateTime(scheduledDate.year, scheduledDate.month, scheduledDate.day),
      scheduledTimeSlot: scheduledTimeSlot,
      durationHours: durationHours,
      totalAmount: totalAmount,
      status: BookingStatus.confirmed,
      createdAt: now,
      updatedAt: now,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'petId': petId,
      'petName': petName,
      'petBreed': petBreed,
      'petAgeLabel': petAgeLabel,
      'petImagePath': petImagePath,
      'professionalId': professionalId,
      'professionalName': professionalName,
      'professionalRole': professionalRole,
      'professionalRating': professionalRating,
      'professionalReviewCount': professionalReviewCount,
      'addressLabel': addressLabel,
      'addressText': addressText,
      'scheduledDate': Timestamp.fromDate(scheduledDate),
      'scheduledTimeSlot': scheduledTimeSlot,
      'durationHours': durationHours,
      'totalAmount': totalAmount,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookingModel(
      id: doc.id,
      petId: data['petId'] as String? ?? '',
      petName: data['petName'] as String? ?? '',
      petBreed: data['petBreed'] as String? ?? '',
      petAgeLabel: data['petAgeLabel'] as String? ?? '',
      petImagePath: data['petImagePath'] as String?,
      professionalId: data['professionalId'] as String? ?? '',
      professionalName: data['professionalName'] as String? ?? '',
      professionalRole: data['professionalRole'] as String? ?? '',
      professionalRating: (data['professionalRating'] as num?)?.toDouble() ?? 0.0,
      professionalReviewCount: (data['professionalReviewCount'] as num?)?.toInt() ?? 0,
      addressLabel: data['addressLabel'] as String? ?? '',
      addressText: data['addressText'] as String? ?? '',
      scheduledDate: (data['scheduledDate'] as Timestamp).toDate(),
      scheduledTimeSlot: data['scheduledTimeSlot'] as String? ?? '',
      durationHours: (data['durationHours'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (data['totalAmount'] as num?)?.toInt() ?? 0,
      status: BookingStatus.values.byName(data['status'] as String? ?? 'confirmed'),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  bool get isCancelled => status == BookingStatus.cancelled;

  String get confirmedDateLabel => AppDateUtils.formatDateCard(scheduledDate);

  String get sessionDayLabel =>
      '${AppDateUtils.fullWeekdayName(scheduledDate)}, ${AppDateUtils.formatDateCard(scheduledDate)}';

  /// "Starts in N days", or null if the session is today or already past.
  String? get startsInLabel {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = scheduledDate.difference(today).inDays;
    if (days <= 0) return null;
    return 'Starts in $days day${days > 1 ? 's' : ''}';
  }

  @override
  List<Object?> get props => [
        id,
        petId,
        petName,
        petBreed,
        petAgeLabel,
        petImagePath,
        professionalId,
        professionalName,
        professionalRole,
        professionalRating,
        professionalReviewCount,
        addressLabel,
        addressText,
        scheduledDate,
        scheduledTimeSlot,
        durationHours,
        totalAmount,
        status,
        createdAt,
        updatedAt,
      ];
}
