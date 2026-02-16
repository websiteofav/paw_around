import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_spacing.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/repositories/public_pet_repository.dart';
import 'package:paw_around/web/widgets/public_pet/emergency_card.dart';
import 'package:paw_around/web/widgets/public_pet/found_pet_section.dart';
import 'package:paw_around/web/widgets/public_pet/info_card.dart';
import 'package:paw_around/web/widgets/public_pet/owner_card.dart';
import 'package:paw_around/web/widgets/public_pet/pet_hero_section.dart';
import 'package:paw_around/web/widgets/public_pet/public_footer.dart';
import 'package:paw_around/web/widgets/public_pet/public_top_bar.dart';

class PublicPetPage extends StatefulWidget {
  final String petPublicId;

  const PublicPetPage({super.key, required this.petPublicId});

  @override
  State<PublicPetPage> createState() => _PublicPetPageState();
}

class _PublicPetPageState extends State<PublicPetPage> {
  final _repository = PublicPetRepository();
  PetModel? _pet;
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _loadPet();
  }

  Future<void> _loadPet() async {
    setState(() {
      _loading = true;
      _error = false;
    });
    final pet = await _repository.getByPublicId(widget.petPublicId);
    if (mounted) {
      setState(() {
        _pet = pet;
        _loading = false;
        _error = pet == null && widget.petPublicId.isNotEmpty;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width > 900;
    final padding = EdgeInsets.symmetric(
      horizontal: isWide ? 24 : 16,
      vertical: 16,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const PublicPetTopBar(),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : _error || _pet == null
                    ? Center(
                        child: Text(
                          AppStrings.petNotFound,
                          style: AppTextStyles.regularStyle400(
                            fontSize: 18,
                            fontColor: AppColors.textSecondary,
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        padding: padding,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AppSpacing.vertical32,
                            PublicPetHeroSection(
                              pet: _pet!,
                              isWideLayout: isWide,
                              ownerPhone: '+919876543210',
                              ownerWhatsApp: null,
                              lastSeenAt: _pet!.isLost
                                  ? DateTime.now()
                                      .subtract(const Duration(hours: 12))
                                  : null,
                              lastSeenLocation:
                                  _pet!.isLost ? 'Central Park' : null,
                            ),
                            AppSpacing.vertical24,
                            if (isWide)
                              _buildWideCards()
                            else
                              _buildNarrowCards(),
                            AppSpacing.vertical32,
                            const PublicPetFooter(),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildWideCards() {
    final basicRows = _basicInfoRows(_pet!);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              PublicPetInfoCard(title: AppStrings.basicInfo, rows: basicRows),
              AppSpacing.vertical20,
              PublicPetEmergencyCard(pet: _pet!),
            ],
          ),
        ),
        AppSpacing.horizontal20,
        Expanded(
          child: Column(
            children: [
              PublicPetOwnerCard(
                ownerName: 'John Doe',
                ownerPhone: '+91 98765 43210',
                alternatePhone: null,
              ),
              AppSpacing.vertical20,
              PublicPetFoundSection(pet: _pet!),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowCards() {
    final basicRows = _basicInfoRows(_pet!);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PublicPetInfoCard(title: AppStrings.basicInfo, rows: basicRows),
        AppSpacing.vertical20,
        PublicPetEmergencyCard(pet: _pet!),
        AppSpacing.vertical20,
        PublicPetOwnerCard(
          ownerName: 'John Doe',
          ownerPhone: '+91 98765 43210',
          alternatePhone: null,
        ),
        AppSpacing.vertical20,
        PublicPetFoundSection(pet: _pet!),
      ],
    );
  }

  List<PublicPetInfoRow> _basicInfoRows(PetModel pet) {
    final vaccinationText = pet.overdueVaccines.isNotEmpty
        ? AppStrings.overdue
        : (pet.upcomingVaccines.isNotEmpty
            ? '${pet.upcomingVaccines.first.vaccineName}'
            : AppStrings.vaccinationUpToDate);
    return [
      PublicPetInfoRow(
        icon: pet.gender.toLowerCase() == 'female' ? Icons.female : Icons.male,
        value: pet.gender,
      ),
      PublicPetInfoRow(
        icon: Icons.monitor_weight_outlined,
        value: '${pet.weight.toInt()} kg',
      ),
      PublicPetInfoRow(icon: Icons.pets, value: pet.species),
      PublicPetInfoRow(
        icon: Icons.medical_services_outlined,
        value: vaccinationText,
      ),
    ];
  }
}
