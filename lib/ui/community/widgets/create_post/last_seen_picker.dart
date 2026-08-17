import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';

/// "When did you last see {pet}?" — a Pick time / Just now toggle, with a
/// tap-to-open date+time field (past only) shown when Pick time is active.
class LastSeenPicker extends StatelessWidget {
  final String? petName;
  final DateTime value;
  final bool isJustNow;
  final ValueChanged<bool> onJustNowChanged;
  final ValueChanged<DateTime> onChanged;

  const LastSeenPicker({
    super.key,
    required this.petName,
    required this.value,
    required this.isJustNow,
    required this.onJustNowChanged,
    required this.onChanged,
  });

  static Widget _pickerTheme(BuildContext context, Widget? child) => Theme(
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

  Future<void> _pickDateTime(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: value,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: _pickerTheme,
    );
    if (date == null || !context.mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(value),
      builder: _pickerTheme,
    );
    if (time == null) return;
    onChanged(
      DateTime(date.year, date.month, date.day, time.hour, time.minute),
    );
  }

  String get _title {
    final hasPetName = petName != null && petName!.isNotEmpty;
    return hasPetName
        ? '${AppStrings.whenDidYouLastSee} $petName?'
        : AppStrings.whenDidYouSeeThePet;
  }

  String _formatDateTime(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final min = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month - 1]} ${dt.day}, $hour:$min $ampm';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _title,
          style: AppTextStyles.semiBoldStyle600(
              fontSize: 13, fontColor: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildChip(AppStrings.pickTime, !isJustNow,
                () => onJustNowChanged(false)),
            const SizedBox(width: 10),
            _buildChip(
                AppStrings.justNow, isJustNow, () => onJustNowChanged(true)),
          ],
        ),
        if (!isJustNow) ...[
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _pickDateTime(context),
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
                      _formatDateTime(value),
                      style: AppTextStyles.regularStyle400(
                          fontSize: 15, fontColor: AppColors.textPrimary),
                    ),
                  ),
                  const Icon(Icons.calendar_today_outlined,
                      color: AppColors.primary, size: 18),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildChip(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: smoothDecoration(
          cornerRadius: 999,
          color: isActive ? AppColors.navColor : AppColors.white,
          side: BorderSide(
              color: isActive ? AppColors.navColor : AppColors.border),
        ),
        child: Text(
          label,
          style: AppTextStyles.mediumStyle500(
            fontSize: 14,
            fontColor: isActive ? AppColors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
