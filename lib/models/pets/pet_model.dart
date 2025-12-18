import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:paw_around/models/pets/care_settings_model.dart';
import 'package:paw_around/models/vaccines/vaccine_model.dart';

class PetModel extends Equatable {
  final String id;
  final String name;
  final String species;
  final String breed;
  final String gender;
  final DateTime dateOfBirth;
  final double weight;
  final String notes;
  final String? imagePath;
  final List<VaccineModel> vaccines;
  final CareSettingsModel? groomingSettings;
  final CareSettingsModel? tickFleaSettings;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PetModel({
    required this.id,
    required this.name,
    required this.species,
    required this.breed,
    required this.gender,
    required this.dateOfBirth,
    required this.weight,
    required this.notes,
    this.imagePath,
    this.vaccines = const [],
    this.groomingSettings,
    this.tickFleaSettings,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor for creating a new pet
  factory PetModel.create({
    required String name,
    required String species,
    required String breed,
    required String gender,
    required DateTime dateOfBirth,
    required double weight,
    required String notes,
    String? imagePath,
    List<VaccineModel> vaccines = const [],
    CareSettingsModel? groomingSettings,
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
      notes: notes,
      imagePath: imagePath,
      vaccines: vaccines,
      groomingSettings: groomingSettings,
      tickFleaSettings: tickFleaSettings,
      createdAt: now,
      updatedAt: now,
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
    String? notes,
    String? imagePath,
    List<VaccineModel>? vaccines,
    CareSettingsModel? groomingSettings,
    CareSettingsModel? tickFleaSettings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PetModel(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      weight: weight ?? this.weight,
      notes: notes ?? this.notes,
      imagePath: imagePath ?? this.imagePath,
      vaccines: vaccines ?? this.vaccines,
      groomingSettings: groomingSettings ?? this.groomingSettings,
      tickFleaSettings: tickFleaSettings ?? this.tickFleaSettings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
      'notes': notes,
      'imagePath': imagePath,
      'vaccines': vaccines.map((v) => v.toFirestore()).toList(),
      'groomingSettings': groomingSettings?.toFirestore(),
      'tickFleaSettings': tickFleaSettings?.toFirestore(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
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
      notes: data['notes'] as String? ?? '',
      imagePath: data['imagePath'] as String?,
      vaccines: (data['vaccines'] as List<dynamic>?)
              ?.map((v) => VaccineModel.fromFirestore(v as Map<String, dynamic>))
              .toList() ??
          [],
      groomingSettings: data['groomingSettings'] != null
          ? CareSettingsModel.fromFirestore(data['groomingSettings'] as Map<String, dynamic>)
          : null,
      tickFleaSettings: data['tickFleaSettings'] != null
          ? CareSettingsModel.fromFirestore(data['tickFleaSettings'] as Map<String, dynamic>)
          : null,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
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
      'notes': notes,
      'imagePath': imagePath,
      'vaccines': vaccines.map((v) => v.toJson()).toList(),
      'groomingSettings': groomingSettings?.toJson(),
      'tickFleaSettings': tickFleaSettings?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
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
      notes: json['notes'] as String,
      imagePath: json['imagePath'] as String?,
      vaccines:
          (json['vaccines'] as List<dynamic>?)?.map((v) => VaccineModel.fromJson(v as Map<String, dynamic>)).toList() ??
              [],
      groomingSettings: json['groomingSettings'] != null
          ? CareSettingsModel.fromJson(json['groomingSettings'] as Map<String, dynamic>)
          : null,
      tickFleaSettings: json['tickFleaSettings'] != null
          ? CareSettingsModel.fromJson(json['tickFleaSettings'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
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
    return vaccines.where((vaccine) => vaccine.nextDueDate.isAfter(now)).toList();
  }

  List<VaccineModel> get overdueVaccines {
    final now = DateTime.now();
    return vaccines.where((vaccine) => vaccine.nextDueDate.isBefore(now)).toList();
  }

  /// Check if pet supports medical care (vaccines, tick & flea)
  /// Only dogs and cats support full medical care
  bool get supportsMedicalCare {
    final speciesLower = species.toLowerCase();
    return speciesLower == 'dog' || speciesLower == 'cat';
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
        notes,
        imagePath,
        vaccines,
        groomingSettings,
        tickFleaSettings,
        createdAt,
        updatedAt,
      ];
}
