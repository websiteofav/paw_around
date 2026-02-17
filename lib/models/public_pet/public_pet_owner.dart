import 'package:equatable/equatable.dart';

/// Owner info exposed on the public pet profile (name and primary phone only).
class PublicPetOwner extends Equatable {
  final String? name;
  final String? primaryPhone;

  const PublicPetOwner({
    this.name,
    this.primaryPhone,
  });

  static PublicPetOwner? fromMap(Map<String, dynamic>? map) {
    if (map == null || map.isEmpty) return null;
    return PublicPetOwner(
      name: map['name'] as String?,
      primaryPhone: map['primaryPhone'] as String?,
    );
  }

  @override
  List<Object?> get props => [name, primaryPhone];
}
