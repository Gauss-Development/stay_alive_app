import 'package:equatable/equatable.dart';

class AnalyticsEvent extends Equatable {
  const AnalyticsEvent({
    required this.name,
    this.screenName,
    this.metadata = const <String, dynamic>{},
    required this.createdAt,
  });

  final String name;
  final String? screenName;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  @override
  List<Object?> get props => <Object?>[name, screenName, metadata, createdAt];
}
