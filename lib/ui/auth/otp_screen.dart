import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/core/di/service_locator.dart';
import 'package:paw_around/repositories/auth_repository.dart';
import 'package:paw_around/ui/auth/widgets/otp_input_field.dart';

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
  TextEditingController? _otpController;
  bool _isOTPComplete = false;
  bool _isVerifying = false;
  bool _isNavigating = false;
  bool _isResending = false;
  late String _verificationId;

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController();
    _verificationId = widget.verificationId;
  }

  String get _maskedPhoneNumber {
    if (widget.phoneNumber.length < 4) {
      return widget.phoneNumber;
    }
    final lastFour = widget.phoneNumber.substring(widget.phoneNumber.length - 4);
    return '+${'•' * (widget.phoneNumber.length - 5)}$lastFour';
  }

  void _onOTPChanged(String value) {
    setState(() {
      _isOTPComplete = value.length == 6;
    });
  }

  void _onOTPCompleted(String value) {
    setState(() {
      _isOTPComplete = true;
    });
  }

  Future<void> _verifyOTP() async {
    if (!_isOTPComplete || _otpController == null) {
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    try {
      await sl<AuthRepository>().signInWithOTP(
        verificationId: _verificationId,
        smsCode: _otpController!.text,
      );

      if (mounted) {
        _isNavigating = true;
        context.go(AppRoutes.home);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(sl<AuthRepository>().getAuthErrorMessage(e)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
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
    if (_isResending) {
      return;
    }

    setState(() {
      _isResending = true;
    });

    await sl<AuthRepository>().verifyPhoneNumber(
      phoneNumber: widget.phoneNumber,
      onCodeSent: (verificationId) {
        if (mounted) {
          setState(() {
            _verificationId = verificationId;
            _isResending = false;
          });
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
          setState(() {
            _isResending = false;
          });
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
            _isNavigating = true;
            context.go(AppRoutes.home);
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              _isResending = false;
            });
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
    if (!_isNavigating) {
      _otpController?.dispose();
    }
    _otpController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.authBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              GestureDetector(
                onTap: () => context.pop(),
                child: const Icon(
                  Icons.arrow_back,
                  color: AppColors.textPrimary,
                  size: 24,
                ),
              ),

              const SizedBox(height: 32),

              // Title
              Text(
                AppStrings.verifyYourNumber,
                style: AppTextStyles.boldStyle700(fontSize: 28, fontColor: AppColors.textPrimary),
              ),

              const SizedBox(height: 8),

              // Subtitle with masked phone
              RichText(
                text: TextSpan(
                  style: AppTextStyles.regularStyle400(fontSize: 16, fontColor: AppColors.textSecondary),
                  children: [
                    TextSpan(
                        text: '${AppStrings.otpSentTo} ',
                        style: AppTextStyles.regularStyle400(fontSize: 16, fontColor: AppColors.textSecondary)),
                    TextSpan(
                      text: _maskedPhoneNumber,
                      style: AppTextStyles.mediumStyle500(fontSize: 16, fontColor: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Enter Code Label
              Text(
                AppStrings.enterCode,
                style: AppTextStyles.mediumStyle500(fontSize: 14, fontColor: AppColors.textPrimary),
              ),

              const SizedBox(height: 16),

              // OTP Input
              if (_otpController != null)
                OTPInputField(
                  controller: _otpController!,
                  onChanged: _onOTPChanged,
                  onCompleted: _onOTPCompleted,
                ),

              const SizedBox(height: 24),

              // Verify Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isOTPComplete && !_isVerifying ? _verifyOTP : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.border,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _isVerifying
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                          ),
                        )
                      : Text(
                          AppStrings.verify,
                          style: AppTextStyles.semiBoldStyle600(
                              fontSize: 16, fontColor: _isOTPComplete ? AppColors.white : AppColors.textSecondary),
                        ),
                ),
              ),

              const SizedBox(height: 24),

              // Resend OTP
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${AppStrings.didntReceiveCode} ',
                      style: AppTextStyles.regularStyle400(fontSize: 14, fontColor: AppColors.textSecondary),
                    ),
                    GestureDetector(
                      onTap: _isResending ? null : _resendOTP,
                      child: _isResending
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                              ),
                            )
                          : Text(
                              AppStrings.resendOTP,
                              style: AppTextStyles.mediumStyle500(fontSize: 14, fontColor: AppColors.primary),
                            ),
                    ),
                  ],
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
