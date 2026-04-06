import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/india_locations.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/core/di/service_locator.dart';
import 'package:paw_around/repositories/user_repository.dart';
import 'package:paw_around/router/app_router.dart';
import 'package:paw_around/ui/auth/widgets/location_search_sheet.dart';
import 'package:paw_around/ui/widgets/common_button.dart';

class UserProfileSetupScreen extends StatefulWidget {
  const UserProfileSetupScreen({super.key});

  @override
  State<UserProfileSetupScreen> createState() => _UserProfileSetupScreenState();
}

class _UserProfileSetupScreenState extends State<UserProfileSetupScreen> {
  final _nameController = TextEditingController();
  String? _selectedState;
  String? _selectedCity;
  bool _isSaving = false;
  int _currentStep = 1;
  XFile? _profileImage;

  bool get _isStep1Valid =>
      _nameController.text.trim().isNotEmpty &&
      _selectedState != null &&
      _selectedCity != null;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickState() async {
    final result = await LocationSearchSheet.show(
      context,
      title: AppStrings.stateLabel,
      items: IndiaLocations.states,
      selected: _selectedState,
    );
    if (result != null && result != _selectedState) {
      setState(() {
        _selectedState = result;
        _selectedCity = null;
      });
    }
  }

  Future<void> _pickCity() async {
    if (_selectedState == null) return;
    final result = await LocationSearchSheet.show(
      context,
      title: AppStrings.cityLabel,
      items: IndiaLocations.citiesForState(_selectedState!),
      selected: _selectedCity,
    );
    if (result != null) setState(() => _selectedCity = result);
  }

  Future<void> _saveStep1() async {
    if (!_isStep1Valid || _isSaving) return;
    setState(() => _isSaving = true);
    try {
      await sl<UserRepository>().saveProfile(
        name: _nameController.text.trim(),
        state: _selectedState!,
        city: _selectedCity!,
      );
      if (mounted)
        setState(() {
          _isSaving = false;
          _currentStep = 1;
        });
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 800,
    );
    if (picked != null) setState(() => _profileImage = picked);
  }

