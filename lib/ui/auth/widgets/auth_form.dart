import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/ui/widgets/common_text_field.dart';
import 'package:paw_around/bloc/auth/auth_bloc.dart';
import 'package:paw_around/bloc/auth/auth_event.dart';
import 'package:paw_around/bloc/auth/auth_state.dart';

enum AuthType { login, signup }

class AuthForm extends StatefulWidget {
  final AuthType authType;
  final VoidCallback? onSuccess;

  const AuthForm({
    super.key,
    required this.authType,
    this.onSuccess,
  });

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Input Fields
        _buildInputFields(),

        const SizedBox(height: 24),

        // Submit Button
        _buildSubmitButton(),
      ],
    );
  }

  Widget _buildInputFields() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return Column(
          children: [
            // Full Name Field (only for signup)
            if (widget.authType == AuthType.signup) ...[
              CommonTextField(
                controller: _fullNameController,
                hintText: AppStrings.fullName,
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 16),
            ],

            // Email Field
            CommonTextField(
              controller: _emailController,
              hintText: AppStrings.emailAddress,
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 16),

            // Password Field
            CommonTextField(
              controller: _passwordController,
              hintText: AppStrings.password,
              isPassword: true,
              isPasswordVisible: state.isPasswordVisible,
              forgotPasswordText: widget.authType == AuthType.login ? AppStrings.forgotPassword : null,
              onForgotPasswordPressed: widget.authType == AuthType.login
                  ? () {
                      context.read<AuthBloc>().add(
                            ForgotPassword(email: _emailController.text),
                          );
                    }
                  : null,
              onToggleVisibility: () {
                context.read<AuthBloc>().add(TogglePasswordVisibility());
              },
            ),

            // Confirm Password Field (only for signup)
            if (widget.authType == AuthType.signup) ...[
              const SizedBox(height: 16),
              CommonTextField(
                controller: _confirmPasswordController,
                hintText: AppStrings.confirmPassword,
                isPassword: true,
                isPasswordVisible: state.isPasswordVisible,
                onToggleVisibility: () {
                  context.read<AuthBloc>().add(TogglePasswordVisibility());
                },
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildSubmitButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: state is AuthLoading ? null : _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: state is AuthLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    widget.authType == AuthType.login ? AppStrings.logIn : 'Sign Up',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        );
      },
    );
  }

  void _handleSubmit() {
    if (widget.authType == AuthType.login) {
      context.read<AuthBloc>().add(
            LoginWithEmail(
              email: _emailController.text,
              password: _passwordController.text,
            ),
          );
    } else {
      context.read<AuthBloc>().add(
            SignupWithEmail(
              fullName: _fullNameController.text,
              email: _emailController.text,
              password: _passwordController.text,
              confirmPassword: _confirmPasswordController.text,
            ),
          );
    }
  }
}
