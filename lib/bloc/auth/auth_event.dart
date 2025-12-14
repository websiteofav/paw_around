import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthStatus extends AuthEvent {}

class TogglePasswordVisibility extends AuthEvent {}

class LoginWithEmail extends AuthEvent {
  final String email;
  final String password;

  const LoginWithEmail({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class LoginWithGoogle extends AuthEvent {}

class LoginWithApple extends AuthEvent {}

class ForgotPassword extends AuthEvent {
  final String email;

  const ForgotPassword({required this.email});

  @override
  List<Object?> get props => [email];
}

class SignupWithEmail extends AuthEvent {
  final String fullName;
  final String email;
  final String password;
  final String confirmPassword;

  const SignupWithEmail({
    required this.fullName,
    required this.email,
    required this.password,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [fullName, email, password, confirmPassword];
}

class SignOut extends AuthEvent {}
