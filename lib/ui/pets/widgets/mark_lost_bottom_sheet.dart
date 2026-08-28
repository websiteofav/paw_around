import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/app_spacing.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/ui/widgets/common_button.dart';
import 'package:paw_around/ui/widgets/location_autocomplete_field.dart';

/// Bottom sheet to collect last-seen date/time and location when marking a pet as lost.
class MarkLostBottomSheet extends StatefulWidget {
  final PetModel pet;
  final void Function(DateTime lastSeenAt, String lastSeenLocation) onSave;

  const MarkLostBottomSheet({
    super.key,
    required this.pet,
    required this.onSave,
  });

  static Future<void> show({
    required BuildContext context,
    required PetModel pet,
    required void Function(DateTime lastSeenAt, String lastSeenLocation) onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => MarkLostBottomSheet(pet: pet, onSave: onSave),
    );
  }

  @override
  State<MarkLostBottomSheet> createState() => _MarkLostBottomSheetState();
}

class _MarkLostBottomSheetState extends State<MarkLostBottomSheet> {
  late DateTime _selectedDateTime;
  late TextEditingController _locationController;

  @override
  void initState() {
    super.initState();
    _selectedDateTime = widget.pet.lastSeenAt ?? DateTime.now();
    _locationController = TextEditingController(
      text: widget.pet.lastSeenLocation ?? '',
    );
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectDateAndTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (time != null && mounted) {
      setState(() {
        _selectedDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
      });
    }
  }

  void _handleSave() {
    widget.onSave(_selectedDateTime, _locationController.text.trim());
    Navigator.pop(context);
  }

  String _formatDateTime(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final min = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} at $hour:$min $ampm';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: smoothDecoration(
        borderRadius: AppSmoothRadius.topOnly(24),
        color: AppColors.surface,
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: smoothDecoration(
                cornerRadius: 2,
                color: AppColors.border,
              ),
            ),
          ),
          Text(
            AppStrings.markLostLastSeenTitle,
            style: AppTextStyles.semiBoldStyle600(
              fontSize: 20,
              fontColor: AppColors.textPrimary,
            ),
          ),
          AppSpacing.vertical8,
          Text(
            AppStrings.markLostLastSeenDescription,
            style: AppTextStyles.regularStyle400(
              fontSize: 14,
              fontColor: AppColors.textSecondary,
            ),
          ),
          AppSpacing.vertical24,
          Text(
            AppStrings.lastSeenDateAndTime,
            style: AppTextStyles.mediumStyle500(
              fontSize: 14,
              fontColor: AppColors.textPrimary,
            ),
          ),
          AppSpacing.vertical8,
          GestureDetector(
            onTap: _selectDateAndTime,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: smoothDecoration(
                cornerRadius: 12,
                color: AppColors.surface,
                side: const BorderSide(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _formatDateTime(_selectedDateTime),
                      style: AppTextStyles.regularStyle400(
                        fontSize: 16,
                        fontColor: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.calendar_today_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          AppSpacing.vertical20,
          LocationAutocompleteField(
            controller: _locationController,
            labelText: AppStrings.lastSeenLocationLabel,
            hintText: AppStrings.searchForLocation,
            showCurrentLocationButton: true,
            fillColor: AppColors.surface,
          ),
          AppSpacing.vertical32,
          Row(
            children: [
              Expanded(
                child: CommonButton(
                  text: AppStrings.cancel,
                  onPressed: () => Navigator.pop(context),
                  variant: ButtonVariant.secondary,
                  size: ButtonSize.medium,
                ),
              ),
              AppSpacing.horizontal12,
              Expanded(
                child: CommonButton(
                  text: AppStrings.save,
                  onPressed: _handleSave,
                  size: ButtonSize.medium,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
