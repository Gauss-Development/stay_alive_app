/// Custom category artwork keyed by [TrackerCategory.iconKey].
abstract final class CategoryAssets {
  static const Map<String, String> byIconKey = <String, String>{
    'beans': 'assets/beans.png',
    'berries': 'assets/berries.png',
    'fruits': 'assets/fruits.png',
    'cruciferous': 'assets/cruciferous_vegetables.png',
    'cruciferous_vegetables': 'assets/cruciferous_vegetables.png',
    'greens': 'assets/greens.png',
    'other_vegetables': 'assets/greens.png',
    'flaxseeds': 'assets/greens.png',
    'nuts': 'assets/greens.png',
    'spices':'assets/greens.png',
    'whole_grains': 'assets/greens.png',
    'beverages': 'assets/greens.png',
    'exercise': 'assets/greens.png',


  };

  static String? pathFor(String iconKey) => byIconKey[iconKey.toLowerCase()];
}
