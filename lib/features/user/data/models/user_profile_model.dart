import 'package:appwrite/models.dart' as appwrite_models;
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

  factory UserProfileModel.fromDocument(appwrite_models.Document document) {
    final Map<String, dynamic> m = document.data;

    return UserProfileModel(
      id: document.$id,
      email: m['email']?.toString() ?? '',
      displayName: _readString(
        m['display_name'] ?? m['name'],
        fallback: '',
      ),
      age: _readOptionalInt(m['age']),
      gender: _readOptionalString(m['gender']),
      preferredDiet: _readOptionalString(
        m['preferred_diet'] ?? m['preferredDiet'],
      ),
      heightCm: _readOptionalInt(m['height_cm'] ?? m['heightCm']),
      weightKg: _readOptionalDouble(m['weight_kg'] ?? m['weightKg']),
      onboardingCompleted:
          (m['onboarding_completed'] ?? m['onboardingCompleted']) == true,
      unitsPreference: _readOptionalString(
        m['units_preference'] ?? m['unitsPreference'],
      ),
      locale: _readOptionalString(m['locale']),
      createdAt: DateTime.tryParse(
        _readString(m['created_at'], fallback: document.$createdAt),
      ),
      updatedAt: DateTime.tryParse(
        _readString(m['updated_at'], fallback: document.$updatedAt),
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
