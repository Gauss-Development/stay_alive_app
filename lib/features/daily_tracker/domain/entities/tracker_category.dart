import 'package:equatable/equatable.dart';

class TrackerCategory extends Equatable {
  const TrackerCategory({
    required this.id,
    required this.title,
    required this.description,
    required this.targetCount,
    required this.displayOrder,
    required this.iconKey,
    required this.isActive,
  });

  final String id;
  final String title;
  final String description;
  final int targetCount;
  final int displayOrder;
  final String iconKey;
  final bool isActive;

  @override
  List<Object?> get props => <Object?>[
        id,
        title,
        description,
        targetCount,
        displayOrder,
        iconKey,
        isActive,
      ];
}
