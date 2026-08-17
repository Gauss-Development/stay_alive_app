import 'package:equatable/equatable.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/tracker_category.dart';

class DailyLogItem extends Equatable {
  const DailyLogItem({
    required this.id,
    required this.category,
    required this.completedCount,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final TrackerCategory category;
  final int completedCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get categoryId => category.id;
  String get title => category.title;
  int get targetCount => category.targetCount;
  bool get isCompleted => completedCount >= targetCount;

  DailyLogItem increment() {
    final int nextValue = completedCount + 1;
    return copyWith(
      completedCount: nextValue > targetCount ? targetCount : nextValue,
      updatedAt: DateTime.now().toUtc(),
    );
  }

  DailyLogItem decrement() {
    final int nextValue = completedCount - 1;
    return copyWith(
      completedCount: nextValue < 0 ? 0 : nextValue,
      updatedAt: DateTime.now().toUtc(),
    );
  }

  DailyLogItem copyWith({
    String? id,
    TrackerCategory? category,
    int? completedCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DailyLogItem(
      id: id ?? this.id,
      category: category ?? this.category,
      completedCount: completedCount ?? this.completedCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        category,
        completedCount,
        createdAt,
        updatedAt,
      ];
}
