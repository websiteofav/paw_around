import 'package:equatable/equatable.dart';

/// Represents predefined vaccine data from master list
/// Users cannot add custom vaccines - only select from this list
class VaccineMasterData extends Equatable {
  final String id;
  final String name;
  final String petType;
  final String category;
  final int frequencyMonths;
  final String why;
  final String whatToDo;
  final String ctaType;

  const VaccineMasterData({
    required this.id,
    required this.name,
    required this.petType,
    required this.category,
    required this.frequencyMonths,
    required this.why,
    required this.whatToDo,
    required this.ctaType,
  });

  /// Returns helper text based on category
  String get helperText {
    switch (category) {
      case 'mandatory':
        return 'Required by law';
      case 'core':
        return 'Core vaccine';
      default:
        return 'Recommended';
    }
  }

  /// Calculate next due date from a given date
  DateTime calculateNextDueDate(DateTime lastGivenDate) {
    return DateTime(
      lastGivenDate.year,
      lastGivenDate.month + frequencyMonths,
      lastGivenDate.day,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        petType,
        category,
        frequencyMonths,
        why,
        whatToDo,
        ctaType,
      ];
}
