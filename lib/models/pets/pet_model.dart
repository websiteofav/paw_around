import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:paw_around/models/pets/care_settings_model.dart';
import 'package:paw_around/models/vaccines/vaccine_model.dart';

const _undefined = Object();

class PetModel extends Equatable {
  final String id;
  final String name;
  final String species;
  final String breed;
  final String gender;
  final DateTime dateOfBirth;
  final double weight;
  final double height;
  final String colour;
  final String notes;
  final List<String> personality;
  final String? imagePath;
  final List<VaccineModel> vaccines;
  final List<CareSettingsModel> groomingSettings;
  final CareSettingsModel? tickFleaSettings;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? petPublicId;
  final bool isLost;
  final DateTime? lastSeenAt;
  final String? lastSeenLocation;

  const PetModel({
    required this.id,
    required this.name,
    required this.species,
    required this.breed,
    required this.gender,
    required this.dateOfBirth,
    required this.weight,
    this.height = 0.0,
    this.colour = '',
    required this.notes,
    this.personality = const [],
    this.imagePath,
    this.vaccines = const [],
    this.groomingSettings = const [],
    this.tickFleaSettings,
    required this.createdAt,
    required this.updatedAt,
    this.petPublicId,
    this.isLost = false,
    this.lastSeenAt,
    this.lastSeenLocation,
  });

  static const String _petPublicIdPrefix = 'pet_';
  static const String _idAlphabet =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  static const int _idLength = 20;

  static String _generatePetPublicId() {
    final random = Random.secure();
    final buffer = StringBuffer(_petPublicIdPrefix);
    for (var i = 0; i < _idLength; i++) {
      buffer.write(_idAlphabet[random.nextInt(_idAlphabet.length)]);
    }
    return buffer.toString();
  }

  // Factory constructor for creating a new pet
  factory PetModel.create({
    required String name,
    required String species,
    required String breed,
    required String gender,
    required DateTime dateOfBirth,
    required double weight,
    double height = 0.0,
    String colour = '',
    required String notes,
    List<String> personality = const [],
    String? imagePath,
    List<VaccineModel> vaccines = const [],
    List<CareSettingsModel> groomingSettings = const [],
    CareSettingsModel? tickFleaSettings,
  }) {
    final now = DateTime.now();
    return PetModel(
      id: now.millisecondsSinceEpoch.toString(),
      name: name,
      species: species,
      breed: breed,
      gender: gender,
      dateOfBirth: dateOfBirth,
      weight: weight,
      height: height,
      colour: colour,
      notes: notes,
      personality: personality,
      imagePath: imagePath,
      vaccines: vaccines,
      groomingSettings: groomingSettings,
      tickFleaSettings: tickFleaSettings,
      createdAt: now,
      updatedAt: now,
      petPublicId: _generatePetPublicId(),
      isLost: false,
    );
  }

  // Copy with method for updating pet
  PetModel copyWith({
    String? id,
    String? name,
    String? species,
    String? breed,
    String? gender,
    DateTime? dateOfBirth,
    double? weight,
    double? height,
    String? colour,
    String? notes,
    List<String>? personality,
    String? imagePath,
    List<VaccineModel>? vaccines,
    List<CareSettingsModel>? groomingSettings,
    CareSettingsModel? tickFleaSettings,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? petPublicId = _undefined,
    bool? isLost,
    Object? lastSeenAt = _undefined,
    Object? lastSeenLocation = _undefined,
  }) {
    return PetModel(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      colour: colour ?? this.colour,
      notes: notes ?? this.notes,
      personality: personality ?? this.personality,
      imagePath: imagePath ?? this.imagePath,
      vaccines: vaccines ?? this.vaccines,
      groomingSettings: groomingSettings ?? this.groomingSettings,
      tickFleaSettings: tickFleaSettings ?? this.tickFleaSettings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      petPublicId:
          petPublicId == _undefined ? this.petPublicId : petPublicId as String?,
      isLost: isLost ?? this.isLost,
      lastSeenAt:
          lastSeenAt == _undefined ? this.lastSeenAt : lastSeenAt as DateTime?,
      lastSeenLocation: lastSeenLocation == _undefined
          ? this.lastSeenLocation
          : lastSeenLocation as String?,
    );
  }

  // Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'species': species,
      'breed': breed,
      'gender': gender,
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'weight': weight,
      'height': height,
      'colour': colour,
      'notes': notes,
      'personality': personality,
      'imagePath': imagePath,
      'vaccines': vaccines.map((v) => v.toFirestore()).toList(),
      'groomingSettings': groomingSettings.map((s) => s.toFirestore()).toList(),
      'tickFleaSettings': tickFleaSettings?.toFirestore(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'petPublicId': petPublicId,
      'isLost': isLost,
      'lastSeenAt': lastSeenAt != null ? Timestamp.fromDate(lastSeenAt!) : null,
      'lastSeenLocation': lastSeenLocation,
    };
  }

  // Create from Firestore document
  factory PetModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PetModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      species: data['species'] as String? ?? '',
      breed: data['breed'] as String? ?? '',
      gender: data['gender'] as String? ?? '',
      dateOfBirth: (data['dateOfBirth'] as Timestamp).toDate(),
      weight: (data['weight'] as num?)?.toDouble() ?? 0.0,
      height: (data['height'] as num?)?.toDouble() ?? 0.0,
      colour: data['colour'] as String? ?? '',
      notes: data['notes'] as String? ?? '',
      personality: (data['personality'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      imagePath: data['imagePath'] as String?,
      vaccines: (data['vaccines'] as List<dynamic>?)
              ?.map(
                  (v) => VaccineModel.fromFirestore(v as Map<String, dynamic>))
              .toList() ??
          [],
      groomingSettings:
          _parseGroomingSettingsFromFirestore(data['groomingSettings']),
      tickFleaSettings: data['tickFleaSettings'] != null
          ? CareSettingsModel.fromFirestore(
              data['tickFleaSettings'] as Map<String, dynamic>)
          : null,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      petPublicId: data['petPublicId'] as String?,
      isLost: (data['isLost'] as bool?) ?? false,
      lastSeenAt: (data['lastSeenAt'] as Timestamp?)?.toDate(),
      lastSeenLocation: data['lastSeenLocation'] as String?,
    );
  }

  // Convert to JSON (for compatibility)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'species': species,
      'breed': breed,
      'gender': gender,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'weight': weight,
      'height': height,
      'colour': colour,
      'notes': notes,
      'personality': personality,
      'imagePath': imagePath,
      'vaccines': vaccines.map((v) => v.toJson()).toList(),
      'groomingSettings': groomingSettings.map((s) => s.toJson()).toList(),
      'tickFleaSettings': tickFleaSettings?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'petPublicId': petPublicId,
      'isLost': isLost,
      'lastSeenAt': lastSeenAt?.toIso8601String(),
      'lastSeenLocation': lastSeenLocation,
    };
  }

  // Create from JSON
  factory PetModel.fromJson(Map<String, dynamic> json) {
    return PetModel(
      id: json['id'] as String,
      name: json['name'] as String,
      species: json['species'] as String,
      breed: json['breed'] as String,
      gender: json['gender'] as String,
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      weight: (json['weight'] as num).toDouble(),
      height: (json['height'] as num?)?.toDouble() ?? 0.0,
      colour: json['colour'] as String? ?? '',
      notes: json['notes'] as String,
      personality: (json['personality'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      imagePath: json['imagePath'] as String?,
      vaccines: (json['vaccines'] as List<dynamic>?)
              ?.map((v) => VaccineModel.fromJson(v as Map<String, dynamic>))
              .toList() ??
          [],
      groomingSettings:
          _parseGroomingSettingsFromJson(json['groomingSettings']),
      tickFleaSettings: json['tickFleaSettings'] != null
          ? CareSettingsModel.fromJson(
              json['tickFleaSettings'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      petPublicId: json['petPublicId'] as String?,
      isLost: (json['isLost'] as bool?) ?? false,
      lastSeenAt: json['lastSeenAt'] != null
          ? DateTime.tryParse(json['lastSeenAt'] as String)
          : null,
      lastSeenLocation: json['lastSeenLocation'] as String?,
    );
  }

  // ── Static helpers for backward-compat grooming list parsing ──────────────

  /// Parses Firestore value into `List<CareSettingsModel>`.
  /// Handles three cases:
  ///   • null   → empty list
  ///   • List   → new format, parse each element
  ///   • Map    → old format (single model with groomingTypes list), migrate
  static List<CareSettingsModel> _parseGroomingSettingsFromFirestore(
      dynamic raw) {
    if (raw == null) return const [];
    if (raw is List) {
      return raw
          .map(
              (e) => CareSettingsModel.fromFirestore(e as Map<String, dynamic>))
          .toList();
    }
    if (raw is Map<String, dynamic>) {
      final old = CareSettingsModel.fromFirestore(raw);
      if (old.groomingTypes.isEmpty) {
        return [old.copyWith(groomingType: null)];
      }
      return old.groomingTypes
          .map((t) => old.copyWith(groomingType: t))
          .toList();
    }
    return const [];
  }

  /// Parses JSON value into `List<CareSettingsModel>`.
  /// Same three-case backward-compat logic as the Firestore variant.
  static List<CareSettingsModel> _parseGroomingSettingsFromJson(dynamic raw) {
    if (raw == null) return const [];
    if (raw is List) {
      return raw
          .map((e) => CareSettingsModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (raw is Map<String, dynamic>) {
      final old = CareSettingsModel.fromJson(raw);
      if (old.groomingTypes.isEmpty) {
        return [old.copyWith(groomingType: null)];
      }
      return old.groomingTypes
          .map((t) => old.copyWith(groomingType: t))
          .toList();
    }
    return const [];
  }

  // Helper methods
  int get ageInMonths {
    final now = DateTime.now();
    final age = now.difference(dateOfBirth);
    return (age.inDays / 30).round();
  }

  int get ageInYears {
    final now = DateTime.now();
    final age = now.difference(dateOfBirth);
    return (age.inDays / 365).round();
  }

  String get ageString {
    final years = ageInYears;
    final months = ageInMonths % 12;

    if (years > 0 && months > 0) {
      return '$years year${years > 1 ? 's' : ''}, $months month${months > 1 ? 's' : ''}';
    } else if (years > 0) {
      return '$years year${years > 1 ? 's' : ''}';
    } else {
      return '$months month${months > 1 ? 's' : ''}';
    }
  }

  List<VaccineModel> get upcomingVaccines {
    final now = DateTime.now();
    return vaccines
        .where((vaccine) => vaccine.nextDueDate?.isAfter(now) ?? false)
        .toList();
  }

  List<VaccineModel> get overdueVaccines {
    final now = DateTime.now();
    return vaccines
        .where((vaccine) => vaccine.nextDueDate?.isBefore(now) ?? false)
        .toList();
  }

  /// Check if pet supports medical care (vaccines, tick & flea)
  /// Only dogs and cats support full medical care
  bool get supportsMedicalCare {
    final speciesLower = species.toLowerCase();
    return speciesLower == 'dog' || speciesLower == 'cat';
  }

  /// Check if any care is due (vaccines, grooming, or tick & flea)
  bool get hasCareDue {
    // Check vaccines
    if (supportsMedicalCare) {
      for (final vaccine in vaccines) {
        if (vaccine.nextDueDate
                ?.isBefore(DateTime.now().add(const Duration(days: 30))) ??
            false) {
          return true;
        }
      }
    }

    // Check grooming — any item due soon or overdue triggers the flag
    if (groomingSettings.any((s) => s.isDueSoon || s.isOverdue)) {
      return true;
    }

    // Check tick & flea
    if (supportsMedicalCare && tickFleaSettings != null) {
      if (tickFleaSettings!.isDueSoon || tickFleaSettings!.isOverdue) {
        return true;
      }
    }

    return false;
  }

  /// Get count of vaccines due within 30 days
  int get upcomingVaccinesCount {
    final now = DateTime.now();
    final thirtyDaysFromNow = now.add(const Duration(days: 30));
    return vaccines.where((vaccine) {
      return (vaccine.nextDueDate?.isAfter(now) ?? false) &&
          (vaccine.nextDueDate?.isBefore(thirtyDaysFromNow) ?? false);
    }).length;
  }

  /// Get grooming status type: 'overdue', 'soon', 'good', or null if not set.
  /// Checks across all grooming items — worst status wins.
  String? get groomingStatusType {
    final active = groomingSettings.where((s) => s.hasReminder).toList();
    if (active.isEmpty) return null;
    if (active.any((s) => s.isOverdue)) return 'overdue';
    if (active.any((s) => s.isDueSoon)) return 'soon';
    return 'good';
  }

  /// Get tick & flea status type: 'overdue', 'soon', 'good', or null if not set
  String? get tickFleaStatusType {
    if (tickFleaSettings == null || !tickFleaSettings!.hasReminder) {
      return null;
    }
    if (tickFleaSettings!.isOverdue) {
      return 'overdue';
    }
    if (tickFleaSettings!.isDueSoon) {
      return 'soon';
    }
    return 'good';
  }

  @override
  List<Object?> get props => [
        id,
        name,
        species,
        breed,
        gender,
        dateOfBirth,
        weight,
        height,
        colour,
        notes,
        personality,
        imagePath,
        vaccines,
        groomingSettings,
        tickFleaSettings,
        createdAt,
        updatedAt,
        petPublicId,
        isLost,
        lastSeenAt,
        lastSeenLocation,
      ];
}
