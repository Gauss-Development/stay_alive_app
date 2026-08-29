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

/// What the sprout is feeling right now.
///
/// The sprout never wilts or blames: an untouched day reads as [waiting]
/// (patient hope), never as sadness. GAU-416 adds a distinct `missedYou`
/// mood for return-after-skip; until that loop exists, [celebrating] is the
/// only reunion-flavoured state and it fires on a completed day.
enum SproutMood {
  happy,
  waiting,
  sleeping,
  celebrating,
}

/// Client-computed visual projection of gamification + today's log.
class GardenState extends Equatable {
  const GardenState({
    required this.stage,
    required this.mood,
    required this.health,
    required this.wilting,
    required this.todayGrowth,
    required this.levelTitle,
    required this.level,
  });

  factory GardenState.seedling() => const GardenState(
        stage: GardenStage.seed,
        mood: SproutMood.waiting,
        health: 0.4,
        wilting: false,
        todayGrowth: 0,
        levelTitle: 'Seedling',
        level: 1,
      );

  final GardenStage stage;
  final SproutMood mood;
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
        mood,
        health,
        wilting,
        todayGrowth,
        levelTitle,
        level,
      ];
}
