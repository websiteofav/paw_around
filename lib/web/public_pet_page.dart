import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_spacing.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/models/public_pet/public_pet_profile.dart';
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
  PublicPetProfile? _profile;
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
    final profile = await _repository.getByPublicId(widget.petPublicId);
    if (mounted) {
      setState(() {
        _profile = profile;
        _loading = false;
        _error = profile == null && widget.petPublicId.isNotEmpty;
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
                : _error || _profile == null
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
                              pet: _profile!.pet,
                              isWideLayout: isWide,
                              ownerPhone: _profile!.owner?.primaryPhone,
                              ownerWhatsApp: null,
                              lastSeenAt: _profile!.lastSeen?.at,
                              lastSeenLocation: _profile!.lastSeen?.location,
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
    final basicRows = _basicInfoRows(_profile!.pet);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              PublicPetInfoCard(title: AppStrings.basicInfo, rows: basicRows),
              AppSpacing.vertical20,
              PublicPetEmergencyCard(pet: _profile!.pet),
            ],
          ),
        ),
        AppSpacing.horizontal20,
        Expanded(
          child: Column(
            children: [
              PublicPetOwnerCard(
                ownerName: _profile!.owner?.name,
                ownerPhone: _profile!.owner?.primaryPhone,
                alternatePhone: null,
              ),
              AppSpacing.vertical20,
              PublicPetFoundSection(pet: _profile!.pet),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowCards() {
    final basicRows = _basicInfoRows(_profile!.pet);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PublicPetInfoCard(title: AppStrings.basicInfo, rows: basicRows),
        AppSpacing.vertical20,
        PublicPetEmergencyCard(pet: _profile!.pet),
        AppSpacing.vertical20,
        PublicPetOwnerCard(
          ownerName: _profile!.owner?.name,
          ownerPhone: _profile!.owner?.primaryPhone,
          alternatePhone: null,
        ),
        AppSpacing.vertical20,
        PublicPetFoundSection(pet: _profile!.pet),
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
