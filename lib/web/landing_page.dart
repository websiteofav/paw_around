import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_spacing.dart';
import 'package:paw_around/web/widgets/download_section.dart';
import 'package:paw_around/web/widgets/feature_cards_section.dart';
import 'package:paw_around/web/widgets/hero_section.dart';
import 'package:paw_around/web/widgets/landing_footer.dart';
import 'package:paw_around/web/widgets/landing_nav_bar.dart';
import 'package:paw_around/web/widgets/qr_safety_section.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 800;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.onboardingMapBlue,
                  AppColors.background,
                ],
              ),
            ),
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LandingNavBar(isMobile: isMobile),
                    AppSpacing.vertical40,
                    HeroSection(isMobile: isMobile),
                    AppSpacing.vertical48,
                    const FeatureCardsSection(),
                    AppSpacing.vertical48,
                    QrSafetySection(isMobile: isMobile),
                    AppSpacing.vertical48,
                    const DownloadSection(),
                    AppSpacing.vertical40,
                    const LandingFooter(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
