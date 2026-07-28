import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stay_alive/core/usecase/usecase.dart';
import 'package:stay_alive/features/subscription/domain/entities/subscription_package.dart';
import 'package:stay_alive/features/subscription/domain/usecases/get_subscription_offering_usecase.dart';
import 'package:stay_alive/features/subscription/domain/usecases/get_subscription_status_usecase.dart';
import 'package:stay_alive/features/subscription/domain/usecases/purchase_subscription_usecase.dart';
import 'package:stay_alive/features/subscription/domain/usecases/restore_purchases_usecase.dart';
import 'package:stay_alive/features/subscription/presentation/cubit/subscription_state.dart';

class SubscriptionCubit extends Cubit<SubscriptionState> {
  SubscriptionCubit({
    required GetSubscriptionStatusUseCase getSubscriptionStatusUseCase,
    required GetSubscriptionOfferingUseCase getSubscriptionOfferingUseCase,
    required PurchaseSubscriptionUseCase purchaseSubscriptionUseCase,
    required RestorePurchasesUseCase restorePurchasesUseCase,
  }) : _getSubscriptionStatusUseCase = getSubscriptionStatusUseCase,
       _getSubscriptionOfferingUseCase = getSubscriptionOfferingUseCase,
       _purchaseSubscriptionUseCase = purchaseSubscriptionUseCase,
       _restorePurchasesUseCase = restorePurchasesUseCase,
       super(const SubscriptionState.initial());

  final GetSubscriptionStatusUseCase _getSubscriptionStatusUseCase;
  final GetSubscriptionOfferingUseCase _getSubscriptionOfferingUseCase;
  final PurchaseSubscriptionUseCase _purchaseSubscriptionUseCase;
  final RestorePurchasesUseCase _restorePurchasesUseCase;

  Future<void> load() async {
    emit(
      state.copyWith(status: SubscriptionViewStatus.loading, clearError: true),
    );

    final statusResult = await _getSubscriptionStatusUseCase(const NoParams());
    await statusResult.fold(
      (failure) async => emit(
        state.copyWith(
          status: SubscriptionViewStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (info) async {
        final offeringResult = await _getSubscriptionOfferingUseCase(
          const NoParams(),
        );
        offeringResult.fold(
          (failure) => emit(
            state.copyWith(
              status: SubscriptionViewStatus.error,
              info: info,
              errorMessage: failure.message,
            ),
          ),
          (offering) => emit(
            state.copyWith(
              status: SubscriptionViewStatus.loaded,
              info: info,
              offering: offering,
              clearError: true,
            ),
          ),
        );
      },
    );
  }

  Future<void> refreshStatus() async {
    final statusResult = await _getSubscriptionStatusUseCase(const NoParams());
    statusResult.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (info) => emit(state.copyWith(info: info, clearError: true)),
    );
  }

  void selectPackage(String packageId) {
    emit(state.copyWith(selectedPackageId: packageId, clearError: true));
  }

  Future<void> purchaseSelectedPackage() async {
    final SubscriptionPackage? package = state.selectedPackage;
    if (package == null) return;
    await purchase(package);
  }

  Future<void> purchase(SubscriptionPackage package) async {
    if (state.status != SubscriptionViewStatus.loaded) {
      return;
    }

    emit(
      state.copyWith(
        status: SubscriptionViewStatus.purchasing,
        selectedPackageId: package.id,
        clearError: true,
      ),
    );
    final result = await _purchaseSubscriptionUseCase(
      PurchaseSubscriptionParams(packageId: package.id),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: SubscriptionViewStatus.loaded,
          errorMessage: failure.message,
        ),
      ),
      (info) => emit(
        state.copyWith(
          status: SubscriptionViewStatus.loaded,
          info: info,
          errorMessage: info.isPremiumActive
              ? 'Premium unlocked. Enjoy your full health statistics!'
              : 'Purchase completed, but premium is not active yet.',
        ),
      ),
    );
  }

  Future<void> restore() async {
    if (state.status != SubscriptionViewStatus.loaded) {
      return;
    }

    emit(
      state.copyWith(
        status: SubscriptionViewStatus.restoring,
        clearError: true,
      ),
    );
    final result = await _restorePurchasesUseCase(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: SubscriptionViewStatus.loaded,
          errorMessage: failure.message,
        ),
      ),
      (info) => emit(
        state.copyWith(
          status: SubscriptionViewStatus.loaded,
          info: info,
          errorMessage: info.isPremiumActive
              ? 'Purchases restored.'
              : 'No active premium subscription found.',
        ),
      ),
    );
  }
}
