import 'package:appwrite/models.dart' as appwrite_models;
import 'package:stay_alive/features/user/domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.email,
    required super.name,
    required super.age,
    super.gender,
    super.preferredDiet,
    super.heightCm,
    required super.weightKg,
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
      name: m['name']?.toString() ?? '',
      age: _readInt(m['age'], field: 'age'),
      gender: _readOptionalString(m['gender']),
      preferredDiet: _readOptionalString(m['preferredDiet']),
      heightCm: _readOptionalInt(m['heightCm']),
      weightKg: _readDouble(m['weightKg'], field: 'weightKg'),
      onboardingCompleted: m['onboardingCompleted'] == true,
      unitsPreference: _readOptionalString(m['unitsPreference']),
      locale: _readOptionalString(m['locale']),
      createdAt: DateTime.tryParse(document.$createdAt),
      updatedAt: DateTime.tryParse(document.$updatedAt),
    );
  }

  static String? _readOptionalString(dynamic value) {
    if (value == null) {
      return null;
    }
    final String s = value.toString();
    return s.isEmpty ? null : s;
  }

  static int _readInt(dynamic value, {required String field}) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    throw FormatException('Invalid int for $field: $value');
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

  static double _readDouble(dynamic value, {required String field}) {
    if (value is double) {
      return value;
    }
    if (value is int) {
      return value.toDouble();
    }
    if (value is num) {
      return value.toDouble();
    }
    throw FormatException('Invalid double for $field: $value');
  }
}
