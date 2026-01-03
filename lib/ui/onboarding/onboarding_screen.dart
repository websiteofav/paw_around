import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_icons.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/bloc/onboarding/onboarding_bloc.dart';
import 'package:paw_around/bloc/onboarding/onboarding_event.dart';
import 'package:paw_around/bloc/onboarding/onboarding_state.dart';
import 'package:paw_around/ui/auth/phone_login_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const OnboardingView();
  }
}

class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  void _goToAuth(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const PhoneLoginScreen()),
    );
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
                      onPageChanged: (index) {
                        context.read<OnboardingBloc>().add(OnboardingPageChanged(index));
                      },
                      children: [
                        _buildPage(
                          title: AppStrings.onboarding1Title,
                          image: Image.asset(AppIcons.introIcon1),
                        ),
                        _buildPage(
                          title: AppStrings.onboarding2Title,
                          image: Image.asset(AppIcons.introIcon2),
                        ),
                        _buildPage(
                          title: AppStrings.onboarding3Title,
                          image: Image.asset(AppIcons.introIcon3),
                        ),
                      ],
                    ),
                  ),

                  // Page dots indicator
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        3,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: index == state.currentPage ? 22.0 : 10.0,
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
                  ),

                  // Navigation buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Skip button
                        TextButton(
                          onPressed: () {
                            context.read<OnboardingBloc>().add(OnboardingSkip());
                          },
                          child: Text(
                            AppStrings.skipButton,
                            style: AppTextStyles.mediumStyle500(fontSize: 16, fontColor: AppColors.onboardingText),
                          ),
                        ),

                        // Next/Get Started button
                        state.currentPage == 2
                            ? Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.onboardingButton,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: TextButton(
                                  onPressed: () {
                                    context.read<OnboardingBloc>().add(OnboardingNextPage());
                                  },
                                  child: Text(
                                    AppStrings.getStartedButton,
                                    style: AppTextStyles.boldStyle700(
                                        fontSize: 16, fontColor: AppColors.onboardingButtonText),
                                  ),
                                ),
                              )
                            : TextButton(
                                onPressed: () {
                                  context.read<OnboardingBloc>().add(OnboardingNextPage());
                                },
                                child: Text(
                                  AppStrings.nextButton,
                                  style:
                                      AppTextStyles.mediumStyle500(fontSize: 16, fontColor: AppColors.onboardingText),
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

  Widget _buildPage({required String title, required Widget image}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),

          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.boldStyle700(
              fontSize: 24,
              fontColor: AppColors.onboardingText,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 60),

          // Image
          image,

          const SizedBox(height: 60),
        ],
      ),
    );
  }
}
