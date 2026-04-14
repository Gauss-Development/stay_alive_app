import 'package:equatable/equatable.dart';

class CategoryDefinition extends Equatable {
  const CategoryDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.iconKey,
    required this.targetCount,
    required this.displayOrder,
    required this.isActive,
  });

  final String id;
  final String title;
  final String description;
  final String iconKey;
  final int targetCount;
  final int displayOrder;
  final bool isActive;

  @override
  List<Object?> get props => <Object?>[
        id,
        title,
        description,
        iconKey,
        targetCount,
        displayOrder,
        isActive,
      ];
}
