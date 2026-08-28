import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_bloc.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_event.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_icons.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/constants/vaccine_constants.dart';
import 'package:paw_around/core/di/service_locator.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/models/vaccines/vaccine_master_data.dart';
import 'package:paw_around/models/vaccines/vaccine_model.dart';
import 'package:paw_around/repositories/pet_repository.dart';
import 'package:paw_around/ui/pets/widgets/vaccine_actions.dart';
import 'package:paw_around/ui/pets/widgets/vaccine_date_field.dart';
import 'package:paw_around/ui/pets/widgets/vaccine_form_helper.dart';
import 'package:paw_around/ui/pets/widgets/vaccine_notes_field.dart';
import 'package:paw_around/ui/pets/widgets/vaccine_reminder_card.dart';
import 'package:paw_around/ui/pets/widgets/vaccine_selector_field.dart';
import 'package:paw_around/ui/pets/widgets/vaccine_snooze_banner.dart';
import 'package:paw_around/ui/widgets/common_button.dart';

class AddVaccineScreen extends StatefulWidget {
  final PetModel? pet;
  final VaccineModel? vaccineToEdit;
  const AddVaccineScreen({super.key, this.pet, this.vaccineToEdit});

  @override
  State<AddVaccineScreen> createState() => _AddVaccineScreenState();
}

class _AddVaccineScreenState extends State<AddVaccineScreen> {
  final _notesCtrl = TextEditingController();
  final _customNameCtrl = TextEditingController();
  VaccineMasterData? _selectedVaccine;
  bool _isOtherSelected = false;
  DateTime? _dateGiven;
  DateTime? _nextDueDate;
  bool _setReminder = true;
  final Map<String, String> _errors = {};
  bool _isEditMode = false;
  bool _isSaving = false;
  bool _isSnoozed = false;
  bool _isUnsnoozeing = false;

  List<VaccineMasterData> get _available {
    final all = widget.pet != null
        ? VaccineConstants.getVaccinesByPetType(widget.pet!.species)
        : [...VaccineConstants.dogVaccines, ...VaccineConstants.catVaccines];
    final seen = <String>{};
    return all.where((v) => seen.add(v.id)).toList();
  }

  List<VaccineMasterData> get _required => _available
      .where((v) => v.category == 'mandatory' || v.category == 'core')
      .toList()
    ..sort((a, b) {
      if (a.category == 'mandatory' && b.category != 'mandatory') return -1;
      if (a.category != 'mandatory' && b.category == 'mandatory') return 1;
      return a.name.compareTo(b.name);
    });

  List<VaccineMasterData> get _recommended => _available
      .where((v) => v.category == 'recommended' || v.category == 'optional')
      .toList()
    ..sort((a, b) => a.name.compareTo(b.name));

  @override
  void initState() {
    super.initState();
    final v = widget.vaccineToEdit;
    if (v == null) return;
    _isEditMode = true;
    try {
      _selectedVaccine = _available.firstWhere(
          (x) => x.name.toLowerCase() == v.vaccineName.toLowerCase());
    } catch (_) {
      _isOtherSelected = true;
      _customNameCtrl.text = v.vaccineName;
    }
    _dateGiven = v.dateGiven;
    _nextDueDate = v.nextDueDate;
    _notesCtrl.text = v.notes;
    _setReminder = v.setReminder;
    _isSnoozed = v.isSnoozed;
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    _customNameCtrl.dispose();
    super.dispose();
  }

  void _onVaccineSelected(VaccineMasterData? v) => setState(() {
        _selectedVaccine = v;
        _isOtherSelected = false;
        _customNameCtrl.clear();
        _errors.remove('vaccineName');
        _errors.remove('customVaccineName');
        if (_dateGiven != null && v != null)
          _nextDueDate = v.calculateNextDueDate(_dateGiven!);
      });

  void _onOtherSelected() => setState(() {
        _selectedVaccine = null;
        _isOtherSelected = true;
        _errors.remove('vaccineName');
      });

  void _onDateGiven(DateTime date) => setState(() {
        _dateGiven = date;
        _errors.remove('dateGiven');
        if (_selectedVaccine != null) {
          _nextDueDate = _selectedVaccine!.calculateNextDueDate(date);
          _errors.remove('nextDueDate');
        }
      });

