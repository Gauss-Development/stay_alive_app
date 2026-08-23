import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:stay_alive/core/constants/category_assets.dart';

/// The categories bundled as the datasource fallback and seeded by the schema migration.
const List<String> _seededIconKeys = <String>[
  'beans',
  'berries',
  'fruits',
  'cruciferous_vegetables',
  'greens',
  'other_vegetables',
  'flaxseeds',
  'nuts',
  'spices',
  'whole_grains',
  'beverages',
  'exercise',
];

void main() {
  test('every seeded category resolves to artwork', () {
    for (final String iconKey in _seededIconKeys) {
      expect(
        CategoryAssets.pathFor(iconKey),
        isNotNull,
        reason: '$iconKey has no artwork and would render an empty tile',
      );
    }
  });

  test('every mapped asset exists on disk and is declared in pubspec', () {
    final String pubspec = File('pubspec.yaml').readAsStringSync();

    for (final String path in CategoryAssets.byIconKey.values.toSet()) {
      expect(
        File(path).existsSync(),
        isTrue,
        reason: '$path is mapped but missing from the repo',
      );
      expect(
        pubspec.contains(path),
        isTrue,
        reason: '$path is not declared in pubspec.yaml assets',
      );
    }
  });
}
