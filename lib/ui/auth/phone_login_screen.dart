import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
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
  bool _isLoading = false;

  Future<void> _onContinuePressed() async {
    if (!_isPhoneValid || _completePhoneNumber.isEmpty) {
      return;
    }

    setState(() => _isLoading = true);

    await sl<AuthRepository>().verifyPhoneNumber(
      phoneNumber: _completePhoneNumber,
      onCodeSent: (verificationId) {
        if (mounted) {
          setState(() => _isLoading = false);
          context.push(
            AppRoutes.otpVerification,
            extra: {
              'phoneNumber': _completePhoneNumber,
              'verificationId': verificationId,
            },
          );
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      onAutoVerified: (credential) async {
        try {
          await sl<AuthRepository>().signInWithPhoneCredential(credential);
          if (mounted) {
            context.go(AppRoutes.home);
          }
        } catch (e) {
          if (mounted) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.toString()),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      },
    );
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
              Text(
                AppStrings.welcomeToPawAround,
                style: AppTextStyles.semiBoldTextStyle(fontSize: 24),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // Subtitle
              Text(
                AppStrings.authSubtitle,
                style: AppTextStyles.regularStyle400(fontSize: 16, fontColor: AppColors.textSecondary),
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
        Text(
          AppStrings.phoneNumber,
          style: AppTextStyles.mediumStyle500(fontSize: 14, fontColor: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        IntlPhoneField(
          decoration: InputDecoration(
            hintText: '9990000000',
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
          disableLengthCheck: true,
          initialCountryCode: 'IN',
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
        onPressed: _isPhoneValid && !_isLoading ? _onContinuePressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                ),
              )
            : Text(
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
        style: AppTextStyles.regularStyle400(fontSize: 12, fontColor: AppColors.textSecondary),
        children: [
          TextSpan(
              text: '${AppStrings.termsText} ',
              style: AppTextStyles.regularStyle400(fontSize: 12, fontColor: AppColors.textSecondary)),
          TextSpan(
            text: AppStrings.termsOfService,
            style: AppTextStyles.mediumStyle500(fontSize: 14, fontColor: AppColors.primary),
          ),
          TextSpan(
              text: ' ${AppStrings.and} ',
              style: AppTextStyles.regularStyle400(fontSize: 12, fontColor: AppColors.textSecondary)),
          TextSpan(
            text: AppStrings.privacyPolicyLink,
            style: AppTextStyles.mediumStyle500(fontSize: 14, fontColor: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
