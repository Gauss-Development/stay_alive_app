import 'package:equatable/equatable.dart';
import 'package:stay_alive/features/user/domain/entities/user_profile.dart';

abstract class UserProfileState extends Equatable {
  const UserProfileState();

  @override
  List<Object?> get props => <Object?>[];
}

class UserProfileInitial extends UserProfileState {
  const UserProfileInitial();
}

class UserProfileLoading extends UserProfileState {
  const UserProfileLoading();
}

class UserProfileLoaded extends UserProfileState {
  const UserProfileLoaded(this.profile);

  final UserProfile profile;

  @override
  List<Object?> get props => <Object?>[profile];
}

class UserProfileError extends UserProfileState {
  const UserProfileError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
