import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/core/di/service_locator.dart';
import 'package:paw_around/repositories/auth_repository.dart';
import 'package:paw_around/ui/auth/widgets/auth_logo.dart';
import 'package:paw_around/ui/auth/widgets/social_auth_button.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  String _completePhoneNumber = '';
  bool _isPhoneValid = false;

  void _onContinuePressed() {
    if (_isPhoneValid && _completePhoneNumber.isNotEmpty) {
      context.push(
        AppRoutes.otpVerification,
        extra: _completePhoneNumber,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.authBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 48),

              // Logo
              const AuthLogo(size: 80),

              const SizedBox(height: 32),

              // Title
              const Text(
                AppStrings.welcomeToPawAround,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // Subtitle
              const Text(
                AppStrings.authSubtitle,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Phone Number Input
              _buildPhoneInput(),

              const SizedBox(height: 16),

              // Continue Button
              _buildContinueButton(),

              const SizedBox(height: 24),

              // Divider
              _buildDivider(),

              const SizedBox(height: 24),

              // Social Auth Buttons
              SocialAuthButton(
                type: SocialAuthType.google,
                onPressed: () async {
                  try {
                    await sl<AuthRepository>().signInWithGoogle();
                    if (context.mounted) {
                      context.go(AppRoutes.home);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(e.toString()),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  }
                },
              ),

              const SizedBox(height: 12),

              SocialAuthButton(
                type: SocialAuthType.apple,
                onPressed: () {
                  // TODO: Implement Apple Sign-In
                },
              ),

              const SizedBox(height: 32),

              // Terms Text
              _buildTermsText(),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.phoneNumber,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        IntlPhoneField(
          decoration: InputDecoration(
            hintText: '(555) 000-0000',
            hintStyle: const TextStyle(
              color: AppColors.textSecondary,
            ),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          initialCountryCode: 'US',
          dropdownTextStyle: const TextStyle(
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
          onChanged: (phone) {
            setState(() {
              _completePhoneNumber = phone.completeNumber;
              try {
                _isPhoneValid = phone.isValidNumber();
              } catch (_) {
                _isPhoneValid = false;
              }
            });
          },
          onCountryChanged: (country) {},
        ),
      ],
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isPhoneValid ? _onContinuePressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: Text(
          AppStrings.continueButton,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _isPhoneValid ? AppColors.white : AppColors.white.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Row(
      children: [
        Expanded(
          child: Divider(color: AppColors.border, thickness: 1),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            AppStrings.orContinueWith,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Divider(color: AppColors.border, thickness: 1),
        ),
      ],
    );
  }

  Widget _buildTermsText() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
        children: [
          TextSpan(text: '${AppStrings.termsText} '),
          TextSpan(
            text: AppStrings.termsOfService,
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          TextSpan(text: ' ${AppStrings.and} '),
          TextSpan(
            text: AppStrings.privacyPolicyLink,
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
