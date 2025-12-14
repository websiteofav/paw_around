import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthState extends Equatable {
  final bool isPasswordVisible;

  const AuthState({this.isPasswordVisible = false});

  @override
  List<Object?> get props => [isPasswordVisible];
}

class AuthInitial extends AuthState {
  const AuthInitial() : super(isPasswordVisible: false);
}

class AuthLoading extends AuthState {
  const AuthLoading({required super.isPasswordVisible});
}

class AuthPasswordVisibilityToggled extends AuthState {
  const AuthPasswordVisibilityToggled({required super.isPasswordVisible});
}

class Authenticated extends AuthState {
  final User user;

  const Authenticated({
    required this.user,
    super.isPasswordVisible = false,
  });

  @override
  List<Object?> get props => [user, isPasswordVisible];
}

class Unauthenticated extends AuthState {
  const Unauthenticated({super.isPasswordVisible = false});
}

class AuthSuccess extends AuthState {
  final String? message;

  const AuthSuccess({
    this.message,
    required super.isPasswordVisible,
  });

  @override
  List<Object?> get props => [message, isPasswordVisible];
}

class AuthError extends AuthState {
  final String errorMessage;

  const AuthError({
    required this.errorMessage,
    required super.isPasswordVisible,
  });

  @override
  List<Object?> get props => [errorMessage, isPasswordVisible];
}
