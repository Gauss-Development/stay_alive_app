import 'package:equatable/equatable.dart';
import 'package:stay_alive/features/subscription/domain/entities/subscription_info.dart';
import 'package:stay_alive/features/subscription/domain/entities/subscription_offering.dart';

enum SubscriptionStatus {
  initial,
  loading,
  loaded,
  purchasing,
  restoring,
  error,
}

class SubscriptionState extends Equatable {
  const SubscriptionState({
    required this.status,
    this.info = const SubscriptionInfo.free(),
    this.offering = const SubscriptionOffering.empty(),
    this.errorMessage,
    this.selectedPackageId,
  });

  const SubscriptionState.initial()
      : status = SubscriptionStatus.initial,
        info = const SubscriptionInfo.free(),
        offering = const SubscriptionOffering.empty(),
        errorMessage = null,
        selectedPackageId = null;

  final SubscriptionStatus status;
  final SubscriptionInfo info;
  final SubscriptionOffering offering;
  final String? errorMessage;
  final String? selectedPackageId;

  bool get isPremiumActive => info.isPremiumActive;

  SubscriptionState copyWith({
    SubscriptionStatus? status,
    SubscriptionInfo? info,
    SubscriptionOffering? offering,
    String? errorMessage,
    String? selectedPackageId,
    bool clearError = false,
  }) {
    return SubscriptionState(
      status: status ?? this.status,
      info: info ?? this.info,
      offering: offering ?? this.offering,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      selectedPackageId: selectedPackageId ?? this.selectedPackageId,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        status,
        info,
        offering,
        errorMessage,
        selectedPackageId,
      ];
}
