import 'package:equatable/equatable.dart';

/// Validated AI daily-quest template (no XP until mapped + completed).
class PersonalizedChallengeDraft extends Equatable {
  const PersonalizedChallengeDraft({
    required this.title,
    required this.description,
    required this.target,
    required this.xpReward,
    this.categoryId,
    this.challengeType = 'logServings',
  });

  final String title;
  final String description;
  final int target;
  final int xpReward;
  final String? categoryId;
  final String challengeType;

  factory PersonalizedChallengeDraft.fromJson(Map<String, dynamic> json) {
    return PersonalizedChallengeDraft(
      title: json['title']?.toString() ?? 'Personal Quest',
      description: json['description']?.toString() ?? '',
      target: (json['target'] as num?)?.toInt() ?? 3,
      xpReward: (json['xpReward'] as num?)?.toInt().clamp(20, 80) ?? 40,
      categoryId: json['categoryId']?.toString(),
      challengeType: json['challengeType']?.toString() ?? 'logServings',
    );
  }

  PersonalizedChallengeDraft validated() {
    return PersonalizedChallengeDraft(
      title: title.trim().isEmpty ? 'Personal Quest' : title.trim(),
      description: description.trim(),
      target: target.clamp(1, 12),
      xpReward: xpReward.clamp(20, 80),
      categoryId: categoryId,
      challengeType: challengeType,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        title,
        description,
        target,
        xpReward,
        categoryId,
        challengeType,
      ];
}
