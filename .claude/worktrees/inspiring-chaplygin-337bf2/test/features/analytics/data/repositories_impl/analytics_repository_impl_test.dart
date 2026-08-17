import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stay_alive/core/error/failures.dart';
import 'package:stay_alive/features/analytics/data/datasources/analytics_remote_data_source.dart';
import 'package:stay_alive/features/analytics/data/repositories_impl/analytics_repository_impl.dart';
import 'package:stay_alive/features/analytics/domain/entities/analytics_event.dart';

class _MockAnalyticsRemoteDataSource extends Mock
    implements AnalyticsRemoteDataSource {}

class _FakeAnalyticsEvent extends Fake implements AnalyticsEvent {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeAnalyticsEvent());
  });

  late _MockAnalyticsRemoteDataSource dataSource;
  late AnalyticsRepositoryImpl repository;

  final AnalyticsEvent event = AnalyticsEvent(
    name: 'daily_goal_incremented',
    screenName: 'home',
    metadata: const <String, dynamic>{'category_id': 'beans'},
    createdAt: DateTime.utc(2026, 5, 6),
  );

  setUp(() {
    dataSource = _MockAnalyticsRemoteDataSource();
    repository = AnalyticsRepositoryImpl(dataSource);
  });

  test('returns success when remote tracking succeeds', () async {
    when(() => dataSource.trackEvent(event)).thenAnswer((_) async {});

    final result = await repository.trackEvent(event);

    expect(result.isRight(), isTrue);
    verify(() => dataSource.trackEvent(event)).called(1);
  });

  test('maps remote tracking exceptions to failures', () async {
    when(() => dataSource.trackEvent(any())).thenThrow(Exception('boom'));

    final result = await repository.trackEvent(event);

    expect(result.isLeft(), isTrue);
    result.fold(
      (Failure failure) => expect(failure, isA<UnknownFailure>()),
      (_) => fail('Expected failure'),
    );
  });
}
