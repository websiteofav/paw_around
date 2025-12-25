import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paw_around/services/auth_error_interceptor.dart';

/// Global BlocObserver that handles unauthorized errors across all blocs
class AuthBlocObserver extends BlocObserver {
  final AuthErrorInterceptor _authInterceptor = AuthErrorInterceptor();

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);

    // Check for unauthorized errors globally and logout if detected
    if (_authInterceptor.isUnauthorizedError(error)) {
      _authInterceptor.handleUnauthorizedError();
    }
  }
}
