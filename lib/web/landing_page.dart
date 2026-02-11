import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_spacing.dart';
import 'package:paw_around/web/widgets/download_section.dart';
import 'package:paw_around/web/widgets/feature_cards_section.dart';
import 'package:paw_around/web/widgets/hero_section.dart';
import 'package:paw_around/web/widgets/landing_footer.dart';
import 'package:paw_around/web/widgets/landing_nav_bar.dart';
import 'package:paw_around/web/widgets/qr_safety_section.dart';

enum LandingSection {
  home,
  features,
  qrSafety,
  download,
  footer,
}

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final ScrollController _scrollController = ScrollController();

  final GlobalKey _homeKey = GlobalKey();
  final GlobalKey _featuresKey = GlobalKey();
  final GlobalKey _qrSafetyKey = GlobalKey();
  final GlobalKey _downloadKey = GlobalKey();
  final GlobalKey _footerKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSection(LandingSection section) {
    BuildContext? targetContext;
    switch (section) {
      case LandingSection.home:
        targetContext = _homeKey.currentContext;
        break;
      case LandingSection.features:
        targetContext = _featuresKey.currentContext;
        break;
      case LandingSection.qrSafety:
        targetContext = _qrSafetyKey.currentContext;
        break;
      case LandingSection.download:
        targetContext = _downloadKey.currentContext;
        break;
      case LandingSection.footer:
        targetContext = _footerKey.currentContext;
        break;
    }

    if (targetContext == null) {
      return;
    }

    Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _handleNavSelected(int index) {
    switch (index) {
      case 0:
        _scrollToSection(LandingSection.home);
        break;
      case 1:
        _scrollToSection(LandingSection.features);
        break;
      case 2:
        _scrollToSection(LandingSection.qrSafety);
        break;
      case 3:
        _scrollToSection(LandingSection.download);
        break;
      default:
        _scrollToSection(LandingSection.home);
    }
  }

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
              controller: _scrollController,
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LandingNavBar(
                      isMobile: isMobile,
                      onNavSelected: _handleNavSelected,
                    ),
                    AppSpacing.vertical40,
                    KeyedSubtree(
                      key: _homeKey,
                      child: HeroSection(isMobile: isMobile),
                    ),
                    AppSpacing.vertical48,
                    KeyedSubtree(
                      key: _featuresKey,
                      child: const FeatureCardsSection(),
                    ),
                    AppSpacing.vertical48,
                    KeyedSubtree(
                      key: _qrSafetyKey,
                      child: QrSafetySection(
                        isMobile: isMobile,
                        onCtaPressed: () =>
                            _scrollToSection(LandingSection.download),
                      ),
                    ),
                    AppSpacing.vertical48,
                    KeyedSubtree(
                      key: _downloadKey,
                      child: const DownloadSection(),
                    ),
                    AppSpacing.vertical40,
                    KeyedSubtree(
                      key: _footerKey,
                      child: const LandingFooter(),
                    ),
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
