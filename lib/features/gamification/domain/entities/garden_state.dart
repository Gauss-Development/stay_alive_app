import 'package:equatable/equatable.dart';
import 'package:stay_alive/features/gamification/domain/entities/game_level.dart';

/// Visual growth stage of the user's single sprout (maps 1:1 to [GameLevel]).
enum GardenStage {
  seed,
  sprout,
  sapling,
  plant,
  bloom,
}

/// Client-computed visual projection of gamification + today's log.
class GardenState extends Equatable {
  const GardenState({
    required this.stage,
    required this.health,
    required this.wilting,
    required this.todayGrowth,
    required this.levelTitle,
    required this.level,
  });

  factory GardenState.seedling() => const GardenState(
        stage: GardenStage.seed,
        health: 0.4,
        wilting: false,
        todayGrowth: 0,
        levelTitle: 'Seedling',
        level: 1,
      );

  final GardenStage stage;
  final double health;
  final bool wilting;
  final double todayGrowth;
  final String levelTitle;
  final int level;

  static GardenStage stageForLevel(GameLevel level) {
    return switch (level.level) {
      1 => GardenStage.seed,
      2 => GardenStage.sprout,
      3 => GardenStage.sapling,
      4 => GardenStage.plant,
      _ => GardenStage.bloom,
    };
  }

  double get displayScale {
    final double stageScale = switch (stage) {
      GardenStage.seed => 0.72,
      GardenStage.sprout => 0.82,
      GardenStage.sapling => 0.92,
      GardenStage.plant => 1.0,
      GardenStage.bloom => 1.08,
    };
    final double growthBoost = 0.08 * todayGrowth;
    final double wiltPenalty = wilting ? 0.12 : 0;
    return (stageScale + growthBoost - wiltPenalty).clamp(0.55, 1.15);
  }

  @override
  List<Object?> get props => <Object?>[
        stage,
        health,
        wilting,
        todayGrowth,
        levelTitle,
        level,
      ];
}
