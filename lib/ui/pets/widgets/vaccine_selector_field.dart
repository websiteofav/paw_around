import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/models/vaccines/vaccine_master_data.dart';
import 'package:paw_around/ui/widgets/common_form_field.dart';

class VaccineSelectorField extends StatefulWidget {
  final VaccineMasterData? selectedVaccine;
  final bool isOtherSelected;
  final TextEditingController customVaccineNameController;
  final Map<String, String> errors;
  final bool isSaving;
  final List<VaccineMasterData> requiredCoreVaccines;
  final List<VaccineMasterData> recommendedVaccines;
  final ValueChanged<VaccineMasterData?> onVaccineSelected;
  final VoidCallback onOtherSelected;

  const VaccineSelectorField({
    super.key,
    required this.selectedVaccine,
    required this.isOtherSelected,
    required this.customVaccineNameController,
    required this.errors,
    required this.isSaving,
    required this.requiredCoreVaccines,
    required this.recommendedVaccines,
    required this.onVaccineSelected,
    required this.onOtherSelected,
  });

  @override
  State<VaccineSelectorField> createState() => _VaccineSelectorFieldState();
}

class _VaccineSelectorFieldState extends State<VaccineSelectorField> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _toggle() {
    if (_isOpen) {
      _close();
    } else {
      _open();
    }
  }

  void _open() {
    _removeOverlay();
    final renderBox = context.findRenderObject() as RenderBox;
    final fieldHeight = renderBox.size.height;
    final fieldWidth = renderBox.size.width;

    _overlayEntry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _close,
            ),
          ),
          Positioned(
            width: fieldWidth,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0, fieldHeight + 4),
              child: _DropdownSheet(
                requiredCoreVaccines: widget.requiredCoreVaccines,
                recommendedVaccines: widget.recommendedVaccines,
                selectedVaccine: widget.selectedVaccine,
                isOtherSelected: widget.isOtherSelected,
                onSelected: (v) {
                  _close();
                  widget.onVaccineSelected(v);
                },
                onOtherSelected: () {
                  _close();
                  widget.onOtherSelected();
                },
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isOpen = true);
  }

  void _close() {
    _removeOverlay();
    if (mounted) setState(() => _isOpen = false);
  }

  bool get _hasError =>
      widget.errors['vaccineName'] != null ||
      widget.errors['customVaccineName'] != null;

  String get _displayText {
    if (widget.isOtherSelected) {
      return widget.customVaccineNameController.text.isNotEmpty
          ? widget.customVaccineNameController.text
          : AppStrings.otherVaccine;
    }
    return widget.selectedVaccine?.name ?? AppStrings.selectVaccine;
  }

  bool get _hasSelection =>
      widget.selectedVaccine != null || widget.isOtherSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text(
            AppStrings.vaccineName,
            style: AppTextStyles.interRegularStyle400(
                fontSize: 14, fontColor: AppColors.grey1000),
          ),
          const SizedBox(width: 4),
          Text(
            '*',
            style: AppTextStyles.interRegularStyle400(
                fontSize: 14, fontColor: AppColors.grey1000),
          ),
        ]),
        const SizedBox(height: 8),
        CompositedTransformTarget(
          link: _layerLink,
          child: GestureDetector(
            onTap: _toggle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: smoothDecoration(
                cornerRadius: 14,
                color: AppColors.surface,
                side: BorderSide(
                  color: _hasError
                      ? AppColors.error
                      : _isOpen
                          ? AppColors.primary
                          : AppColors.neutral300,
                  width: _isOpen && !_hasError ? 2 : 1,
                ),
              ),
              child: Row(children: [
                Expanded(
                  child: Text(
                    _displayText,
                    style: AppTextStyles.regularStyle400(
                      fontSize: 16,
                      fontColor: _hasSelection
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: _isOpen ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.keyboard_arrow_down,
                      color: AppColors.textSecondary, size: 20),
                ),
              ]),
            ),
          ),
        ),
        if (_hasError)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              widget.errors['vaccineName'] ??
                  widget.errors['customVaccineName'] ??
                  '',
              style: AppTextStyles.regularStyle400(
                  fontSize: 12, fontColor: AppColors.error),
            ),
          ),
        if (widget.selectedVaccine != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              widget.selectedVaccine!.why,
              style: AppTextStyles.regularStyle400(
                  fontSize: 12, fontColor: AppColors.textSecondary),
            ),
          ),
        if (widget.isOtherSelected) ...[
          const SizedBox(height: 16),
          CommonFormField(
            controller: widget.customVaccineNameController,
            label: AppStrings.customVaccineName,
            hintText: AppStrings.enterCustomVaccine,
            isRequired: true,
            enabled: !widget.isSaving,
            errorText: widget.errors['customVaccineName'],
          ),
        ],
      ],
    );
  }
}

