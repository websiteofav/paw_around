import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/ui/widgets/scale_button.dart';

// ── Gender Selector ───────────────────────────────────────────────────────────

class PetGenderSelector extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onChanged;
  const PetGenderSelector({super.key, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _GenderButton(
            label: AppStrings.male,
            isSelected: selected == AppStrings.male,
            icon: Icons.male,
            onTap: () => onChanged(selected == AppStrings.male ? null : AppStrings.male),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _GenderButton(
            label: AppStrings.female,
            icon: Icons.female_outlined,
            isSelected: selected == AppStrings.female,
            onTap: () => onChanged(selected == AppStrings.female ? null : AppStrings.female),
          ),
        ),
      ],
    );
  }
}

class _GenderButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData icon;
  const _GenderButton({required this.label, required this.isSelected, required this.onTap, required this.icon});

  @override
  Widget build(BuildContext context) {
    return ScaleButton(
      onPressed: onTap,
      child: AnimatedContainer(
        height: 104,
        width: 168,
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondaryCTA : AppColors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.neutral300),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: isSelected ? AppColors.white : AppColors.grey1000),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.interMediumStyle500(
                fontSize: 16,
                fontColor: isSelected ? AppColors.white : AppColors.grey1000,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stepper Field ─────────────────────────────────────────────────────────────

class PetStepperField extends StatelessWidget {
  final double value;
  final double step;
  final int decimals;
  final ValueChanged<double> onChanged;
  const PetStepperField({
    super.key,
    required this.value,
    required this.step,
    required this.decimals,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StepButton(
          icon: Icons.remove,
          onTap: value > 0 ? () => onChanged((value - step).clamp(0, 9999)) : null,
        ),
        Expanded(
          child: Center(
            child: Text(
              value.toStringAsFixed(decimals),
              style: AppTextStyles.boldStyle700(fontSize: 18, fontColor: AppColors.secondaryCTA),
            ),
          ),
        ),
        _StepButton(icon: Icons.add, onTap: () => onChanged(value + step)),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _StepButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: onTap != null ? AppColors.secondaryCTA : AppColors.border,
        ),
        child: Icon(icon, size: 20, color: AppColors.white),
      ),
    );
  }
}

// ── Step Indicator ────────────────────────────────────────────────────────────

class PetStepIndicator extends StatelessWidget {
  final int current;
  final int total;
  const PetStepIndicator({super.key, required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
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
