import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/core/error/error_handler.dart';
import 'package:paw_around/ui/widgets/common_text_field.dart';
import 'package:paw_around/bloc/auth/auth_bloc.dart';
import 'package:paw_around/bloc/auth/auth_event.dart';
import 'package:paw_around/bloc/auth/auth_state.dart';
import 'package:paw_around/utils/validators.dart';

enum AuthType { login, signup }

class AuthForm extends StatefulWidget {
  final AuthType authType;

  const AuthForm({
    super.key,
    required this.authType,
  });

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          context.go(AppRoutes.home);
        } else if (state is AuthError) {
          ErrorHandler.handleError(
            context,
            AuthFailure(state.errorMessage),
          );
        } else if (state is AuthSuccess && state.message != null) {
          ErrorHandler.showSuccess(context, state.message!);
        }
      },
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildInputFields(),
            const SizedBox(height: 24),
            _buildSubmitButton(),
          ],
        ),
      ),
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
                validator: Validators.fullName,
              ),
              const SizedBox(height: 16),
            ],

            // Email Field
            CommonTextField(
              controller: _emailController,
              hintText: AppStrings.emailAddress,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.email,
            ),

            const SizedBox(height: 16),

            // Password Field
            CommonTextField(
              controller: _passwordController,
              hintText: AppStrings.password,
              isPassword: true,
              isPasswordVisible: state.isPasswordVisible,
              onToggleVisibility: () {
                context.read<AuthBloc>().add(TogglePasswordVisibility());
              },
              validator: widget.authType == AuthType.signup
                  ? Validators.password
                  : (value) => Validators.required(value, 'Password'),
            ),

            // Forgot Password (only for login)
            if (widget.authType == AuthType.login) ...[
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    if (_emailController.text.trim().isEmpty) {
                      ErrorHandler.handleError(
                        context,
                        const AuthFailure('Please enter your email first'),
                      );
                      return;
                    }
                    context.read<AuthBloc>().add(
                          ForgotPassword(email: _emailController.text),
                        );
                  },
                  child: Text(
                    AppStrings.forgotPassword,
                    style: AppTextStyles.bodyText.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              ),
            ],

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
                validator: (value) => Validators.confirmPassword(value, _passwordController.text),
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
                    widget.authType == AuthType.login ? AppStrings.logIn : AppStrings.signUp,
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
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (widget.authType == AuthType.login) {
      context.read<AuthBloc>().add(
            LoginWithEmail(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    } else {
      context.read<AuthBloc>().add(
            SignupWithEmail(
              fullName: _fullNameController.text.trim(),
              email: _emailController.text.trim(),
              password: _passwordController.text,
              confirmPassword: _confirmPasswordController.text,
            ),
          );
    }
  }
}