class _DropdownSheet extends StatelessWidget {
  final List<VaccineMasterData> requiredCoreVaccines;
  final List<VaccineMasterData> recommendedVaccines;
  final VaccineMasterData? selectedVaccine;
  final bool isOtherSelected;
  final ValueChanged<VaccineMasterData?> onSelected;
  final VoidCallback onOtherSelected;

  const _DropdownSheet({
    required this.requiredCoreVaccines,
    required this.recommendedVaccines,
    required this.selectedVaccine,
    required this.isOtherSelected,
    required this.onSelected,
    required this.onOtherSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 12,
      shadowColor: AppColors.shadowOverlay.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(14),
      color: AppColors.white,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 320),
        decoration: smoothDecoration(
          cornerRadius: 14,
          side: const BorderSide(color: AppColors.border),
        ),
        child: ClipSmoothRect(
          radius: AppSmoothRadius.custom(14),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (requiredCoreVaccines.isNotEmpty) ...[
                  const _SectionLabel(AppStrings.requiredCore),
                  ...requiredCoreVaccines.map((v) => _VaccineItem(
                        vaccine: v,
                        isSelected: selectedVaccine?.id == v.id,
                        onTap: () => onSelected(v),
                      )),
                ],
                if (recommendedVaccines.isNotEmpty) ...[
                  const _SectionLabel(AppStrings.recommendedVaccines),
                  ...recommendedVaccines.map((v) => _VaccineItem(
                        vaccine: v,
                        isSelected: selectedVaccine?.id == v.id,
                        onTap: () => onSelected(v),
                      )),
                ],
                const _SectionLabel(AppStrings.otherVaccine),
                _VaccineItem(
                  vaccine: null,
                  isSelected: isOtherSelected,
                  onTap: onOtherSelected,
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;
  const _SectionLabel(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.mediumStyle500(
            fontSize: 11, fontColor: AppColors.textSecondary),
      ),
    );
  }
}

class _VaccineItem extends StatelessWidget {
  final VaccineMasterData? vaccine;
  final bool isSelected;
  final VoidCallback onTap;

  const _VaccineItem({
    required this.vaccine,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isOther = vaccine == null;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.08)
            : Colors.transparent,
        child: Row(children: [
          Expanded(
            child: Row(children: [
              Text(
                isOther ? AppStrings.otherVaccine : vaccine!.name,
                style: AppTextStyles.mediumStyle500(
                  fontSize: 15,
                  fontColor:
                      isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
              if (!isOther && vaccine!.category == 'mandatory') ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: smoothDecoration(
                    cornerRadius: 4,
                    color: AppColors.error.withValues(alpha: 0.1),
                  ),
                  child: Text(
                    AppStrings.requiredBadge,
                    style: AppTextStyles.regularStyle400(
                        fontSize: 10, fontColor: AppColors.error),
                  ),
                ),
              ],
            ]),
          ),
          if (isSelected)
            const Icon(Icons.check, color: AppColors.primary, size: 18),
        ]),
      ),
    );
  }
}
