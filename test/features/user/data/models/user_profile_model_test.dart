import 'package:flutter_test/flutter_test.dart';
import 'package:stay_alive/features/user/data/models/user_profile_model.dart';

void main() {
  group('UserProfileModel.fromData', () {
    test('maps snake_case profile row data', () {
      final UserProfileModel profile = UserProfileModel.fromData(
        id: 'user_1',
        data: <String, dynamic>{
          'email': 'user@example.com',
          'display_name': 'Healthy User',
          'onboarding_completed': true,
          'units_preference': 'metric',
          'preferred_diet': 'whole_food_plant_based',
          'height_cm': 172,
          'weight_kg': 68.5,
          'age': 35,
          'locale': 'en',
        },
        createdAt: '2026-05-01T00:00:00Z',
        updatedAt: '2026-05-06T00:00:00Z',
      );

      expect(profile.id, 'user_1');
      expect(profile.email, 'user@example.com');
      expect(profile.displayName, 'Healthy User');
      expect(profile.onboardingCompleted, isTrue);
      expect(profile.unitsPreference, 'metric');
      expect(profile.preferredDiet, 'whole_food_plant_based');
      expect(profile.heightCm, 172);
      expect(profile.weightKg, 68.5);
      expect(profile.age, 35);
      expect(profile.createdAt, DateTime.parse('2026-05-01T00:00:00Z'));
      expect(profile.updatedAt, DateTime.parse('2026-05-06T00:00:00Z'));
    });

    test('keeps optional health fields nullable for new auth users', () {
      final UserProfileModel profile = UserProfileModel.fromData(
        id: 'user_2',
        data: <String, dynamic>{
          'email': 'new@example.com',
          'display_name': 'New User',
        },
        createdAt: '',
        updatedAt: '',
      );

      expect(profile.displayName, 'New User');
      expect(profile.age, isNull);
      expect(profile.weightKg, isNull);
      expect(profile.heightCm, isNull);
      expect(profile.onboardingCompleted, isFalse);
    });
  });
}
