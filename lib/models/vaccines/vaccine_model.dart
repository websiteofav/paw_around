import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class VaccineModel extends Equatable {
  final String id;
  final String vaccineName;
  final DateTime dateGiven;
  final DateTime nextDueDate;
  final String notes;
  final bool setReminder;
  final DateTime? snoozedUntil;
  final DateTime createdAt;
  final DateTime updatedAt;

  const VaccineModel({
    required this.id,
    required this.vaccineName,
    required this.dateGiven,
    required this.nextDueDate,
    required this.notes,
    required this.setReminder,
    this.snoozedUntil,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor for creating a new vaccine
  factory VaccineModel.create({
    required String vaccineName,
    required DateTime dateGiven,
    required DateTime nextDueDate,
    required String notes,
    required bool setReminder,
    DateTime? snoozedUntil,
  }) {
    final now = DateTime.now();
    return VaccineModel(
      id: now.millisecondsSinceEpoch.toString(),
      vaccineName: vaccineName,
      dateGiven: dateGiven,
      nextDueDate: nextDueDate,
      notes: notes,
      setReminder: setReminder,
      snoozedUntil: snoozedUntil,
      createdAt: now,
      updatedAt: now,
    );
  }

  // Copy with method for updating vaccine
  VaccineModel copyWith({
    String? id,
    String? vaccineName,
    DateTime? dateGiven,
    DateTime? nextDueDate,
    String? notes,
    bool? setReminder,
    DateTime? snoozedUntil,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VaccineModel(
      id: id ?? this.id,
      vaccineName: vaccineName ?? this.vaccineName,
      dateGiven: dateGiven ?? this.dateGiven,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      notes: notes ?? this.notes,
      setReminder: setReminder ?? this.setReminder,
      snoozedUntil: snoozedUntil ?? this.snoozedUntil,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Convert to Firestore map (for embedding in pet document)
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'vaccineName': vaccineName,
      'dateGiven': Timestamp.fromDate(dateGiven),
      'nextDueDate': Timestamp.fromDate(nextDueDate),
      'notes': notes,
      'setReminder': setReminder,
      'snoozedUntil': snoozedUntil != null ? Timestamp.fromDate(snoozedUntil!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Create from Firestore map (for reading from pet document)
  factory VaccineModel.fromFirestore(Map<String, dynamic> data) {
    return VaccineModel(
      id: data['id'] as String,
      vaccineName: data['vaccineName'] as String,
      dateGiven: (data['dateGiven'] as Timestamp).toDate(),
      nextDueDate: (data['nextDueDate'] as Timestamp).toDate(),
      notes: data['notes'] as String? ?? '',
      setReminder: data['setReminder'] as bool? ?? false,
      snoozedUntil: (data['snoozedUntil'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  // Convert to JSON (for compatibility)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vaccineName': vaccineName,
      'dateGiven': dateGiven.toIso8601String(),
      'nextDueDate': nextDueDate.toIso8601String(),
      'notes': notes,
      'setReminder': setReminder,
      'snoozedUntil': snoozedUntil?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create from JSON
  factory VaccineModel.fromJson(Map<String, dynamic> json) {
    return VaccineModel(
      id: json['id'] as String,
      vaccineName: json['vaccineName'] as String,
      dateGiven: DateTime.parse(json['dateGiven'] as String),
      nextDueDate: DateTime.parse(json['nextDueDate'] as String),
      notes: json['notes'] as String,
      setReminder: json['setReminder'] as bool,
      snoozedUntil: json['snoozedUntil'] != null ? DateTime.parse(json['snoozedUntil'] as String) : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  // Helper methods
  bool get isSnoozed {
    return snoozedUntil != null && snoozedUntil!.isAfter(DateTime.now());
  }

  bool get isOverdue {
    return nextDueDate.isBefore(DateTime.now());
  }

  bool get isDueSoon {
    final now = DateTime.now();
    final daysUntilDue = nextDueDate.difference(now).inDays;
    return daysUntilDue <= 30 && daysUntilDue >= 0;
  }

  int get daysUntilDue {
    return nextDueDate.difference(DateTime.now()).inDays;
  }

  String get status {
    if (isOverdue) {
      return 'Overdue';
    } else if (isDueSoon) {
      return 'Due Soon';
    } else {
      return 'Up to Date';
    }
  }

  String get timeUntilDue {
    final days = daysUntilDue;
    if (days < 0) {
      return '${-days} days overdue';
    } else if (days == 0) {
      return 'Due today';
    } else if (days == 1) {
      return 'Due tomorrow';
    } else {
      return 'Due in $days days';
    }
  }

  @override
  List<Object?> get props => [
        id,
        vaccineName,
        dateGiven,
        nextDueDate,
        notes,
        setReminder,
        snoozedUntil,
        createdAt,
        updatedAt,
      ];
}
