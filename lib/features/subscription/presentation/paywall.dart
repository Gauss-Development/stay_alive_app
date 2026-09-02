import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:stay_alive/features/subscription/presentation/cubit/subscription_cubit.dart';

/// Opens the RevenueCat-hosted paywall for the current offering.
///
/// The app ships no paywall UI of its own: layout, copy and pricing live in
/// the RevenueCat dashboard and change without an app release. Status is
/// refreshed on dismissal regardless of the outcome — the sheet can end in a
/// purchase, a restore or a plain close, and only `CustomerInfo` knows which.
Future<void> showPaywall(BuildContext context) async {
  final SubscriptionCubit cubit = context.read<SubscriptionCubit>();
  await RevenueCatUI.presentPaywall();
  await cubit.refreshStatus();
}
