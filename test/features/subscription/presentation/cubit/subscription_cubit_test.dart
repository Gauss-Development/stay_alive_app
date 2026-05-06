import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stay_alive/core/error/failures.dart';
import 'package:stay_alive/core/usecase/usecase.dart';
import 'package:stay_alive/features/subscription/domain/entities/subscription_info.dart';
import 'package:stay_alive/features/subscription/domain/entities/subscription_offering.dart';
import 'package:stay_alive/features/subscription/domain/entities/subscription_package.dart';
import 'package:stay_alive/features/subscription/domain/entities/subscription_plan.dart';
import 'package:stay_alive/features/subscription/domain/usecases/get_subscription_offering_usecase.dart';
import 'package:stay_alive/features/subscription/domain/usecases/get_subscription_status_usecase.dart';
import 'package:stay_alive/features/subscription/domain/usecases/purchase_subscription_usecase.dart';
import 'package:stay_alive/features/subscription/domain/usecases/restore_purchases_usecase.dart';
import 'package:stay_alive/features/subscription/presentation/cubit/subscription_cubit.dart';
import 'package:stay_alive/features/subscription/presentation/cubit/subscription_state.dart';

class _MockGetSubscriptionStatusUseCase extends Mock
    implements GetSubscriptionStatusUseCase {}

class _MockGetSubscriptionOfferingUseCase extends Mock
    implements GetSubscriptionOfferingUseCase {}

class _MockPurchaseSubscriptionUseCase extends Mock
    implements PurchaseSubscriptionUseCase {}

class _MockRestorePurchasesUseCase extends Mock
    implements RestorePurchasesUseCase {}

class _FakeNoParams extends Fake implements NoParams {}

class _FakePurchaseSubscriptionParams extends Fake
    implements PurchaseSubscriptionParams {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeNoParams());
    registerFallbackValue(_FakePurchaseSubscriptionParams());
  });

  late _MockGetSubscriptionStatusUseCase getStatusUseCase;
  late _MockGetSubscriptionOfferingUseCase getOfferingUseCase;
  late _MockPurchaseSubscriptionUseCase purchaseUseCase;
  late _MockRestorePurchasesUseCase restoreUseCase;

  const SubscriptionPackage monthlyPackage = SubscriptionPackage(
    id: 'monthly',
    plan: SubscriptionPlan.monthly,
    title: 'Monthly',
    description: 'Monthly stats',
    priceLabel: r'$15 / month',
    productIdentifier: 'premium_monthly',
  );
  const SubscriptionOffering offering = SubscriptionOffering(
    packages: <SubscriptionPackage>[monthlyPackage],
  );
  const SubscriptionInfo activeInfo = SubscriptionInfo(
    plan: SubscriptionPlan.monthly,
    status: SubscriptionStatus.active,
    productIdentifier: 'premium_monthly',
  );

  setUp(() {
    getStatusUseCase = _MockGetSubscriptionStatusUseCase();
    getOfferingUseCase = _MockGetSubscriptionOfferingUseCase();
    purchaseUseCase = _MockPurchaseSubscriptionUseCase();
    restoreUseCase = _MockRestorePurchasesUseCase();
  });

  SubscriptionCubit buildCubit() {
    return SubscriptionCubit(
      getSubscriptionStatusUseCase: getStatusUseCase,
      getSubscriptionOfferingUseCase: getOfferingUseCase,
      purchaseSubscriptionUseCase: purchaseUseCase,
      restorePurchasesUseCase: restoreUseCase,
    );
  }

  blocTest<SubscriptionCubit, SubscriptionState>(
    'loads free status and offering',
    build: () {
      when(() => getStatusUseCase(any())).thenAnswer(
        (_) async => const Right<Failure, SubscriptionInfo>(
          SubscriptionInfo.free(),
        ),
      );
      when(() => getOfferingUseCase(any())).thenAnswer(
        (_) async => const Right<Failure, SubscriptionOffering>(offering),
      );
      return buildCubit();
    },
    act: (SubscriptionCubit cubit) => cubit.load(),
    expect: () => <Matcher>[
      isA<SubscriptionState>().having(
        (SubscriptionState state) => state.status,
        'status',
        SubscriptionStatus.loading,
      ),
      isA<SubscriptionState>()
          .having(
            (SubscriptionState state) => state.status,
            'status',
            SubscriptionStatus.loaded,
          )
          .having(
            (SubscriptionState state) => state.offering,
            'offering',
            offering,
          ),
    ],
  );

  blocTest<SubscriptionCubit, SubscriptionState>(
    'updates info after a successful purchase',
    build: () {
      when(() => purchaseUseCase(any())).thenAnswer(
        (_) async => const Right<Failure, SubscriptionInfo>(activeInfo),
      );
      return buildCubit();
    },
    seed: () => const SubscriptionState(
      status: SubscriptionStatus.loaded,
      offering: offering,
    ),
    act: (SubscriptionCubit cubit) => cubit.purchase(monthlyPackage),
    expect: () => <Matcher>[
      isA<SubscriptionState>().having(
        (SubscriptionState state) => state.status,
        'status',
        SubscriptionStatus.purchasing,
      ),
      isA<SubscriptionState>()
          .having(
            (SubscriptionState state) => state.status,
            'status',
            SubscriptionStatus.loaded,
          )
          .having(
            (SubscriptionState state) => state.info,
            'info',
            activeInfo,
          ),
    ],
  );

  blocTest<SubscriptionCubit, SubscriptionState>(
    'emits error when status load fails',
    build: () {
      when(() => getStatusUseCase(any())).thenAnswer(
        (_) async => const Left<Failure, SubscriptionInfo>(
          NetworkFailure('RevenueCat unavailable'),
        ),
      );
      return buildCubit();
    },
    act: (SubscriptionCubit cubit) => cubit.load(),
    expect: () => <Matcher>[
      isA<SubscriptionState>().having(
        (SubscriptionState state) => state.status,
        'status',
        SubscriptionStatus.loading,
      ),
      isA<SubscriptionState>()
          .having(
            (SubscriptionState state) => state.status,
            'status',
            SubscriptionStatus.error,
          )
          .having(
            (SubscriptionState state) => state.errorMessage,
            'errorMessage',
            'RevenueCat unavailable',
          ),
    ],
  );
}
