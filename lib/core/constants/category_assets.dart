/// Custom category artwork keyed by [TrackerCategory.iconKey].
///
/// Only five illustrations exist so far. The remaining categories borrow the
/// closest available one so no single image dominates the grid — previously
/// seven of twelve tiles all rendered `greens.png`, which read as a bug.
///
/// ⚠️ Placeholders: every entry under "borrowed art" is waiting on real
/// artwork. Drop the PNG in `assets/`, register it in `pubspec.yaml`, and
/// point the key at it.
abstract final class CategoryAssets {
  static const Map<String, String> byIconKey = <String, String>{
    // Categories with their own art.
    'beans': 'assets/beans.png',
    'berries': 'assets/berries.png',
    'fruits': 'assets/fruits.png',
    'cruciferous': 'assets/cruciferous_vegetables.png',
    'cruciferous_vegetables': 'assets/cruciferous_vegetables.png',
    'greens': 'assets/greens.png',

    // Borrowed art — placeholder until dedicated illustrations land.
    'other_vegetables': 'assets/cruciferous_vegetables.png',
    'flaxseeds': 'assets/beans.png',
    'nuts': 'assets/beans.png',
    'whole_grains': 'assets/beans.png',
    'spices': 'assets/greens.png',
    'beverages': 'assets/berries.png',
    'exercise': 'assets/fruits.png',
  };

  static String? pathFor(String iconKey) => byIconKey[iconKey.toLowerCase()];
}
