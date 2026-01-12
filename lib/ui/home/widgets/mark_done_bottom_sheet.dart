import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/ui/widgets/common_button.dart';

class MarkDoneBottomSheet extends StatefulWidget {
  final String actionTitle;

  const MarkDoneBottomSheet({
    super.key,
    required this.actionTitle,
  });

  static Future<DateTime?> show(BuildContext context, String actionTitle) {
    return showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => MarkDoneBottomSheet(actionTitle: actionTitle),
    );
  }

  @override
  State<MarkDoneBottomSheet> createState() => _MarkDoneBottomSheetState();
}

class _MarkDoneBottomSheetState extends State<MarkDoneBottomSheet> {
  DateTime? _selectedDate;

  static const List<String> _months = [
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

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now(); // Default to today
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);
    final lastDate = now;

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              surface: AppColors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(date.year, date.month, date.day);

    if (selected == today) {
      return AppStrings.doneToday;
    } else {
      return '${_months[date.month - 1]} ${date.day}, ${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isToday = _selectedDate != null &&
        DateTime(_selectedDate!.year, _selectedDate!.month,
                _selectedDate!.day) ==
            DateTime(
                DateTime.now().year, DateTime.now().month, DateTime.now().day);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(32),
            ),
            child: const Icon(
              Icons.check_circle_outline,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          // Title
          Text(
            AppStrings.confirmMarkDone,
            style: AppTextStyles.semiBoldStyle600(
                fontSize: 20, fontColor: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          // Description
          Text(
            AppStrings.markDoneDescription,
            textAlign: TextAlign.center,
            style: AppTextStyles.regularStyle400(
              fontSize: 14,
              fontColor: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          // Date Selection
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.completionDate,
                        style: AppTextStyles.regularStyle400(
                          fontSize: 12,
                          fontColor: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _selectedDate != null
                            ? _formatDate(_selectedDate!)
                            : AppStrings.doneToday,
                        style: AppTextStyles.semiBoldStyle600(
                          fontSize: 16,
                          fontColor: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                CommonButton(
                  isFullWidth: false, // Add this line
                  text: isToday ? AppStrings.changeDate : AppStrings.selectDate,
                  variant: ButtonVariant.outline,
                  size: ButtonSize.small,
                  onPressed: _selectDate,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Buttons
          Row(
            children: [
              Expanded(
                child: CommonButton(
                  text: AppStrings.cancel,
                  variant: ButtonVariant.outline,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CommonButton(
                  text: AppStrings.confirm,
                  onPressed: () => Navigator.of(context).pop(_selectedDate),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
