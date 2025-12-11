import 'package:equatable/equatable.dart';
import 'package:hive_ce/hive.dart';
import 'package:paw_around/models/vaccines/vaccine_model.dart';

part 'pet_model.g.dart';

@HiveType(typeId: 1)
class PetModel extends Equatable {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String species;
  @HiveField(3)
  final String breed;
  @HiveField(4)
  final String gender;
  @HiveField(5)
  final DateTime dateOfBirth;
  @HiveField(6)
  final double weight;
  @HiveField(7)
  final String notes;
  @HiveField(8)
  final String? imagePath;
  @HiveField(9)
  final List<VaccineModel> vaccines;
  @HiveField(10)
  final DateTime createdAt;
  @HiveField(11)
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Convert to JSON
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
        createdAt,
        updatedAt,
      ];
}
