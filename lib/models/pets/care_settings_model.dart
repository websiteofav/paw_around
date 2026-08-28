import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

const _undefinedCare = Object();

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
  final List<DateTime> completionHistory;
  final DateTime updatedAt;
  final List<String> groomingTypes;

  /// For the new per-type grooming model: the specific grooming type this
  /// settings entry represents (e.g. 'Bathing', 'Nail Trimming').
  /// Null for tick & flea settings.
  final String? groomingType;

  const CareSettingsModel({
    required this.frequency,
    this.lastDate,
    this.snoozedUntil,
    this.completionHistory = const [],
    required this.updatedAt,
    this.groomingTypes = const [],
    this.groomingType,
  });

  factory CareSettingsModel.empty() {
    return CareSettingsModel(
      frequency: CareFrequency.none,
      lastDate: null,
      snoozedUntil: null,
      completionHistory: const [],
      updatedAt: DateTime.now(),
    );
  }

  CareSettingsModel copyWith({
    CareFrequency? frequency,
    DateTime? lastDate,
    DateTime? snoozedUntil,
    bool clearSnoozedUntil = false,
    List<DateTime>? completionHistory,
    bool clearCompletionHistory = false,
    DateTime? updatedAt,
    List<String>? groomingTypes,
    Object? groomingType = _undefinedCare,
  }) {
    return CareSettingsModel(
      frequency: frequency ?? this.frequency,
      lastDate: lastDate ?? this.lastDate,
      snoozedUntil:
          clearSnoozedUntil ? null : (snoozedUntil ?? this.snoozedUntil),
      completionHistory: clearCompletionHistory
          ? []
          : (completionHistory ?? this.completionHistory),
      updatedAt: updatedAt ?? this.updatedAt,
      groomingTypes: groomingTypes ?? this.groomingTypes,
      groomingType: groomingType == _undefinedCare
          ? this.groomingType
          : groomingType as String?,
    );
  }

  static const List<String> allGroomingTypes = [
    'Brushing / Combing',
    'Bathing',
    'Haircut / Trimming',
    'Nail Trimming',
    'Ear Cleaning',
    'Teeth Cleaning',
    'De-shedding',
    'Paw Cleaning',
    'Tick & Flea Grooming',
  ];

  /// Calculate next due date based on frequency and latest completion history
  DateTime? get nextDueDate {
    if (frequency == CareFrequency.none) {
      return null;
    }

    // Use latest date from completionHistory if available, otherwise fall back to lastDate
    final latestDate = completionHistory.isNotEmpty
        ? completionHistory.reduce((a, b) => a.isAfter(b) ? a : b)
        : lastDate;

    if (latestDate == null) {
      return null;
    }

    return latestDate.add(Duration(days: frequency.days));
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
  bool get isSnoozed =>
      snoozedUntil != null && snoozedUntil!.isAfter(DateTime.now());

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'frequency': frequency.toFirestoreValue(),
      'lastDate': lastDate != null ? Timestamp.fromDate(lastDate!) : null,
      'snoozedUntil':
          snoozedUntil != null ? Timestamp.fromDate(snoozedUntil!) : null,
      'completionHistory':
          completionHistory.map((date) => Timestamp.fromDate(date)).toList(),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'groomingTypes': groomingTypes,
      'groomingType': groomingType,
    };
  }

  /// Create from Firestore map
  factory CareSettingsModel.fromFirestore(Map<String, dynamic>? data) {
    if (data == null) {
      return CareSettingsModel.empty();
    }

    // Handle backward compatibility: if completionHistory doesn't exist, create it from lastDate
    List<DateTime> history = [];
    if (data['completionHistory'] != null) {
      final historyList = data['completionHistory'] as List<dynamic>?;
      history =
          historyList?.map((ts) => (ts as Timestamp).toDate()).toList() ?? [];
    } else if (data['lastDate'] != null) {
      // Migrate existing lastDate to history for backward compatibility
      history = [(data['lastDate'] as Timestamp).toDate()];
    }

    return CareSettingsModel(
      frequency:
          CareFrequencyExtension.fromString(data['frequency'] as String?),
      lastDate: (data['lastDate'] as Timestamp?)?.toDate(),
      snoozedUntil: (data['snoozedUntil'] as Timestamp?)?.toDate(),
      completionHistory: history,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      groomingTypes: List<String>.from(data['groomingTypes'] ?? []),
      groomingType: data['groomingType'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'frequency': frequency.toFirestoreValue(),
      'lastDate': lastDate?.toIso8601String(),
      'snoozedUntil': snoozedUntil?.toIso8601String(),
      'completionHistory':
          completionHistory.map((date) => date.toIso8601String()).toList(),
      'updatedAt': updatedAt.toIso8601String(),
      'groomingTypes': groomingTypes,
      'groomingType': groomingType,
    };
  }

  /// Create from JSON
  factory CareSettingsModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return CareSettingsModel.empty();
    }

    // Handle backward compatibility
    List<DateTime> history = [];
    if (json['completionHistory'] != null) {
      final historyList = json['completionHistory'] as List<dynamic>?;
      history = historyList?.map<DateTime>((value) {
            if (value is String) {
              // Stored as ISO string
              return DateTime.parse(value);
            }
            if (value is Timestamp) {
              // Coming directly from Firestore
              return value.toDate();
            }
            // Fallback: try parsing string representation
            return DateTime.parse(value.toString());
          }).toList() ??
          [];
    } else if (json['lastDate'] != null) {
      history = [DateTime.parse(json['lastDate'] as String)];
    }

    return CareSettingsModel(
      frequency:
          CareFrequencyExtension.fromString(json['frequency'] as String?),
      lastDate: json['lastDate'] != null
          ? (json['lastDate'] is Timestamp
              ? (json['lastDate'] as Timestamp).toDate()
              : DateTime.parse(json['lastDate'] as String))
          : null,
      snoozedUntil: json['snoozedUntil'] != null
          ? (json['snoozedUntil'] is Timestamp
              ? (json['snoozedUntil'] as Timestamp).toDate()
              : DateTime.parse(json['snoozedUntil'] as String))
          : null,
      completionHistory: history,
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] is Timestamp
              ? (json['updatedAt'] as Timestamp).toDate()
              : DateTime.parse(json['updatedAt'] as String))
          : DateTime.now(),
      groomingTypes: List<String>.from(json['groomingTypes'] ?? []),
      groomingType: json['groomingType'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        frequency,
        lastDate,
        snoozedUntil,
        completionHistory,
        updatedAt,
        groomingTypes,
        groomingType,
      ];
}
