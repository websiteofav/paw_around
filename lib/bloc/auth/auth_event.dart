abstract class AuthEvent {}

class TogglePasswordVisibility extends AuthEvent {}

class LoginWithEmail extends AuthEvent {
  final String email;
  final String password;

  LoginWithEmail({required this.email, required this.password});
}

class LoginWithGoogle extends AuthEvent {}

class LoginWithApple extends AuthEvent {}

class ForgotPassword extends AuthEvent {
  final String email;

  ForgotPassword({required this.email});
}

class SignupWithEmail extends AuthEvent {
  final String fullName;
  final String email;
  final String password;
  final String confirmPassword;

  SignupWithEmail({
    required this.fullName,
    required this.email,
    required this.password,
    required this.confirmPassword,
  });
}
