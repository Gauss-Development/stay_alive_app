import 'package:flutter_test/flutter_test.dart';
import 'package:stay_alive/features/coach/domain/entities/coach_entities.dart';
import 'package:stay_alive/features/coach/domain/services/coach_local_fallback.dart';

void main() {
  test('local fallback nudge mentions incomplete category', () {
    const CoachContextPayload context = CoachContextPayload(
      level: 2,
      levelTitle: 'Sprout',
      streak: 2,
      activityStreak: 3,
      todayCompleted: 4,
      todayTarget: 24,
      incompleteCategories: <String>['greens', 'beans'],
      wilting: false,
    );

    final CoachResponse response = CoachLocalFallback.respond(
      mode: CoachMode.nudge,
      context: context,
    );

    expect(response.message, contains('greens'));
    expect(response.fromFallback, isTrue);
  });
}
