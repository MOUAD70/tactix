/// Failure classes used by state notifiers to represent error state.
///
/// These are intentionally simple wrappers that can be shown in UI.
library;

abstract class Failure {
  const Failure(this.message);

  final String message;
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Something went wrong']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Unable to connect. Please check your internet connection.']);
}

class AuthenticationFailure extends Failure {
  const AuthenticationFailure([super.message = 'Authentication failed. Please login again.']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {this.errors});

  final Map<String, dynamic>? errors;
}
