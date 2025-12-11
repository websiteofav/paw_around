import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_constants.dart';
import 'package:paw_around/ui/widgets/animated_content.dart';
import 'package:paw_around/ui/widgets/paw_pattern_painter.dart';
import 'widgets/app_logo.dart';
import 'widgets/get_started_button.dart';
import 'widgets/app_title_section.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _animationController.forward();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: AppConstants.animationDuration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
        ),
        child: CustomPaint(
          painter: PawPatternPainter(),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMedium),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  _buildLogoSection(),
                  const SizedBox(height: AppConstants.spacingLarge),
                  _buildTitleSection(),
                  const Spacer(flex: 3),
                  _buildButtonSection(),
                  const SizedBox(height: AppConstants.spacingLarge),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return AnimatedScaledContent(
      animation: _scaleAnimation,
      child: const AppLogo(),
    );
  }

  Widget _buildTitleSection() {
    return AppTitleSection(animation: _fadeAnimation);
  }

  Widget _buildButtonSection() {
    return AnimatedContent(
      animation: _fadeAnimation,
      child: const GetStartedButton(),
    );
  }
}
