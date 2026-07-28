import 'package:equatable/equatable.dart';

class GamificationXpEvent extends Equatable {
  const GamificationXpEvent({
    required this.eventId,
    required this.eventType,
    required this.label,
    required this.xpDelta,
    required this.logDate,
    required this.createdAt,
  });

  final String eventId;
  final String eventType;
  final String label;
  final int xpDelta;
  final String logDate;
  final DateTime createdAt;

  @override
  List<Object?> get props => <Object?>[
    eventId,
    eventType,
    label,
    xpDelta,
    logDate,
    createdAt,
  ];
}
