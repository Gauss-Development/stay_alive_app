import 'package:equatable/equatable.dart';

/// Mirrors the Supabase `profiles` table columns.
class UserProfile extends Equatable {
  const UserProfile({
    required this.id,
    required this.email,
    required this.displayName,
    this.age,
    this.gender,
    this.preferredDiet,
    this.heightCm,
    this.weightKg,
    this.onboardingCompleted = false,
    this.unitsPreference,
    this.locale,
    this.createdAt,
    this.updatedAt,
  });

  /// Document `$id` (typically the same as the Auth user id).
  final String id;
  final String email;
  final String displayName;
  final int? age;
  final String? gender;
  final String? preferredDiet;
  final int? heightCm;
  final double? weightKg;
  final bool onboardingCompleted;
  final String? unitsPreference;
  final String? locale;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => <Object?>[
    id,
    email,
    displayName,
    age,
    gender,
    preferredDiet,
    heightCm,
    weightKg,
    onboardingCompleted,
    unitsPreference,
    locale,
    createdAt,
    updatedAt,
  ];
}
