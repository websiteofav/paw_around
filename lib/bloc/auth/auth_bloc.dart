import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paw_around/bloc/auth/auth_event.dart';
import 'package:paw_around/bloc/auth/auth_state.dart';
import 'package:paw_around/constants/analytics_constants.dart';
import 'package:paw_around/repositories/auth_repository.dart';
import 'package:paw_around/core/di/service_locator.dart';
import 'package:paw_around/repositories/user_repository.dart';
import 'package:paw_around/services/analytics_service.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<User?>? _authSubscription;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<RefreshUserProfile>(_onRefreshUserProfile);
    on<TogglePasswordVisibility>(_onTogglePasswordVisibility);
    on<LoginWithEmail>(_onLoginWithEmail);
    on<SignupWithEmail>(_onSignupWithEmail);
    on<ForgotPassword>(_onForgotPassword);
    on<SignOut>(_onSignOut);
    on<LoginWithGoogle>(_onLoginWithGoogle);

    // Listen to auth state changes
    _authSubscription = _authRepository.authStateChanges.listen((user) {
      add(CheckAuthStatus());
    });
  }

  Future<void> _onCheckAuthStatus(
      CheckAuthStatus event, Emitter<AuthState> emit) async {
    final user = _authRepository.currentUser;
    if (user != null) {
      final profile = await sl<UserRepository>().getProfile(user.uid);
      emit(Authenticated(
        user: user,
        profile: profile,
        isPasswordVisible: state.isPasswordVisible,
      ));
    } else {
      emit(Unauthenticated(isPasswordVisible: state.isPasswordVisible));
    }
  }

  Future<void> _onRefreshUserProfile(
      RefreshUserProfile event, Emitter<AuthState> emit) async {
    final user = _authRepository.currentUser;
    if (user == null) return;
    final profile = await sl<UserRepository>().getProfile(user.uid);
    emit(Authenticated(
      user: user,
      profile: profile,
      isPasswordVisible: state.isPasswordVisible,
    ));
  }

  void _onTogglePasswordVisibility(
      TogglePasswordVisibility event, Emitter<AuthState> emit) {
    emit(AuthPasswordVisibilityToggled(
        isPasswordVisible: !state.isPasswordVisible));
  }

  Future<void> _onLoginWithEmail(
      LoginWithEmail event, Emitter<AuthState> emit) async {
    emit(AuthLoading(isPasswordVisible: state.isPasswordVisible));

    try {
      await _authRepository.signInWithEmail(
        email: event.email.trim(),
        password: event.password,
      );
      // Auth state listener will emit Authenticated
    } on FirebaseAuthException catch (e) {
      emit(AuthError(
        errorMessage: _authRepository.getAuthErrorMessage(e),
        isPasswordVisible: state.isPasswordVisible,
      ));
    } catch (e) {
      emit(AuthError(
        errorMessage: 'An unexpected error occurred. Please try again.',
        isPasswordVisible: state.isPasswordVisible,
      ));
    }
  }

  Future<void> _onSignupWithEmail(
      SignupWithEmail event, Emitter<AuthState> emit) async {
    // Validate passwords match

    emit(AuthLoading(isPasswordVisible: state.isPasswordVisible));

    try {
      await _authRepository.signUpWithEmail(
        email: event.email.trim(),
        password: event.password,
      );

      // Update display name
      if (event.fullName.isNotEmpty) {
        await _authRepository.updateDisplayName(event.fullName.trim());
      }
      // Auth state listener will emit Authenticated
    } on FirebaseAuthException catch (e) {
      emit(AuthError(
        errorMessage: _authRepository.getAuthErrorMessage(e),
        isPasswordVisible: state.isPasswordVisible,
      ));
    } catch (e) {
      emit(AuthError(
        errorMessage: 'An unexpected error occurred. Please try again.',
        isPasswordVisible: state.isPasswordVisible,
      ));
    }
  }

  Future<void> _onForgotPassword(
      ForgotPassword event, Emitter<AuthState> emit) async {
    emit(AuthLoading(isPasswordVisible: state.isPasswordVisible));

    try {
      await _authRepository.sendPasswordResetEmail(event.email.trim());
      emit(AuthSuccess(
        message: 'Password reset email sent. Please check your inbox.',
        isPasswordVisible: state.isPasswordVisible,
      ));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(
        errorMessage: _authRepository.getAuthErrorMessage(e),
        isPasswordVisible: state.isPasswordVisible,
      ));
    } catch (e) {
      emit(AuthError(
        errorMessage: 'Failed to send reset email. Please try again.',
        isPasswordVisible: state.isPasswordVisible,
      ));
    }
  }

  Future<void> _onSignOut(SignOut event, Emitter<AuthState> emit) async {
    AnalyticsService.logEvent(name: AnalyticsEvents.logout);
    await _authRepository.signOut();
    // Auth state listener will emit Unauthenticated
  }

  Future<void> _onLoginWithGoogle(
      LoginWithGoogle event, Emitter<AuthState> emit) async {
    emit(AuthLoading(isPasswordVisible: state.isPasswordVisible));
    try {
      await _authRepository.signInWithGoogle();
      AnalyticsService.logEvent(
        name: AnalyticsEvents.loginSuccess,
        parameters: {AnalyticsParams.method: 'google'},
      );
      // Auth state listener will emit Authenticated
    } catch (e) {
      AnalyticsService.logEvent(
        name: AnalyticsEvents.loginFailed,
        parameters: {
          AnalyticsParams.method: 'google',
          AnalyticsParams.error: e.toString(),
        },
      );
      emit(AuthError(
        errorMessage: e.toString().replaceAll('Exception: ', ''),
        isPasswordVisible: state.isPasswordVisible,
      ));
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
