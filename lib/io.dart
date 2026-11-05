/// File-system readers for [WordStore], for VM tools and tests. Apps use
/// their asset bundle instead; this library imports `dart:io` and is kept
/// apart so the main library stays usable on the web.
library;

import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'nounogram_words.dart';

/// A reader over the data files in [directory].
WordReader directoryReader(String directory) =>
    (name) => File('$directory/$name').readAsString();

/// A reader over this package's own `lib/data/`, wherever pub put it.
///
/// Resolved through the isolate when it can be (`dart run`, `dart test`),
/// else from the `.dart_tool/package_config.json` above the working
/// directory, which is how `flutter test` runs land here.
Future<WordReader> packageDataReader() async {
  final uri = await _resolveData();
  return directoryReader(uri.toFilePath().replaceAll(RegExp(r'/$'), ''));
}

Future<Uri> _resolveData() async {
  try {
    final uri = await Isolate.resolvePackageUri(
      Uri.parse('package:nounogram_words/data/'),
    );
    if (uri != null) return uri;
  } on UnsupportedError {
    // Fall through to the package config.
  }
  for (var dir = Directory.current;; dir = dir.parent) {
    final config = File('${dir.path}/.dart_tool/package_config.json');
    if (config.existsSync()) {
      final packages =
          (jsonDecode(config.readAsStringSync()) as Map)['packages'] as List;
      for (final p in packages) {
        if ((p as Map)['name'] != 'nounogram_words') continue;
        // A directory URI must end in a slash, or resolving against it
        // replaces its last segment.
        var root = config.uri.resolve(p['rootUri'] as String).toString();
        if (!root.endsWith('/')) root = '$root/';
        return Uri.parse(root).resolve('${p['packageUri'] as String}data/');
      }
      throw StateError('nounogram_words is not in ${config.path}');
    }
    if (dir.parent.path == dir.path) {
      throw StateError('package:nounogram_words/data/ could not be resolved');
    }
  }
}

/// A store over this package's own data files.
Future<WordStore> packageWordStore() async =>
    WordStore(await packageDataReader());
