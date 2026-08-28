import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/constants/analytics_constants.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_icons.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/core/di/service_locator.dart';
import 'package:paw_around/repositories/auth_repository.dart';
import 'package:paw_around/services/analytics_service.dart';
import 'package:paw_around/ui/auth/widgets/otp_input_field.dart';
import 'package:paw_around/ui/widgets/common_button.dart';

class OTPScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;

  const OTPScreen({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
  });

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  static const int _resendCooldownSeconds = 60;

  TextEditingController? _otpController;
  bool _isOTPComplete = false;
  bool _isVerifying = false;
  bool _isResending = false;
  late String _verificationId;
  int _resendCountdown = 0;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController();
    _verificationId = widget.verificationId;
    _startResendCountdown();
  }

  void _startResendCountdown() {
    _resendTimer?.cancel();
    _resendCountdown = _resendCooldownSeconds;
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _resendCountdown--;
        if (_resendCountdown <= 0) {
          _resendTimer?.cancel();
          _resendTimer = null;
        }
      });
    });
  }

  String get _maskedPhoneNumber {
    if (widget.phoneNumber.length < 4) return widget.phoneNumber;
    final lastFour =
        widget.phoneNumber.substring(widget.phoneNumber.length - 4);
    return '+${'•' * (widget.phoneNumber.length - 5)}$lastFour';
  }

  void _onOTPChanged(String value) {
    setState(() => _isOTPComplete = value.length == 6);
  }

  void _onOTPCompleted(String value) {
    setState(() => _isOTPComplete = true);
    _verifyOTP();
  }

  Future<void> _verifyOTP() async {
    if (!_isOTPComplete || _otpController == null) return;

    setState(() => _isVerifying = true);

    try {
      await sl<AuthRepository>().signInWithOTP(
        verificationId: _verificationId,
        smsCode: _otpController!.text,
      );
      AnalyticsService.logEvent(
        name: AnalyticsEvents.loginSuccess,
        parameters: {AnalyticsParams.method: 'phone'},
      );
    } on FirebaseAuthException catch (e) {
      AnalyticsService.logEvent(
        name: AnalyticsEvents.loginFailed,
        parameters: {
          AnalyticsParams.method: 'phone',
          AnalyticsParams.error: e.code,
        },
      );
      if (mounted) {
        setState(() => _isVerifying = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(sl<AuthRepository>().getAuthErrorMessage(e)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      AnalyticsService.logEvent(
        name: AnalyticsEvents.loginFailed,
        parameters: {
          AnalyticsParams.method: 'phone',
          AnalyticsParams.error: e.toString(),
        },
      );
      if (mounted) {
        setState(() => _isVerifying = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _resendOTP() async {
    if (_isResending) return;

    setState(() => _isResending = true);

    await sl<AuthRepository>().verifyPhoneNumber(
      phoneNumber: widget.phoneNumber,
      onCodeSent: (verificationId) {
        if (mounted) {
          setState(() {
            _verificationId = verificationId;
            _isResending = false;
          });
          _startResendCountdown();
          HapticFeedback.mediumImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(AppStrings.otpSentSuccessfully),
              backgroundColor: AppColors.success,
            ),
          );
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() => _isResending = false);
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
          AnalyticsService.logEvent(
            name: AnalyticsEvents.loginSuccess,
            parameters: {AnalyticsParams.method: 'phone'},
          );
        } catch (e) {
          AnalyticsService.logEvent(
            name: AnalyticsEvents.loginFailed,
            parameters: {
              AnalyticsParams.method: 'phone',
              AnalyticsParams.error: e.toString(),
            },
          );
          if (mounted) {
            setState(() => _isResending = false);
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
  void dispose() {
    _resendTimer?.cancel();
    _resendTimer = null;
    _otpController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Back button
              GestureDetector(
                onTap: () => context.pop(),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 20,
                  color: AppColors.neutral900,
                ),
              ),

              const SizedBox(height: 24),

              // Title
              Text(
                AppStrings.enterOTPCode,
                style: AppTextStyles.boldStyle700(
                  fontSize: 24,
                  fontColor: AppColors.grey1000,
                ),
              ),

              const SizedBox(height: 12),

              // Subtitle — two lines
              Text(
                AppStrings.otpSentTo,
                style: AppTextStyles.interMediumStyle500(
                  fontSize: 16,
                  fontColor: AppColors.grey700,
                ),
              ),
              Text(
                _maskedPhoneNumber,
                style: AppTextStyles.boldStyle700(
                  fontSize: 16,
                  fontColor: AppColors.grey700,
                ),
              ),

              const SizedBox(height: 8),

              // Edit Number
              GestureDetector(
                onTap: () => context.pop(),
                child: Text(
                  AppStrings.editNumber,
                  style: AppTextStyles.interMediumStyle500(
                    fontSize: 14,
                    fontColor: AppColors.secondaryCTA,
                  ).copyWith(
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.secondaryCTA,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // OTP Input
              if (_otpController != null)
                OTPInputField(
                  controller: _otpController!,
                  onChanged: _onOTPChanged,
                  onCompleted: _onOTPCompleted,
                ),

              const SizedBox(height: 24),

              // Verify button
              CommonButton(
                textStyle: AppTextStyles.interBoldStyle700(
                  fontColor: _isOTPComplete && !_isVerifying
                      ? AppColors.black
                      : AppColors.white,
                  fontSize: 16,
                ),
                text: AppStrings.verifyOTP,
                onPressed: _isOTPComplete && !_isVerifying ? _verifyOTP : null,
                isLoading: _isVerifying,
              ),

              const SizedBox(height: 16),

              // Resend OTP
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${AppStrings.didntReceiveCode} ',
                      style: AppTextStyles.interMediumStyle500(
                        fontSize: 14,
                        fontColor: AppColors.grey200,
                      ),
                    ),
                    GestureDetector(
                      onTap: (_resendCountdown <= 0 && !_isResending)
                          ? _resendOTP
                          : null,
                      child: _isResending
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primary),
                              ),
                            )
                          : Text(
                              _resendCountdown > 0
                                  ? AppStrings.resendOTPInSeconds(
                                      _resendCountdown)
                                  : AppStrings.resendOTP,
                              style: AppTextStyles.interMediumStyle500(
                                fontSize: 14,
                                fontColor: _resendCountdown > 0
                                    ? AppColors.grey700
                                    : AppColors.secondaryCTA,
                              ),
                            ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Cat illustration
              if (!isKeyboardVisible)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ShaderMask(
                    shaderCallback: (rect) => const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.5065, 1.0],
                      colors: [Colors.white, Colors.transparent],
                    ).createShader(rect),
                    blendMode: BlendMode.dstIn,
                    child: Image.asset(
                      AppIcons.otpCatIcon,
                      height: 295,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
