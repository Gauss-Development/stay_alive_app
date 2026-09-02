import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/// Driver for `integration_test/screens_test.dart`.
///
/// Writes every `binding.takeScreenshot(name)` call to `screenshots/<name>.png`
/// on the host machine.
Future<void> main() async {
  await integrationDriver(
    onScreenshot: (
      String name,
      List<int> bytes, [
      Map<String, Object?>? args,
    ]) async {
      final File file = File('screenshots/$name.png')
        ..createSync(recursive: true);
      file.writeAsBytesSync(bytes);
      stdout.writeln('saved screenshots/$name.png (${bytes.length} bytes)');
      return true;
    },
  );
}
