import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  const AuthUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.emailVerified,
    required this.preferences,
  });

  final String id;
  final String email;
  final String displayName;
  final bool emailVerified;
  final Map<String, dynamic> preferences;

  bool get onboardingCompleted =>
      preferences['onboardingCompleted'] as bool? ?? false;

  @override
  List<Object?> get props => <Object?>[
        id,
        email,
        displayName,
        emailVerified,
        preferences,
      ];
}
