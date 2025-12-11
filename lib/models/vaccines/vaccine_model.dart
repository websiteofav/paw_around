import 'package:equatable/equatable.dart';
import 'package:hive_ce/hive.dart';

part 'vaccine_model.g.dart';

@HiveType(typeId: 0)
class VaccineModel extends Equatable {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String vaccineName;
  @HiveField(2)
  final DateTime dateGiven;
  @HiveField(3)
  final DateTime nextDueDate;
  @HiveField(4)
  final String notes;
  @HiveField(5)
  final bool setReminder;
  @HiveField(6)
  final DateTime createdAt;
  @HiveField(7)
  final DateTime updatedAt;

  const VaccineModel({
    required this.id,
    required this.vaccineName,
    required this.dateGiven,
    required this.nextDueDate,
    required this.notes,
    required this.setReminder,
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
  }) {
    final now = DateTime.now();
    return VaccineModel(
      id: now.millisecondsSinceEpoch.toString(),
      vaccineName: vaccineName,
      dateGiven: dateGiven,
      nextDueDate: nextDueDate,
      notes: notes,
      setReminder: setReminder,
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vaccineName': vaccineName,
      'dateGiven': dateGiven.toIso8601String(),
      'nextDueDate': nextDueDate.toIso8601String(),
      'notes': notes,
      'setReminder': setReminder,
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
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  // Helper methods
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
        createdAt,
        updatedAt,
      ];
}
