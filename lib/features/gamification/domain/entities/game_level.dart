import 'package:equatable/equatable.dart';

class GameLevel extends Equatable {
  const GameLevel({
    required this.level,
    required this.title,
    required this.xpRequired,
    required this.xpForNext,
  });

  final int level;
  final String title;
  final int xpRequired;
  final int xpForNext; // 0 means max level

  bool get isMaxLevel => xpForNext == 0;

  /// Progress within this level, 0.0–1.0.
  double progressFraction(int currentXp) {
    if (isMaxLevel) return 1.0;
    final int xpIntoLevel = currentXp - xpRequired;
    final int xpNeeded = xpForNext - xpRequired;
    if (xpNeeded <= 0) return 1.0;
    return (xpIntoLevel / xpNeeded).clamp(0.0, 1.0);
  }

  @override
  List<Object?> get props => <Object?>[level, title, xpRequired, xpForNext];
}

abstract final class GameLevelTable {
  static const List<GameLevel> levels = <GameLevel>[
    GameLevel(level: 1, title: 'Seedling', xpRequired: 0, xpForNext: 500),
    GameLevel(level: 2, title: 'Sprout', xpRequired: 500, xpForNext: 1500),
    GameLevel(level: 3, title: 'Grower', xpRequired: 1500, xpForNext: 3500),
    GameLevel(level: 4, title: 'Thriver', xpRequired: 3500, xpForNext: 7000),
    GameLevel(level: 5, title: 'Vitalist', xpRequired: 7000, xpForNext: 0),
  ];

  static GameLevel forXp(int xp) {
    GameLevel current = levels.first;
    for (final GameLevel level in levels) {
      if (xp >= level.xpRequired) current = level;
    }
    return current;
  }
}