  Future<void> _finishWithPhoto() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      if (_profileImage != null) {
        await sl<UserRepository>()
            .uploadProfilePhoto(File(_profileImage!.path));
      }
      AppRouter.setProfileComplete(true);
      if (mounted) context.go(AppRoutes.home);
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    }
  }

  void _skipPhoto() {
    AppRouter.setProfileComplete(true);
    context.go(AppRoutes.home);
  }

  void _handleBack() {
    if (_currentStep == 1) {
      setState(() => _currentStep = 0);
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _handleBack,
                child: const Icon(Icons.arrow_back,
                    size: 24, color: AppColors.grey1000),
              ),
              const SizedBox(height: 20),
              _StepIndicator(current: _currentStep, total: 2),
              const SizedBox(height: 24),
              if (_currentStep == 0) ...[
                _Step1Content(
                  nameController: _nameController,
                  selectedState: _selectedState,
                  selectedCity: _selectedCity,
                  onPickState: _pickState,
                  onPickCity: _selectedState != null ? _pickCity : null,
                ),
                const Spacer(),
                CommonButton(
                  text: AppStrings.nextButton,
                  onPressed: _isStep1Valid && !_isSaving ? _saveStep1 : null,
                  isLoading: _isSaving,
                  textStyle: AppTextStyles.interBoldStyle700(
                    fontColor: _isStep1Valid && !_isSaving
                        ? AppColors.black
                        : AppColors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),
              ] else ...[
                _Step2Content(
                  profileImage: _profileImage,
                  onPickPhoto: _pickPhoto,
                  isSaving: _isSaving,
                  onSkip: _skipPhoto,
                  onContinue: _finishWithPhoto,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Step1Content extends StatelessWidget {
  final TextEditingController nameController;
  final String? selectedState;
  final String? selectedCity;
  final VoidCallback onPickState;
  final VoidCallback? onPickCity;

  const _Step1Content({
    required this.nameController,
    required this.selectedState,
    required this.selectedCity,
    required this.onPickState,
    required this.onPickCity,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.profileSetupTitle,
          style: AppTextStyles.boldStyle700(
              fontSize: 24, fontColor: AppColors.grey1000),
        ),
        const SizedBox(height: 36),
        const _FieldLabel(AppStrings.fullName),
        const SizedBox(height: 8),
        _NameField(controller: nameController),
        const SizedBox(height: 20),
        const _FieldLabel(AppStrings.stateLabel),
        const SizedBox(height: 8),
        _LocationButton(
          hint: AppStrings.searchOrSelectState,
          value: selectedState,
          onTap: onPickState,
        ),
        const SizedBox(height: 20),
        const _FieldLabel(AppStrings.cityLabel),
        const SizedBox(height: 8),
        _LocationButton(
          hint: selectedState == null
              ? AppStrings.selectStateFirst
              : AppStrings.searchOrSelectCity,
          value: selectedCity,
          onTap: onPickCity,
        ),
      ],
    );
  }
}

class _Step2Content extends StatelessWidget {
  final XFile? profileImage;
  final VoidCallback onPickPhoto;
  final bool isSaving;
  final VoidCallback onSkip;
  final VoidCallback onContinue;

  const _Step2Content({
    required this.profileImage,
    required this.onPickPhoto,
    required this.isSaving,
    required this.onSkip,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhoto = profileImage != null;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.profilePhotoTitle,
            style: AppTextStyles.boldStyle700(
                fontSize: 24, fontColor: AppColors.grey1000),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.profilePhotoSubtitle,
            style: AppTextStyles.interMediumStyle500(
              fontSize: 16,
              fontColor: AppColors.grey700,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: GestureDetector(
              onTap: onPickPhoto,
              child: _PhotoPickerBox(
                imageFile:
                    profileImage != null ? File(profileImage!.path) : null,
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (hasPhoto)
            CommonButton(
              text: AppStrings.nextButton,
              onPressed: isSaving ? null : onContinue,
              isLoading: isSaving,
              textStyle: AppTextStyles.interBoldStyle700(
                fontColor: AppColors.black,
                fontSize: 16,
              ),
            )
          else
            CommonButton(
              text: AppStrings.skipForNow,
              onPressed: isSaving ? null : onSkip,
              variant: ButtonVariant.outline,
              customColor: AppColors.secondaryCTA,
              textStyle: AppTextStyles.interBoldStyle700(
                fontColor: AppColors.secondaryCTA,
                fontSize: 16,
              ),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _PhotoPickerBox extends StatelessWidget {
  final File? imageFile;
  const _PhotoPickerBox({this.imageFile});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(color: AppColors.white),
          child: imageFile != null
              ? Image.file(imageFile!, fit: BoxFit.cover)
              : const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo_outlined,
                        size: 52, color: AppColors.neutral300),
                    SizedBox(height: 12),
                    Text(
                      AppStrings.addPhoto,
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const radius = 20.0;
    const dashWidth = 8.0;
    const dashSpace = 6.0;
    final paint = Paint()
      ..color = AppColors.neutral300
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(radius),
      ));

    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      double distance = 0;
      while (distance < metric.length) {
        final next = math.min(distance + dashWidth, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) => false;
}

class _NameField extends StatelessWidget {
  final TextEditingController controller;
  const _NameField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textCapitalization: TextCapitalization.words,
      style: AppTextStyles.regularStyle400(
          fontSize: 16, fontColor: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: AppStrings.enterFullName,
        hintStyle:
            AppTextStyles.regularStyle400(fontColor: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.neutral300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.neutral300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.neutral300, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: text,
            style: AppTextStyles.interRegularStyle400(
                fontSize: 14, fontColor: AppColors.grey1000),
          ),
          TextSpan(
            text: ' *',
            style: AppTextStyles.interRegularStyle400(
                fontSize: 14, fontColor: AppColors.grey1000),
          ),
        ],
      ),
    );
  }
}

class _LocationButton extends StatelessWidget {
  final String hint;
  final String? value;
  final VoidCallback? onTap;

  const _LocationButton({
    required this.hint,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDisabled
                ? AppColors.border.withValues(alpha: 0.5)
                : AppColors.neutral300,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value ?? hint,
                style: AppTextStyles.regularStyle400(
                  fontSize: 16,
                  fontColor: value != null
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: isDisabled ? AppColors.border : AppColors.textSecondary,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int current;
  final int total;

  const _StepIndicator({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final isActive = i == current;
        return Container(
          margin: const EdgeInsets.only(right: 6),
          width: isActive ? 32 : 24,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.border,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
