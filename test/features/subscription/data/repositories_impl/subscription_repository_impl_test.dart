import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stay_alive/core/error/failures.dart';
import 'package:stay_alive/features/subscription/data/datasources/revenue_cat_subscription_data_source.dart';
import 'package:stay_alive/features/subscription/data/repositories_impl/subscription_repository_impl.dart';
import 'package:stay_alive/features/subscription/domain/entities/subscription_info.dart';
import 'package:stay_alive/features/subscription/domain/entities/subscription_offering.dart';

class _MockSubscriptionRemoteDataSource extends Mock
    implements SubscriptionRemoteDataSource {}

void main() {
  late _MockSubscriptionRemoteDataSource dataSource;
  late SubscriptionRepositoryImpl repository;

  setUp(() {
    dataSource = _MockSubscriptionRemoteDataSource();
    repository = SubscriptionRepositoryImpl(dataSource);
  });

  test('returns subscription info when datasource succeeds', () async {
    when(dataSource.getSubscriptionInfo).thenAnswer(
      (_) async => const SubscriptionInfo.free(),
    );

    final result = await repository.getSubscriptionInfo();

    expect(result.isRight(), isTrue);
    result.fold(
      (_) => fail('Expected subscription info'),
      (SubscriptionInfo info) => expect(info.isPremiumActive, isFalse),
    );
  });

  test('maps datasource errors to failures', () async {
    when(dataSource.getOffering).thenThrow(Exception('RevenueCat failed'));

    final result = await repository.getOffering();

    expect(result.isLeft(), isTrue);
    result.fold(
      (Failure failure) => expect(failure, isA<UnknownFailure>()),
      (SubscriptionOffering _) => fail('Expected failure'),
    );
  });
}
