import 'package:equatable/equatable.dart';

class AuthSession extends Equatable {
  const AuthSession({
    required this.id,
    required this.userId,
    required this.provider,
    required this.expire,
  });

  final String id;
  final String userId;
  final String provider;
  final DateTime expire;

  @override
  List<Object?> get props => <Object?>[id, userId, provider, expire];
}
