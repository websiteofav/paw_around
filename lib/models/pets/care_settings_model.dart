import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum CareFrequency {
  none,
  weekly,
  monthly,
  quarterly,
}

extension CareFrequencyExtension on CareFrequency {
  String get displayName {
    switch (this) {
      case CareFrequency.none:
        return 'No reminder';
      case CareFrequency.weekly:
        return 'Every week';
      case CareFrequency.monthly:
        return 'Every month';
      case CareFrequency.quarterly:
        return 'Every 3 months';
    }
  }

  int get days {
    switch (this) {
      case CareFrequency.none:
        return 0;
      case CareFrequency.weekly:
        return 7;
      case CareFrequency.monthly:
        return 30;
      case CareFrequency.quarterly:
        return 90;
    }
  }

  static CareFrequency fromString(String? value) {
    switch (value) {
      case 'weekly':
        return CareFrequency.weekly;
      case 'monthly':
        return CareFrequency.monthly;
      case 'quarterly':
        return CareFrequency.quarterly;
      default:
        return CareFrequency.none;
    }
  }

  String toFirestoreValue() {
    switch (this) {
      case CareFrequency.none:
        return 'none';
      case CareFrequency.weekly:
        return 'weekly';
      case CareFrequency.monthly:
        return 'monthly';
      case CareFrequency.quarterly:
        return 'quarterly';
    }
  }
}

class CareSettingsModel extends Equatable {
  final CareFrequency frequency;
  final DateTime? lastDate;
  final DateTime? snoozedUntil;
  final DateTime updatedAt;

  const CareSettingsModel({
    required this.frequency,
    this.lastDate,
    this.snoozedUntil,
    required this.updatedAt,
  });

  factory CareSettingsModel.empty() {
    return CareSettingsModel(
      frequency: CareFrequency.none,
      lastDate: null,
      snoozedUntil: null,
      updatedAt: DateTime.now(),
    );
  }

  CareSettingsModel copyWith({
    CareFrequency? frequency,
    DateTime? lastDate,
    DateTime? snoozedUntil,
    DateTime? updatedAt,
  }) {
    return CareSettingsModel(
      frequency: frequency ?? this.frequency,
      lastDate: lastDate ?? this.lastDate,
      snoozedUntil: snoozedUntil ?? this.snoozedUntil,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Calculate next due date based on frequency and last date
  DateTime? get nextDueDate {
    if (frequency == CareFrequency.none || lastDate == null) {
      return null;
    }
    return lastDate!.add(Duration(days: frequency.days));
  }

  /// Check if care is due within the next 7 days
  bool get isDueSoon {
    final next = nextDueDate;
    if (next == null) {
      return false;
    }
    final daysUntilDue = next.difference(DateTime.now()).inDays;
    return daysUntilDue >= 0 && daysUntilDue <= 7;
  }

  /// Check if care is overdue
  bool get isOverdue {
    final next = nextDueDate;
    if (next == null) {
      return false;
    }
    return next.isBefore(DateTime.now());
  }

  /// Get days until next due date
  int? get daysUntilDue {
    final next = nextDueDate;
    if (next == null) {
      return null;
    }
    return next.difference(DateTime.now()).inDays;
  }

  /// Check if reminder is enabled
  bool get hasReminder => frequency != CareFrequency.none;

  /// Check if action is snoozed
  bool get isSnoozed => snoozedUntil != null && snoozedUntil!.isAfter(DateTime.now());

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'frequency': frequency.toFirestoreValue(),
      'lastDate': lastDate != null ? Timestamp.fromDate(lastDate!) : null,
      'snoozedUntil': snoozedUntil != null ? Timestamp.fromDate(snoozedUntil!) : null,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Create from Firestore map
  factory CareSettingsModel.fromFirestore(Map<String, dynamic>? data) {
    if (data == null) {
      return CareSettingsModel.empty();
    }
    return CareSettingsModel(
      frequency: CareFrequencyExtension.fromString(data['frequency'] as String?),
      lastDate: (data['lastDate'] as Timestamp?)?.toDate(),
      snoozedUntil: (data['snoozedUntil'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'frequency': frequency.toFirestoreValue(),
      'lastDate': lastDate?.toIso8601String(),
      'snoozedUntil': snoozedUntil?.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory CareSettingsModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return CareSettingsModel.empty();
    }
    return CareSettingsModel(
      frequency: CareFrequencyExtension.fromString(json['frequency'] as String?),
      lastDate: json['lastDate'] != null ? DateTime.parse(json['lastDate'] as String) : null,
      snoozedUntil: json['snoozedUntil'] != null ? DateTime.parse(json['snoozedUntil'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [frequency, lastDate, snoozedUntil, updatedAt];
}
