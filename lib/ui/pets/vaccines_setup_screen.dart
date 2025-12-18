import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_bloc.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_event.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/vaccine_constants.dart';
import 'package:paw_around/core/di/service_locator.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/models/vaccines/vaccine_master_data.dart';
import 'package:paw_around/models/vaccines/vaccine_model.dart';
import 'package:paw_around/repositories/pet_repository.dart';
import 'package:paw_around/ui/pets/widgets/care_app_bar.dart';
import 'package:paw_around/ui/pets/widgets/vaccine_card.dart';
import 'package:paw_around/ui/pets/widgets/vaccine_date_bottom_sheet.dart';

class VaccinesSetupScreen extends StatefulWidget {
  final PetModel pet;

  const VaccinesSetupScreen({
    super.key,
    required this.pet,
  });

  @override
  State<VaccinesSetupScreen> createState() => _VaccinesSetupScreenState();
}

class _VaccinesSetupScreenState extends State<VaccinesSetupScreen> {
  late PetModel _currentPet;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _currentPet = widget.pet;

    // Check if pet type supports vaccines
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!VaccineConstants.supportsVaccines(_currentPet.species)) {
        _showUnsupportedMessage();
      }
    });
  }

  void _showUnsupportedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(AppStrings.vaccinesForDogsCatsOnly),
        backgroundColor: AppColors.textSecondary,
      ),
    );
    context.pop();
  }

  List<VaccineMasterData> get _vaccines {
    return VaccineConstants.getVaccinesByPetType(_currentPet.species);
  }

  VaccineModel? _getExistingVaccine(VaccineMasterData masterData) {
    try {
      return _currentPet.vaccines.firstWhere(
        (v) => v.vaccineName.toLowerCase() == masterData.name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> _handleVaccineTap(VaccineMasterData masterData) async {
    final existingVaccine = _getExistingVaccine(masterData);

    await VaccineDateBottomSheet.show(
      context: context,
      masterData: masterData,
      existingVaccine: existingVaccine,
      onSave: (lastGivenDate, nextDueDate) async {
        await _saveVaccine(masterData, existingVaccine, lastGivenDate, nextDueDate);
      },
    );
  }

  Future<void> _saveVaccine(
    VaccineMasterData masterData,
    VaccineModel? existingVaccine,
    DateTime lastGivenDate,
    DateTime nextDueDate,
  ) async {
    if (_isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      VaccineModel vaccine;

      if (existingVaccine != null) {
        // Update existing vaccine
        vaccine = existingVaccine.copyWith(
          dateGiven: lastGivenDate,
          nextDueDate: nextDueDate,
          updatedAt: DateTime.now(),
        );
      } else {
        // Create new vaccine
        vaccine = VaccineModel.create(
          vaccineName: masterData.name,
          dateGiven: lastGivenDate,
          nextDueDate: nextDueDate,
          notes: '',
          setReminder: true,
        );
      }

      // Update via repository
      await sl<PetRepository>().updateVaccine(_currentPet.id, vaccine);

      // Update local state
      final updatedVaccines = List<VaccineModel>.from(_currentPet.vaccines);
      final existingIndex = updatedVaccines.indexWhere(
        (v) => v.vaccineName.toLowerCase() == masterData.name.toLowerCase(),
      );

      if (existingIndex >= 0) {
        updatedVaccines[existingIndex] = vaccine;
      } else {
        updatedVaccines.add(vaccine);
      }

      setState(() {
        _currentPet = _currentPet.copyWith(vaccines: updatedVaccines);
      });

      // Reload pet list
      if (mounted) {
        context.read<PetListBloc>().add(const LoadPetList());

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.vaccineSaved),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Don't show screen for unsupported pet types
    if (!VaccineConstants.supportsVaccines(_currentPet.species)) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Custom App Bar
          CareAppBar(
            pet: _currentPet,
            screenTitle: AppStrings.vaccines,
          ),

          // Vaccine list
          Expanded(
            child: _vaccines.isEmpty ? _buildEmptyState() : _buildVaccineList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.vaccines_outlined,
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No vaccines available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.vaccinesForDogsCatsOnly,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVaccineList() {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section header
              const Text(
                'Required Vaccines',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),

              // Vaccine cards
              ..._vaccines.map((masterData) {
                final existingVaccine = _getExistingVaccine(masterData);
                return VaccineCard(
                  masterData: masterData,
                  existingVaccine: existingVaccine,
                  onTap: () => _handleVaccineTap(masterData),
                );
              }),

              const SizedBox(height: 32),
            ],
          ),
        ),

        // Loading overlay
        if (_isSaving)
          Container(
            color: Colors.black26,
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ),
      ],
    );
  }
}
