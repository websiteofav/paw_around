import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/models/pets/action_type.dart';
import 'package:paw_around/models/pets/action_timeline_entry.dart';

/// Extension methods for String
extension StringExtension on String? {
  /// Returns true if the string is not null and not empty (after trimming)
  bool get isValidString {
    return this != null && this!.trim().isNotEmpty;
  }

  /// Returns the string if valid, otherwise returns the fallback value
  String orDefault(String? fallback) {
    return isValidString ? this! : fallback ?? '';
  }
}

/// Extension methods for List
extension ListExtension<T> on List<T>? {
  /// Returns true if the list is not null and not empty
  bool get isValidList {
    return this != null && this!.isNotEmpty;
  }

  /// Returns the list if valid, otherwise returns an empty list
  List<T> orEmpty() {
    return isValidList ? this! : [];
  }
}

/// Pet timeline utility functions
class PetTimelineUtils {
  PetTimelineUtils._();

  /// Build timeline entries grouped by action type with optional filters
  static Map<ActionType, List<ActionTimelineEntry>> buildGroupedTimeline({
    required PetModel pet,
    ActionType? filterByActionType,
    String? filterByVaccineName,
  }) {
    final Map<ActionType, List<ActionTimelineEntry>> grouped = {};

    // Group Vaccines
    // Show vaccines if: no filter, filter is for vaccines, or vaccine name filter is provided
    if (filterByActionType == null ||
        filterByActionType == ActionType.vaccine ||
        filterByVaccineName != null) {
      final vaccineEntries = <ActionTimelineEntry>[];
      for (final vaccine in pet.vaccines) {
        if (filterByVaccineName != null &&
            vaccine.vaccineName != filterByVaccineName) {
          continue;
        }

        // Use all completionHistory entries instead of just dateGiven
        for (final completionDate in vaccine.completionHistory) {
          vaccineEntries.add(ActionTimelineEntry(
            id: 'vaccine_${vaccine.id}_${completionDate.millisecondsSinceEpoch}',
            actionName: vaccine.vaccineName,
            date: completionDate,
            status: TimelineEntryStatus.completed,
            actionType: ActionType.vaccine,
          ));
        }
      }
      // Sort vaccines by date (most recent first)
      vaccineEntries.sort((a, b) {
        if (a.date == null) return 1;
        if (b.date == null) return -1;
        return b.date!.compareTo(a.date!);
      });
      if (vaccineEntries.isNotEmpty) {
        grouped[ActionType.vaccine] = vaccineEntries;
      }
    }

    // Group Grooming
    // Only show if no filter or filter is specifically for grooming
    // Don't show if vaccine name filter is provided (viewing specific vaccine)
    if ((filterByActionType == null ||
            filterByActionType == ActionType.grooming) &&
        filterByVaccineName == null) {
      final groomingEntries = <ActionTimelineEntry>[];
      if (pet.groomingSettings != null) {
        for (final completionDate in pet.groomingSettings!.completionHistory) {
          groomingEntries.add(ActionTimelineEntry(
            id: 'grooming_${pet.id}_${completionDate.millisecondsSinceEpoch}',
            actionName: AppStrings.grooming,
            date: completionDate,
            status: TimelineEntryStatus.completed,
            actionType: ActionType.grooming,
          ));
        }
        if (pet.groomingSettings!.isSnoozed) {
          groomingEntries.add(ActionTimelineEntry(
            id: 'grooming_skipped_${pet.id}',
            actionName: AppStrings.grooming,
            status: TimelineEntryStatus.skipped,
            actionType: ActionType.grooming,
          ));
        }
      }
      if (groomingEntries.isNotEmpty) {
        grouped[ActionType.grooming] = groomingEntries;
      }
    }

    // Group Tick & Flea
    // Only show if no filter or filter is specifically for tick & flea
    // Don't show if vaccine name filter is provided (viewing specific vaccine)
    if ((filterByActionType == null ||
            filterByActionType == ActionType.tickFlea) &&
        filterByVaccineName == null) {
      final tickFleaEntries = <ActionTimelineEntry>[];
      if (pet.tickFleaSettings != null) {
        for (final completionDate in pet.tickFleaSettings!.completionHistory) {
          tickFleaEntries.add(ActionTimelineEntry(
            id: 'tickFlea_${pet.id}_${completionDate.millisecondsSinceEpoch}',
            actionName: AppStrings.tickFleaPrevention,
            date: completionDate,
            status: TimelineEntryStatus.completed,
            actionType: ActionType.tickFlea,
          ));
        }
        if (pet.tickFleaSettings!.isSnoozed) {
          tickFleaEntries.add(ActionTimelineEntry(
            id: 'tickFlea_skipped_${pet.id}',
            actionName: AppStrings.tickFleaPrevention,
            status: TimelineEntryStatus.skipped,
            actionType: ActionType.tickFlea,
          ));
        }
      }
      if (tickFleaEntries.isNotEmpty) {
        grouped[ActionType.tickFlea] = tickFleaEntries;
      }
    }

    return grouped;
  }
}
