import 'package:equatable/equatable.dart';

class CompletionSummary extends Equatable {
  const CompletionSummary({
    required this.totalCompleted,
    required this.totalTarget,
    required this.completionPercentage,
    required this.isFullyCompleted,
  });

  final int totalCompleted;
  final int totalTarget;
  final double completionPercentage;
  final bool isFullyCompleted;

  @override
  List<Object?> get props => <Object?>[
        totalCompleted,
        totalTarget,
        completionPercentage,
        isFullyCompleted,
      ];
}
