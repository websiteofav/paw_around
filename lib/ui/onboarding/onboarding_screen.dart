import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/constants/app_constants.dart';
import 'package:paw_around/ui/widgets/common_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:paw_around/bloc/onboarding/onboarding_bloc.dart';
import 'package:paw_around/bloc/onboarding/onboarding_event.dart';
import 'package:paw_around/bloc/onboarding/onboarding_state.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_icons.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/constants/preferences_constants.dart';
import 'package:paw_around/ui/onboarding/widgets/onboarding_page.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) => const _OnboardingView();
}

class _OnboardingView extends StatefulWidget {
  const _OnboardingView();

  @override
  State<_OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<_OnboardingView> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _goToAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PreferencesConstants.hasCompletedOnboarding, true);
    if (!mounted) return;
    context.goNamed(AppRoutes.phoneLogin);
  }

  static const _pages = [
    (
      image: AppIcons.introIcon1,
      title: AppStrings.onboarding1Title,
      desc: AppStrings.onboarding1Description
    ),
    (
      image: AppIcons.introIcon2,
      title: AppStrings.onboarding2Title,
      desc: AppStrings.onboarding2Description
    ),
    (
      image: AppIcons.introIcon3,
      title: AppStrings.onboarding3Title,
      desc: AppStrings.onboarding3Description
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingCompleted) _goToAuth();
      },
      child: BlocBuilder<OnboardingBloc, OnboardingState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.white,
            body: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: AppConstants.spacingLarge),

                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (i) => context
                          .read<OnboardingBloc>()
                          .add(OnboardingPageChanged(i)),
                      children: _pages
                          .map((p) => OnboardingPage(
                                imagePath: p.image,
                                title: p.title,
                                description: p.desc,
                              ))
                          .toList(),
                    ),
                  ),

                  // Dots
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        3,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: i == state.currentPage ? 24.0 : 8.0,
                          height: 8.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: i == state.currentPage
                                ? AppColors.primary
                                : AppColors.grey100,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Login / Signup button
                  CommonButton(
                    text: AppStrings.loginSignupButton,
                    onPressed: _goToAuth,
                    variant: ButtonVariant.primary,
                    size: ButtonSize.large,
                    isFullWidth: false,
                    buttonHeight: 52,
                    buttonWidth: 172,
                    textStyle: AppTextStyles.interBoldStyle700(
                      fontSize: 16,
                      fontColor: AppColors.grey1000,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingLarge),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
