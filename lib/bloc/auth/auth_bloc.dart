import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthInitial()) {
    on<TogglePasswordVisibility>(_onTogglePasswordVisibility);
    on<LoginWithEmail>(_onLoginWithEmail);
    on<LoginWithGoogle>(_onLoginWithGoogle);
    on<LoginWithApple>(_onLoginWithApple);
    on<ForgotPassword>(_onForgotPassword);
    on<SignupWithEmail>(_onSignupWithEmail);
  }

  void _onTogglePasswordVisibility(
    TogglePasswordVisibility event,
    Emitter<AuthState> emit,
  ) {
    emit(AuthPasswordVisibilityToggled(
      isPasswordVisible: !state.isPasswordVisible,
    ));
  }

  void _onLoginWithEmail(
    LoginWithEmail event,
    Emitter<AuthState> emit,
  ) {
    emit(AuthLoading(isPasswordVisible: state.isPasswordVisible));

    // TODO: Implement actual email login logic
    // For now, simulate success after a delay
    Future.delayed(const Duration(seconds: 2), () {
      if (!isClosed) {
        emit(AuthSuccess(isPasswordVisible: state.isPasswordVisible));
      }
    });
  }

  void _onLoginWithGoogle(
    LoginWithGoogle event,
    Emitter<AuthState> emit,
  ) {
    emit(AuthLoading(isPasswordVisible: state.isPasswordVisible));

    // TODO: Implement Google login logic
    Future.delayed(const Duration(seconds: 2), () {
      if (!isClosed) {
        emit(AuthSuccess(isPasswordVisible: state.isPasswordVisible));
      }
    });
  }

  void _onLoginWithApple(
    LoginWithApple event,
    Emitter<AuthState> emit,
  ) {
    emit(AuthLoading(isPasswordVisible: state.isPasswordVisible));

    // TODO: Implement Apple login logic
    Future.delayed(const Duration(seconds: 2), () {
      if (!isClosed) {
        emit(AuthSuccess(isPasswordVisible: state.isPasswordVisible));
      }
    });
  }

  void _onForgotPassword(
    ForgotPassword event,
    Emitter<AuthState> emit,
  ) {
    emit(AuthLoading(isPasswordVisible: state.isPasswordVisible));

    // TODO: Implement forgot password logic
    Future.delayed(const Duration(seconds: 1), () {
      if (!isClosed) {
        emit(AuthSuccess(isPasswordVisible: state.isPasswordVisible));
      }
    });
  }

  void _onSignupWithEmail(
    SignupWithEmail event,
    Emitter<AuthState> emit,
  ) {
    emit(AuthLoading(isPasswordVisible: state.isPasswordVisible));

    // TODO: Implement signup logic
    // For now, simulate success after a delay
    Future.delayed(const Duration(seconds: 2), () {
      if (!isClosed) {
        emit(AuthSuccess(isPasswordVisible: state.isPasswordVisible));
      }
    });
  }
}
