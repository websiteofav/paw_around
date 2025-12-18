import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';

class DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const DatePickerField({
    super.key,
    required this.label,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => _showDatePicker(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.border,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isToday(selectedDate) ? AppStrings.today : '',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        _formatDate(selectedDate),
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.chevron_right,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isToday(DateTime? date) {
    if (date == null) {
      return false;
    }
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Select date';
    }
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: DateTime(2020),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
            dialogBackgroundColor: AppColors.surface,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onDateSelected(picked);
    }
  }
}
