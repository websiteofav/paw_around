import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/constants/preferences_constants.dart';
import 'package:paw_around/ui/onboarding/widgets/onboarding_pages.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_icons.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/bloc/onboarding/onboarding_bloc.dart';
import 'package:paw_around/bloc/onboarding/onboarding_event.dart';
import 'package:paw_around/bloc/onboarding/onboarding_state.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const OnboardingView();
  }
}

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _goToAuth(BuildContext context) async {
    // Persist that onboarding has been completed so we only show it once
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PreferencesConstants.hasCompletedOnboarding, true);

    if (!context.mounted) return;

    // Navigate to primary auth flow using GoRouter
    context.goNamed(AppRoutes.phoneLogin);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingCompleted) {
          _goToAuth(context);
        }
      },
      child: BlocBuilder<OnboardingBloc, OnboardingState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.onboardingBackground,
            body: SafeArea(
              child: Column(
                children: [
                  // Page content
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        context
                            .read<OnboardingBloc>()
                            .add(OnboardingPageChanged(index));
                      },
                      children: [
                        // Page 1: Tracking (FIRST)
                        OnboardingPage(
                          title: "Smarter care for your pet",
                          subtitle:
                              "Track vaccines, grooming schedules & important health reminders.",
                          primaryButtonText: "Next",
                          imageWidget: Image.asset(AppIcons.introIcon1),
                          onPrimaryAction: () {},
                          onSkip: () {},
                          onNext: () {},
                          index: 0,
                        ),
                        // Page 2: Nearby services
                        OnboardingPage(
                          title: "Because pets are family",
                          subtitle: "Connect nearby. Share & find lost pets.",
                          primaryButtonText: "Next",
                          imageWidget: Image.asset(AppIcons.introIcon2),
                          onPrimaryAction: () {},
                          onSkip: () {},
                          onNext: () {},
                          index: 1,
                        ),

                        // Page 3: Community & safety (LAST)
                        OnboardingPage(
                          title: "Because pets are family",
                          subtitle: "Connect nearby. Share & find lost pets.",
                          primaryButtonText: "Next",
                          imageWidget: Image.asset(AppIcons.introIcon3),
                          onPrimaryAction: () {},
                          onSkip: () {},
                          onNext: () {},
                          index: 2,
                        ),
                      ],
                    ),
                  ),

                  // Page dots indicator with progress
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      children: [
                        // Progress text
                        Text(
                          '${state.currentPage + 1} of 3',
                          style: AppTextStyles.regularStyle400(
                            fontSize: 12,
                            fontColor: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Dots indicator
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            3,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: index == state.currentPage ? 24.0 : 10.0,
                              height: 10.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25.0),
                                color: index == state.currentPage
                                    ? AppColors.primary
                                    : AppColors.onboardingDotInactive,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
