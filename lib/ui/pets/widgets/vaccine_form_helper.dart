import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_bloc.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_event.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/core/di/service_locator.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/models/vaccines/vaccine_master_data.dart';
import 'package:paw_around/models/vaccines/vaccine_model.dart';
import 'package:paw_around/repositories/pet_repository.dart';
import 'package:paw_around/services/notification_service.dart';

class VaccineFormHelper {
  VaccineFormHelper._();

  static bool validate({
    required VaccineMasterData? selectedVaccine,
    required bool isOtherSelected,
    required String customName,
    required DateTime? dateGiven,
    required DateTime? nextDueDate,
    required bool setReminder,
    required Map<String, String> errors,
  }) {
    errors.clear();
    if (isOtherSelected) {
      if (customName.trim().isEmpty) errors['customVaccineName'] = AppStrings.pleaseEnterVaccineName;
    } else if (selectedVaccine == null) {
      errors['vaccineName'] = AppStrings.pleaseEnterVaccineName;
    }
    if (dateGiven == null) errors['dateGiven'] = AppStrings.pleaseSelectDateGiven;
    if (nextDueDate == null && setReminder) errors['nextDueDate'] = AppStrings.pleaseSelectNextDueDate;
    if (dateGiven != null && nextDueDate != null && nextDueDate.isBefore(dateGiven) && setReminder) {
      errors['nextDueDate'] = AppStrings.nextDueDateAfterDateGiven;
    }
    return errors.isEmpty;
  }

  static VaccineModel buildEdited({
    required VaccineModel old,
    required String name,
    required DateTime dateGiven,
    required DateTime? nextDueDate,
    required bool setReminder,
    required String notes,
  }) {
    List<DateTime> history = List.from(old.completionHistory);
    if (old.dateGiven.year != dateGiven.year ||
        old.dateGiven.month != dateGiven.month ||
        old.dateGiven.day != dateGiven.day) {
      history.sort((a, b) => b.compareTo(a));
      final i = history.indexWhere((d) =>
          d.year == old.dateGiven.year && d.month == old.dateGiven.month && d.day == old.dateGiven.day);
      if (i != -1) history.removeAt(i);
      history..add(dateGiven)..sort((a, b) => b.compareTo(a));
    }
    final interval = old.nextDueDate != null
        ? old.nextDueDate!.difference(old.dateGiven).inDays.clamp(0, 9999)
        : 0;
    final dueDateChanged = old.nextDueDate != null && nextDueDate != null &&
        old.nextDueDate!.difference(nextDueDate).inDays != 0;
    final nextDue = setReminder && interval > 0 && !dueDateChanged
        ? dateGiven.add(Duration(days: interval))
        : (setReminder ? nextDueDate : null);
    return old.copyWith(
      vaccineName: name, dateGiven: dateGiven, nextDueDate: nextDue,
      notes: notes, setReminder: setReminder,
      updatedAt: DateTime.now(), completionHistory: history,
    );
  }

  static Future<void> scheduleOrCancel({
    required BuildContext context,
    required PetModel pet,
    required VaccineModel vaccine,
    required bool setReminder,
  }) async {
    final svc = NotificationService();
    if (setReminder) {
      final ok = await svc.requestPermissionIfNeeded(context, pet.name, ReminderType.vaccine);
      if (ok) await svc.scheduleVaccineReminder(petId: pet.id, petName: pet.name, vaccine: vaccine);
    } else {
      await svc.cancelVaccineReminder(petId: pet.id, vaccineId: vaccine.id);
    }
  }

  static Future<void> unsnooze({
    required BuildContext context,
    required PetModel pet,
    required VaccineModel vaccine,
    required VoidCallback onStart,
    required VoidCallback onSuccess,
    required VoidCallback onError,
  }) async {
    onStart();
    try {
      await sl<PetRepository>().unsnoozeVaccine(pet.id, vaccine.id);
      if (context.mounted) {
        context.read<PetListBloc>().add(const LoadPetList());
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.reminderUnsnoozed), backgroundColor: AppColors.success));
        onSuccess();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
        onError();
      }
    }
  }
}
