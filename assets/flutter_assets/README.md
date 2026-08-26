# Sprout character assets (Flutter)

Four stages, resolution-aware (1x / 2.0x / 3.0x), transparent PNG.

Stages: sprout_sleep, sprout_curious, sprout_happy, sprout_cheer

## Install
Copy the `assets/` folder into your app root, then in pubspec.yaml:

```yaml
flutter:
  assets:
    - assets/sprout/
```

(Flutter picks the 2.0x / 3.0x variants automatically.)

## Use
```dart
Image.asset('assets/sprout/sprout_happy.png', width: 220);
```

Suggested loop (matches the animation): sleep → curious → happy → cheer → sleep,
cross-faded with AnimatedSwitcher or AnimatedCrossFade (~300 ms fade).
