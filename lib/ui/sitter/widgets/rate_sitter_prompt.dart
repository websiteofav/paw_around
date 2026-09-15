import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/app_spacing.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/ui/sitter/widgets/rate_sitter_bottom_sheet.dart';
import 'package:paw_around/ui/widgets/common_button.dart';

/// Shown on the Upcoming Session card once a session has happened and
/// hasn't been reviewed yet — opens RateSitterBottomSheet.
class RateSitterPrompt extends StatelessWidget {
  final String professionalId;
  final String professionalName;
  final String bookingId;

  const RateSitterPrompt({
    super.key,
    required this.professionalId,
    required this.professionalName,
    required this.bookingId,
  });

  Future<void> _onRate(BuildContext context) async {
    final submitted = await RateSitterBottomSheet.show(
      context: context,
      professionalId: professionalId,
      professionalName: professionalName,
      bookingId: bookingId,
    );
    if (submitted == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.reviewSubmittedThanks)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: smoothDecoration(
        cornerRadius: 16,
        color: AppColors.background3,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.rateYourSitterTitle,
            style: AppTextStyles.interSemiBoldStyle600(
                fontSize: 14, fontColor: AppColors.secondaryCTA),
          ),
          AppSpacing.vertical12,
          CommonButton(
            text: AppStrings.rateSitterButton,
            size: ButtonSize.small,
            customColor: AppColors.secondaryCTA,
            onPressed: () => _onRate(context),
          ),
        ],
      ),
    );
  }
}
