import 'package:equatable/equatable.dart';

class EducationalContent extends Equatable {
  const EducationalContent({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.shortDescription,
    required this.body,
    required this.languageCode,
    required this.isPublished,
  });

  final String id;
  final String categoryId;
  final String title;
  final String shortDescription;
  final String body;
  final String languageCode;
  final bool isPublished;

  @override
  List<Object?> get props => <Object?>[
        id,
        categoryId,
        title,
        shortDescription,
        body,
        languageCode,
        isPublished,
      ];
}
