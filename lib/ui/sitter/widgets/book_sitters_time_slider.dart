import 'package:flutter/material.dart';
import 'package:flutter_ruler_picker/flutter_ruler_picker.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/app_icons.dart';
import 'package:paw_around/constants/app_spacing.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';

/// "Time (Hours)" ruler + mock pricing on the Book Sitters screen. No
/// pricing backend exists yet — see BookSittersScreen's doc comment.
///
/// Uses the same RulerPicker pattern as PetRulerField
/// (lib/ui/pets/widgets/pet_form_selectors.dart) for consistency with the
/// app's other drag-to-pick-a-number fields.
class BookSittersTimeSlider extends StatefulWidget {
  final double hours;
  final ValueChanged<double> onChanged;

  const BookSittersTimeSlider({
    super.key,
    required this.hours,
    required this.onChanged,
  });

  @override
  State<BookSittersTimeSlider> createState() => _BookSittersTimeSliderState();
}

class _BookSittersTimeSliderState extends State<BookSittersTimeSlider> {
  static const int _minHours = 1;
  static const int _maxHours = 6;
  static const double _step = 0.5;

  // Mock hourly rate + a fixed 35% promo discount — no real pricing
  // engine exists yet.
  static const double _ratePerHour = 720;
  static const double _discount = 0.35;

  late RulerPickerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RulerPickerController(value: widget.hours);
  }

  @override
  void didUpdateWidget(BookSittersTimeSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hours != widget.hours && _controller.value != widget.hours) {
      _controller.value = widget.hours;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final originalPrice = (_ratePerHour * widget.hours).round();
    final discountedPrice = (_ratePerHour * widget.hours * (1 - _discount)).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.timeHoursLabel,
          style: AppTextStyles.interRegularStyle400(
            fontSize: 14,
            fontColor: AppColors.grey1000,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: AppEdgeInsets.allMedium,
          decoration: smoothDecoration(
            cornerRadius: 20,
            color: AppColors.white,
            shadows: [
              BoxShadow(
                color: AppColors.shadowOverlay.withValues(alpha: 0.0510),
                offset: const Offset(0, 3),
                blurRadius: 7,
              ),
              BoxShadow(
                color: AppColors.shadowOverlay.withValues(alpha: 0.0392),
                offset: const Offset(0, 13),
                blurRadius: 13,
              ),
              BoxShadow(
                color: AppColors.shadowOverlay.withValues(alpha: 0.0314),
                offset: const Offset(0, 30),
                blurRadius: 18,
              ),
              BoxShadow(
                color: AppColors.shadowOverlay.withValues(alpha: 0.0118),
                offset: const Offset(0, 54),
                blurRadius: 21,
              ),
              BoxShadow(
                color: AppColors.shadowOverlay.withValues(alpha: 0),
                offset: const Offset(0, 84),
                blurRadius: 23,
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                widget.hours.toStringAsFixed(widget.hours % 1 == 0 ? 0 : 1),
                style: AppTextStyles.interBoldStyle700(
                  fontSize: 24,
                  fontColor: AppColors.secondaryCTA,
                ),
              ),
              const SizedBox(height: 20),
              LayoutBuilder(
                builder: (context, constraints) {
                  return RulerPicker(
                    controller: _controller,
                    width: constraints.maxWidth,
                    height: 52,
                    rulerMarginTop: 16,
                    rulerBackgroundColor: AppColors.white,
                    onValueChanged: (v) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) widget.onChanged(v.toDouble());
                      });
                    },
                    onBuildRulerScaleText: (_, v) => v.toStringAsFixed(0),
                    ranges: const [
                      RulerRange(begin: _minHours, end: _maxHours, scale: _step),
                    ],
                    rulerScaleTextStyle: const TextStyle(
                      color: AppColors.grey200,
                      fontSize: 12,
                    ),
                    scaleLineStyleList: const [
                      ScaleLineStyle(scale: 0, color: AppColors.grey200, width: 1.5, height: 28),
                      ScaleLineStyle(scale: -1, color: AppColors.grey100, width: 1, height: 16),
                    ],
                    marker: Container(
                      width: 2,
                      height: 68,
                      decoration: smoothDecoration(
                        cornerRadius: 1,
                        color: AppColors.secondaryCTA,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '₹$discountedPrice',
                    style: AppTextStyles.interBoldStyle700(
                      fontSize: 18,
                      fontColor: AppColors.secondaryCTA,
                    ),
                  ),
                  AppSpacing.horizontal8,
                  Text(
                    '₹$originalPrice',
                    style: AppTextStyles.interRegularStyle400(
                      fontSize: 18,
                      fontColor: AppColors.grey600,
                    ).copyWith(decoration: TextDecoration.lineThrough),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Image.asset(
                        AppIcons.tagIcon,
                        width: 16,
                        height: 16,
                        color: AppColors.grey600,
                        colorBlendMode: BlendMode.srcIn,
                      ),
                      AppSpacing.horizontal4,
                      Text(
                        AppStrings.discountOffLabel,
                        style: AppTextStyles.interRegularStyle400(
                          fontSize: 12,
                          fontColor: AppColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        AppSpacing.vertical32,
        Row(
          children: [
            const Icon(Icons.access_time_filled, size: 18, color: AppColors.grey700),
            AppSpacing.horizontal8,
            Text(
              AppStrings.earliestAvailableSlot,
              style: AppTextStyles.interMediumStyle500(
                fontSize: 12,
                fontColor: AppColors.grey700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
