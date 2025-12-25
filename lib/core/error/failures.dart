abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// Failure for unauthorized/unauthenticated errors (401, permission-denied, etc.)
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([String message = 'Session expired. Please login again.']) : super(message);
}
