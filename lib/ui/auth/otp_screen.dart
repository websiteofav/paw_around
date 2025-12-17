import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/ui/auth/widgets/otp_input_field.dart';

class OTPScreen extends StatefulWidget {
  final String phoneNumber;

  const OTPScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  TextEditingController? _otpController;
  bool _isOTPComplete = false;
  bool _isVerifying = false;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController();
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
    if (!_isOTPComplete) {
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    // TODO: Implement actual Firebase Phone Auth verification
    // For now, simulate a delay and navigate to home
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      _isNavigating = true;
      // Navigate to home on success
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.go(AppRoutes.home);
        }
      });
    }
  }

  void _resendOTP() {
    // TODO: Implement resend OTP logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(AppStrings.otpSentSuccessfully),
        backgroundColor: AppColors.success,
      ),
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
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Back Button
              IconButton(
                onPressed: () => context.pop(),
                icon: Icon(
                  Icons.arrow_back,
                  color: AppColors.textPrimary,
                  size: 24,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),

              const SizedBox(height: 32),

              // Title
              Text(
                AppStrings.verifyYourNumber,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 8),

              // Subtitle with masked phone
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                  children: [
                    TextSpan(text: '${AppStrings.otpSentTo} '),
                    TextSpan(
                      text: _maskedPhoneNumber,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Enter Code Label
              Text(
                AppStrings.enterCode,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
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
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _isOTPComplete ? AppColors.white : AppColors.textSecondary,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),

              // Resend OTP
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '${AppStrings.didntReceiveCode} ',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: _resendOTP,
                      child: const Text(
                        AppStrings.resendOTP,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
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
