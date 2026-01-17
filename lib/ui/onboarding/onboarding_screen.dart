import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/constants/preferences_constants.dart';
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
                  // Skip button (top-right)
                  Padding(
                    padding: const EdgeInsets.only(top: 16, right: 16),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: TextButton(
                        onPressed: () {
                          context.read<OnboardingBloc>().add(OnboardingSkip());
                        },
                        child: Text(
                          AppStrings.skipButton,
                          style: AppTextStyles.regularStyle400(
                            fontSize: 14,
                            fontColor: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Page content
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        context.read<OnboardingBloc>().add(OnboardingPageChanged(index));
                      },
                      children: [
                        // Page 1: Tracking (FIRST)
                        _buildPage(
                          title: AppStrings.onboarding1Title,
                          description: AppStrings.onboarding1Description,
                          image: SvgPicture.asset(AppIcons.introIcon1),
                        ),
                        // Page 2: Nearby services
                        _buildPage(
                          title: AppStrings.onboarding2Title,
                          description: AppStrings.onboarding2Description,
                          image: SvgPicture.asset(AppIcons.introIcon2),
                        ),
                        // Page 3: Community & safety (LAST)
                        _buildPage(
                          title: AppStrings.onboarding3Title,
                          description: AppStrings.onboarding3Description,
                          image: SvgPicture.asset(AppIcons.introIcon3),
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
                                    ? AppColors.onboardingDotActive
                                    : AppColors.onboardingDotInactive,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Navigation buttons
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                    child: state.currentPage == 2
                        ? SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: () {
                                context.read<OnboardingBloc>().add(OnboardingNextPage());
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.onboardingButton,
                                foregroundColor: AppColors.onboardingButtonText,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 2,
                              ),
                              child: Text(
                                AppStrings.getStartedButton,
                                style: AppTextStyles.boldStyle700(
                                  fontSize: 16,
                                  fontColor: AppColors.onboardingButtonText,
                                ),
                              ),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                  context.read<OnboardingBloc>().add(OnboardingNextPage());
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      AppStrings.nextButton,
                                      style: AppTextStyles.semiBoldStyle600(
                                        fontSize: 16,
                                        fontColor: AppColors.onboardingText,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 14,
                                      color: AppColors.onboardingText,
                                    ),
                                  ],
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

  Widget _buildPage({
    required String title,
    required String description,
    required Widget image,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate max illustration height (45% of available height)
        final maxIllustrationHeight = constraints.maxHeight * 0.4;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Illustration (≤45% of screen height)
              SizedBox(
                height: maxIllustrationHeight,
                child: Center(
                  child: image,
                ),
              ),

              const SizedBox(height: 40),

              // Title
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyles.boldStyle700(
                  fontSize: 26,
                  fontColor: AppColors.textPrimary,
                  height: 1.3,
                ),
              ),

              const SizedBox(height: 16),

              // Description
              Text(
                description,
                textAlign: TextAlign.center,
                style: AppTextStyles.regularStyle400(
                  fontSize: 16,
                  fontColor: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),

              const Spacer(),
            ],
          ),
        );
      },
    );
  }
}
