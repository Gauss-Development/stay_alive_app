import 'package:dartz/dartz.dart';
import 'package:stay_alive/core/error/appwrite_failure_mapper.dart';
import 'package:stay_alive/core/error/failures.dart';
import 'package:stay_alive/core/result/result.dart';
import 'package:stay_alive/features/subscription/data/datasources/revenue_cat_subscription_data_source.dart';
import 'package:stay_alive/features/subscription/domain/entities/subscription_info.dart';
import 'package:stay_alive/features/subscription/domain/entities/subscription_offering.dart';
import 'package:stay_alive/features/subscription/domain/repositories/subscription_repository.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  const SubscriptionRepositoryImpl(this._dataSource);

  final SubscriptionRemoteDataSource _dataSource;

  @override
  Future<Result<SubscriptionInfo>> getSubscriptionInfo() async {
    try {
      final SubscriptionInfo info = await _dataSource.getSubscriptionInfo();
      return Right<Failure, SubscriptionInfo>(info);
    } catch (exception) {
      return Left<Failure, SubscriptionInfo>(mapExceptionToFailure(exception));
    }
  }

  @override
  Future<Result<SubscriptionOffering>> getOffering() async {
    try {
      final SubscriptionOffering offering = await _dataSource.getOffering();
      return Right<Failure, SubscriptionOffering>(offering);
    } catch (exception) {
      return Left<Failure, SubscriptionOffering>(mapExceptionToFailure(exception));
    }
  }

  @override
  Future<Result<SubscriptionInfo>> purchasePackage(String packageId) async {
    try {
      final SubscriptionInfo info = await _dataSource.purchasePackage(packageId);
      return Right<Failure, SubscriptionInfo>(info);
    } catch (exception) {
      return Left<Failure, SubscriptionInfo>(mapExceptionToFailure(exception));
    }
  }

  @override
  Future<Result<SubscriptionInfo>> restorePurchases() async {
    try {
      final SubscriptionInfo info = await _dataSource.restorePurchases();
      return Right<Failure, SubscriptionInfo>(info);
    } catch (exception) {
      return Left<Failure, SubscriptionInfo>(mapExceptionToFailure(exception));
    }
  }
}
