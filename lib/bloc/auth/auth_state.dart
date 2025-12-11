abstract class AuthState {
  final bool isPasswordVisible;

  const AuthState({this.isPasswordVisible = false});
}

class AuthInitial extends AuthState {
  const AuthInitial() : super(isPasswordVisible: false);
}

class AuthPasswordVisibilityToggled extends AuthState {
  const AuthPasswordVisibilityToggled({required super.isPasswordVisible});
}

class AuthLoading extends AuthState {
  const AuthLoading({required super.isPasswordVisible});
}

class AuthSuccess extends AuthState {
  const AuthSuccess({required super.isPasswordVisible});
}

class AuthFailure extends AuthState {
  final String errorMessage;

  const AuthFailure({
    required this.errorMessage,
    required super.isPasswordVisible,
  });
}
