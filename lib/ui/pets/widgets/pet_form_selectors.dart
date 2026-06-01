import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ruler_picker/flutter_ruler_picker.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/ui/widgets/scale_button.dart';

// ── Gender Selector ───────────────────────────────────────────────────────────

class PetGenderSelector extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onChanged;
  const PetGenderSelector(
      {super.key, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _GenderButton(
            label: AppStrings.male,
            isSelected: selected == AppStrings.male,
            icon: Icons.male,
            onTap: () =>
                onChanged(selected == AppStrings.male ? null : AppStrings.male),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _GenderButton(
            label: AppStrings.female,
            icon: Icons.female_outlined,
            isSelected: selected == AppStrings.female,
            onTap: () => onChanged(
                selected == AppStrings.female ? null : AppStrings.female),
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
  const _GenderButton(
      {required this.label,
      required this.isSelected,
      required this.onTap,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return ScaleButton(
      onPressed: onTap,
      child: AnimatedContainer(
        height: 104,
        width: 168,
        duration: const Duration(milliseconds: 200),
        decoration: smoothDecoration(
          cornerRadius: 24,
          color: isSelected ? AppColors.secondaryCTA : AppColors.white,
          side: BorderSide(
              color: isSelected ? AppColors.primary : AppColors.neutral300),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 48,
                color: isSelected ? AppColors.white : AppColors.grey1000),
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

// ── Ruler Field ───────────────────────────────────────────────────────────────

class PetRulerField extends StatefulWidget {
  final double value;
  final int min;
  final int max;
  final double step;
  final int decimals;
  final ValueChanged<double> onChanged;

  const PetRulerField({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 150,
    this.step = 0.5,
    this.decimals = 1,
  });

  @override
  State<PetRulerField> createState() => _PetRulerFieldState();
}

class _PetRulerFieldState extends State<PetRulerField> {
  late RulerPickerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RulerPickerController(value: widget.value);
  }

  @override
  void didUpdateWidget(PetRulerField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && _controller.value != widget.value) {
      _controller.value = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          widget.value.toStringAsFixed(widget.decimals),
          style: AppTextStyles.interBoldStyle700(
              fontSize: 24, fontColor: AppColors.secondaryCTA),
        ),
        const SizedBox(height: 20),
        RulerPicker(
          controller: _controller,
          width: MediaQuery.of(context).size.width - 48,
          height: 52,
          rulerMarginTop: 16,
          rulerBackgroundColor: AppColors.white,
          onValueChanged: (v) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) widget.onChanged(v.toDouble());
            });
          },
          onBuildRulerScaleText: (_, v) => v.toStringAsFixed(0),
          ranges: [
            RulerRange(begin: widget.min, end: widget.max, scale: widget.step),
          ],
          rulerScaleTextStyle: const TextStyle(
            color: AppColors.grey200,
            fontSize: 12,
          ),
          scaleLineStyleList: const [
            ScaleLineStyle(
                scale: 0, color: AppColors.grey200, width: 1.5, height: 28),
            ScaleLineStyle(
                scale: -1, color: AppColors.grey100, width: 1, height: 16),
          ],
          marker: Container(
            width: 2,
            height: 68,
            decoration: smoothDecoration(
              cornerRadius: 1,
              color: AppColors.secondaryCTA,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Step Indicator ────────────────────────────────────────────────────────────

class PetStepIndicator extends StatelessWidget {
  final int current;
  final int total;
  const PetStepIndicator(
      {super.key, required this.current, required this.total});

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
          decoration: smoothDecoration(
            cornerRadius: 4,
            color: isActive ? AppColors.primary : AppColors.border,
          ),
        );
      }),
    );
  }
}
