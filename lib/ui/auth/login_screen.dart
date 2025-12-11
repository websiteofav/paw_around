import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/ui/auth/widgets/auth_header_generic.dart';
import 'package:paw_around/ui/auth/widgets/social_login_buttons.dart';
import 'package:paw_around/ui/auth/widgets/auth_separator.dart';
import 'package:paw_around/ui/auth/widgets/auth_form.dart';
import 'package:paw_around/ui/auth/widgets/auth_footer_generic.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
                // Header (Logo, App Name, Welcome Message)
                SizedBox(height: 60),
                AuthHeaderGeneric(headerType: AuthHeaderType.login),

                SizedBox(height: 40),

                // Social Login Buttons
                SocialLoginButtons(),

                SizedBox(height: 24),

                // Separator
                AuthSeparator(),

                SizedBox(height: 24),

                // Auth Form (Input Fields and Submit Button)
                AuthForm(authType: AuthType.login),

                // Footer (Sign Up Link)
                AuthFooterGeneric(footerType: AuthFooterType.login),

                SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
