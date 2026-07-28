import 'package:flutter/foundation.dart';
import 'package:rive/rive.dart';

/// Lazy, fault-tolerant Rive runtime bootstrap.
///
/// Native libraries must be installed (`dart run rive_native:setup`) and the
/// app fully rebuilt after adding the `rive` package — hot restart is not enough.
abstract final class RiveBootstrap {
  static bool _attempted = false;
  static bool _available = false;

  static bool get isAvailable => _available;

  static Future<bool> ensureInitialized() async {
    if (_attempted) {
      return _available;
    }
    _attempted = true;

    try {
      _available = await RiveNative.init();
    } catch (error, stackTrace) {
      _available = false;
      debugPrint('RiveBootstrap: native runtime unavailable — $error');
      debugPrint('$stackTrace');
    }

    return _available;
  }
}
