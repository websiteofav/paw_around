import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/ui/widgets/curved_top_clipper.dart';

class OnboardingPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final String primaryButtonText;
  final VoidCallback onPrimaryAction;
  final VoidCallback? onSkip;
  final VoidCallback? onNext;
  final Widget imageWidget;
  final int index;
  const OnboardingPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.primaryButtonText,
    required this.onPrimaryAction,
    required this.imageWidget,
    this.onSkip,
    this.onNext,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12C2A3), // teal background
      body: SafeArea(
        child: Stack(
          children: [
            /// Skip Button
            if (onSkip != null)
              Positioned(
                top: 12,
                right: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Text(
                    AppStrings.skipButton,
                    style: AppTextStyles.regularStyle400(
                      fontSize: 14,
                      fontColor: AppColors.white,
                    ),
                  ),
                ),
              ),

            Column(
              children: [
                const Spacer(),

                /// Image / Placeholder
                SizedBox(
                  height: 260,
                  child: imageWidget,
                ),

                const Spacer(),

                /// Bottom White Card
                /// Bottom Curved White Card
                ClipPath(
                  clipper: CurvedTopClipper(),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
                    color: const Color(0xFFF5FFFC),
                    child: Column(
                      children: [
                        const Icon(Icons.pets, color: Color(0xFF12C2A3)),

                        const SizedBox(height: 16),

                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Text(
                          subtitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black54,
                          ),
                        ),

                        const SizedBox(height: 28),

                        /// Primary CTA
                      ],
                    ),
                  ),
                ),
              ],
            ),

            /// Next Arrow
            if (onNext != null)
              Positioned(
                bottom: 12,
                right: 24,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: const Icon(Icons.arrow_forward_ios,
                      color: AppColors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
