import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  const UserProfile({
    required this.userId,
    required this.email,
    required this.displayName,
    required this.onboardingCompleted,
    required this.unitsPreference,
    required this.locale,
  });

  final String userId;
  final String email;
  final String displayName;
  final bool onboardingCompleted;
  final String unitsPreference;
  final String locale;

  @override
  List<Object?> get props => <Object?>[
        userId,
        email,
        displayName,
        onboardingCompleted,
        unitsPreference,
        locale,
      ];
}
