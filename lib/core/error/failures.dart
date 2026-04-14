import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network connection unavailable.']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed.']);
}

class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'You do not have permission for this action.']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Provided data is invalid.']);
}

class StorageFailure extends Failure {
  const StorageFailure([super.message = 'Storage operation failed.']);
}

class DatabaseFailure extends Failure {
  const DatabaseFailure([super.message = 'Database operation failed.']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Something went wrong. Please try again.']);
}
