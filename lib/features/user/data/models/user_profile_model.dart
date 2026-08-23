import 'package:stay_alive/features/user/domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.email,
    required super.displayName,
    super.age,
    super.gender,
    super.preferredDiet,
    super.heightCm,
    super.weightKg,
    super.onboardingCompleted,
    super.unitsPreference,
    super.locale,
    super.createdAt,
    super.updatedAt,
  });

  factory UserProfileModel.fromRow(Map<String, dynamic> row) {
    return UserProfileModel.fromData(
      id: row['id']?.toString() ?? '',
      data: row,
    );
  }

  factory UserProfileModel.fromData({
    required String id,
    required Map<String, dynamic> data,
    String? createdAt,
    String? updatedAt,
  }) {
    return UserProfileModel(
      id: id,
      email: data['email']?.toString() ?? '',
      displayName: _readString(
        data['display_name'] ?? data['name'],
        fallback: '',
      ),
      age: _readOptionalInt(data['age']),
      gender: _readOptionalString(data['gender']),
      preferredDiet: _readOptionalString(
        data['preferred_diet'] ?? data['preferredDiet'],
      ),
      heightCm: _readOptionalInt(data['height_cm'] ?? data['heightCm']),
      weightKg: _readOptionalDouble(data['weight_kg'] ?? data['weightKg']),
      onboardingCompleted:
          (data['onboarding_completed'] ?? data['onboardingCompleted']) == true,
      unitsPreference: _readOptionalString(
        data['units_preference'] ?? data['unitsPreference'],
      ),
      locale: _readOptionalString(data['locale']),
      createdAt: DateTime.tryParse(
        _readString(data['created_at'], fallback: createdAt ?? ''),
      ),
      updatedAt: DateTime.tryParse(
        _readString(data['updated_at'], fallback: updatedAt ?? ''),
      ),
    );
  }

  static String _readString(dynamic value, {required String fallback}) {
    if (value == null) {
      return fallback;
    }
    final String text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  static String? _readOptionalString(dynamic value) {
    if (value == null) {
      return null;
    }
    final String s = value.toString();
    return s.isEmpty ? null : s;
  }

  static int? _readOptionalInt(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return null;
  }

  static double? _readOptionalDouble(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is double) {
      return value;
    }
    if (value is int) {
      return value.toDouble();
    }
    if (value is num) {
      return value.toDouble();
    }
    return null;
  }
}
