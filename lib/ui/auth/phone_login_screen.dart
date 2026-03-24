import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:paw_around/constants/analytics_constants.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_icons.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/core/di/service_locator.dart';
import 'package:paw_around/ui/widgets/common_button.dart';
import 'package:paw_around/repositories/auth_repository.dart';
import 'package:paw_around/services/analytics_service.dart';
import 'package:paw_around/services/animation_service.dart';
import 'package:paw_around/utils/url_utils.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  String _completePhoneNumber = '';
  bool _isPhoneValid = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _preloadAnimation();
  }

  void _preloadAnimation() {
    AnimationService.getLottieFile(AppIcons.addPetAnimationFileName)
        .then((_) {})
        .catchError((error) {
      debugPrint('Failed to preload animation: $error');
    });
  }

  Future<void> _onContinuePressed() async {
    if (!_isPhoneValid || _completePhoneNumber.isEmpty) return;
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
            SnackBar(content: Text(error), backgroundColor: AppColors.error),
          );
        }
      },
      onAutoVerified: (credential) async {
        try {
          await sl<AuthRepository>().signInWithPhoneCredential(credential);
          AnalyticsService.logEvent(
            name: AnalyticsEvents.loginSuccess,
            parameters: {AnalyticsParams.method: 'phone'},
          );
          if (mounted) context.go(AppRoutes.home);
        } catch (e) {
          AnalyticsService.logEvent(
            name: AnalyticsEvents.loginFailed,
            parameters: {
              AnalyticsParams.method: 'phone',
              AnalyticsParams.error: e.toString(),
            },
          );
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
    final bool isKeyboardVsisible =
        MediaQuery.of(context).viewInsets.bottom > 0;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SafeArea(
          bottom: false,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Back button
              GestureDetector(
                onTap: () => context.canPop() ? context.pop() : null,
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 20,
                  color: AppColors.neutral900,
                ),
              ),

              const SizedBox(height: 24),

              // Title
              Text(
                AppStrings.loginTitle,
                style: AppTextStyles.boldStyle700(
                  fontSize: 24,
                  fontColor: AppColors.grey1000,
                ),
              ),

              const SizedBox(height: 12),

              // Subtitle
              Text(
                AppStrings.loginSubtitle,
                style: AppTextStyles.interMediumStyle500(
                  fontSize: 16,
                  fontColor: AppColors.grey700,
                ),
              ),

              const SizedBox(height: 36),

              // Phone label
              Text(
                AppStrings.phoneNumber,
                style: AppTextStyles.interRegularStyle400(
                  fontSize: 14,
                  fontColor: AppColors.grey1000,
                ),
              ),
              const SizedBox(height: 8),

              // Phone input
              IntlPhoneField(
                decoration: InputDecoration(
                  hintText: AppStrings.enterYourNumber,
                  hintStyle: AppTextStyles.regularStyle400(
                      fontColor: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.neutral300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.neutral300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppColors.neutral300, width: 1.5),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                disableLengthCheck: true,
                initialCountryCode: 'IN',
                
                dropdownTextStyle: AppTextStyles.regularStyle400(
                    fontSize: 16, fontColor: AppColors.textPrimary),
                style: AppTextStyles.regularStyle400(
                    fontSize: 16, fontColor: AppColors.textPrimary),
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
                onCountryChanged: (_) {},
              ),

              const SizedBox(height: 8),

              // Helper text
              Text(
                AppStrings.phoneVerificationSms,
                style: AppTextStyles.regularStyle400(
                  fontSize: 12,
                  fontColor: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 24),

              // Continue button
              CommonButton(
                textStyle: AppTextStyles.interBoldStyle700(fontColor: AppColors.white, fontSize: 16),
                text: AppStrings.continueButton,
                onPressed:
                    _isPhoneValid && !_isLoading ? _onContinuePressed : null,
                isLoading: _isLoading,
              ),

              const SizedBox(height: 16),

              // Terms
              _buildTermsText(),

              const Spacer(),
              if (!isKeyboardVsisible)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        AppIcons.loginDogIcon,
                        width: 196,
                        height: 295,
                        fit: BoxFit.fitWidth,
                      ),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.white.withValues(alpha: 0),
                                AppColors.white,
                              ],
                              stops: const [0.65, 1.0],
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
      ),
    );
  }

  Widget _buildTermsText() {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          '${AppStrings.termsText} ',
          style: AppTextStyles.regularStyle400(
              fontSize: 12, fontColor: AppColors.textSecondary),
        ),
        GestureDetector(
          onTap: () => UrlUtils.openWebsite(AppStrings.termsOfServiceUrl),
          child: Text(
            AppStrings.termsOfService,
            style: AppTextStyles.semiBoldStyle600(
                fontSize: 12, fontColor: AppColors.primary),
          ),
        ),
        Text(
          ' ${AppStrings.and} ',
          style: AppTextStyles.regularStyle400(
              fontSize: 12, fontColor: AppColors.textSecondary),
        ),
        GestureDetector(
          onTap: () => UrlUtils.openWebsite(AppStrings.privacyPolicyUrl),
          child: Text(
            AppStrings.privacyPolicyLink,
            style: AppTextStyles.semiBoldStyle600(
                fontSize: 12, fontColor: AppColors.primary),
          ),
        ),
      ],
    );
  }
}
