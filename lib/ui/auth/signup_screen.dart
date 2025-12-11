import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/ui/auth/widgets/auth_header_generic.dart';
import 'package:paw_around/ui/auth/widgets/social_login_buttons.dart';
import 'package:paw_around/ui/auth/widgets/auth_separator.dart';
import 'package:paw_around/ui/auth/widgets/auth_form.dart';
import 'package:paw_around/ui/auth/widgets/auth_footer_generic.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.authBackground,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 60),

                // Header (Logo, App Name, Create Account Title)
                AuthHeaderGeneric(headerType: AuthHeaderType.signup),

                SizedBox(height: 40),

                // Auth Form (Input Fields and Submit Button)
                AuthForm(authType: AuthType.signup),

                SizedBox(height: 24),

                // Separator
                AuthSeparator(),

                SizedBox(height: 24),

                // Social Login Buttons
                SocialLoginButtons(),

                // Footer (Log In Link)
                AuthFooterGeneric(footerType: AuthFooterType.signup),

                SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