  Future<void> _save() async {
    final valid = VaccineFormHelper.validate(
      selectedVaccine: _selectedVaccine,
      isOtherSelected: _isOtherSelected,
      customName: _customNameCtrl.text,
      dateGiven: _dateGiven,
      nextDueDate: _nextDueDate,
      setReminder: _setReminder,
      errors: _errors,
    );
    setState(() {});
    if (!valid || widget.pet == null) return;
    setState(() => _isSaving = true);
    try {
      final name = _isOtherSelected
          ? _customNameCtrl.text.trim()
          : _selectedVaccine!.name;
      final vaccine = _isEditMode && widget.vaccineToEdit != null
          ? VaccineFormHelper.buildEdited(
              old: widget.vaccineToEdit!,
              name: name,
              dateGiven: _dateGiven!,
              nextDueDate: _nextDueDate,
              setReminder: _setReminder,
              notes: _notesCtrl.text)
          : VaccineModel.create(
              vaccineName: name,
              dateGiven: _dateGiven!,
              nextDueDate: _setReminder ? _nextDueDate : null,
              notes: _notesCtrl.text,
              setReminder: _setReminder);
      await sl<PetRepository>().updateVaccine(widget.pet!.id, vaccine);
      if (!mounted) {
        return;
      }
      await VaccineFormHelper.scheduleOrCancel(
          context: context,
          pet: widget.pet!,
          vaccine: vaccine,
          setReminder: _setReminder);
      if (!mounted) return;
      context.read<PetListBloc>().add(const LoadPetList());
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_isEditMode
            ? AppStrings.vaccineSaved
            : AppStrings.vaccineAddedSuccessfully),
        backgroundColor: AppColors.success,
      ));
      context.pop(vaccine);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(e.toString()), backgroundColor: AppColors.error));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _unsnooze() => VaccineFormHelper.unsnooze(
        context: context,
        pet: widget.pet!,
        vaccine: widget.vaccineToEdit!,
        onStart: () => setState(() => _isUnsnoozeing = true),
        onSuccess: () => setState(() {
          _isSnoozed = false;
          _isUnsnoozeing = false;
        }),
        onError: () => setState(() => _isUnsnoozeing = false),
      );

  Future<DateTime?> _pickDate(
          {required DateTime initial, DateTime? first, DateTime? last}) =>
      showDatePicker(
        context: context,
        initialDate: initial,
        firstDate: first ?? DateTime(2000),
        lastDate: last ?? DateTime.now(),
        builder: (ctx, child) => Theme(
          data: Theme.of(ctx).copyWith(
              colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: AppColors.white,
            surface: AppColors.surface,
            onSurface: AppColors.textPrimary,
          )),
          child: child!,
        ),
      );

  Widget _buildHero() {
    return SvgPicture.asset(
      AppIcons.syringIcon,
      height: 64,
      width: 64,
      colorFilter: const ColorFilter.mode(AppColors.grey150, BlendMode.srcIn),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(children: [
            if (_isEditMode && _isSnoozed && widget.vaccineToEdit != null)
              VaccineSnoozeBanner(
                  vaccine: widget.vaccineToEdit!,
                  isUnsnoozeing: _isUnsnoozeing,
                  onUnsnooze: _unsnooze),
            const SizedBox(height: 28),
            Row(
              children: [
                GestureDetector(
                  onTap: () => context.canPop()
                      ? context.pop()
                      : context.pushNamed(AppRoutes.home),
                  child: const Icon(Icons.arrow_back,
                      size: 24, color: AppColors.grey1000),
                ),
                const SizedBox(width: 12),
                Text(
                  widget.vaccineToEdit != null
                      ? AppStrings.editVaccine
                      : AppStrings.addVaccine,
                  style: AppTextStyles.boldStyle700(
                      fontSize: 18, fontColor: AppColors.grey1000),
                ),
              ],
            ),
            const SizedBox(height: 28),
            _buildHero(),
            const SizedBox(height: 36),
            VaccineSelectorField(
              selectedVaccine: _selectedVaccine,
              isOtherSelected: _isOtherSelected,
              customVaccineNameController: _customNameCtrl,
              errors: _errors,
              isSaving: _isSaving,
              requiredCoreVaccines: _required,
              recommendedVaccines: _recommended,
              onVaccineSelected: _onVaccineSelected,
              onOtherSelected: _onOtherSelected,
            ),
            const SizedBox(height: 16),
            VaccineDateField(
                label: AppStrings.dateGiven,
                selectedDate: _dateGiven,
                error: _errors['dateGiven'],
                onTap: () async {
                  final d = await _pickDate(
                      initial: _dateGiven ?? DateTime.now(),
                      last: DateTime.now());
                  if (d != null) _onDateGiven(d);
                }),
            const SizedBox(height: 16),
            VaccineDateField(
                label: AppStrings.nextDueDate,
                selectedDate: _nextDueDate,
                error: _errors['nextDueDate'],
                helperText: _selectedVaccine != null
                    ? AppStrings.autoCalculatedHelperText
                    : null,
                visible: _setReminder,
                onTap: () async {
                  final now = DateTime.now();
                  final d = await _pickDate(
                      initial: _nextDueDate?.isAfter(now) == true
                          ? _nextDueDate!
                          : now.add(const Duration(days: 30)),
                      first: now,
                      last: now.add(const Duration(days: 3650)));
                  if (d != null) {
                    setState(() {
                      _nextDueDate = d;
                      _errors.remove('nextDueDate');
                    });
                  }
                }),
            const SizedBox(height: 16),
            VaccineNotesField(controller: _notesCtrl),
            const SizedBox(height: 24),
            VaccineReminderCard(
                setReminder: _setReminder,
                onChanged: (v) => setState(() => _setReminder = v)),
            const SizedBox(height: 32),
            CommonButton(
                text: AppStrings.saveVaccine,
                onPressed: _isSaving ? null : _save,
                variant: ButtonVariant.primary,
                textStyle: AppTextStyles.interBoldStyle700(
                  fontSize: 16,
                  fontColor: AppColors.grey1000,
                ),
                isLoading: _isSaving),
            if (_isEditMode && widget.vaccineToEdit != null) ...[
              const SizedBox(height: 12),
              CommonButton(
                  text: AppStrings.deleteVaccine,
                  variant: ButtonVariant.danger,
                  onPressed: _isSaving
                      ? null
                      : () => VaccineActions.showDeleteConfirmation(
                          context, widget.pet!, widget.vaccineToEdit!)),
            ],
            const SizedBox(height: 24),
          ]),
        ),
      ),
    );
  }
}
