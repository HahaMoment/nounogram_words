/// File-system readers for [WordStore], for VM tools and tests. Apps use
/// their asset bundle instead; this library imports `dart:io` and is kept
/// apart so the main library stays usable on the web.
library;

import 'dart:io';
import 'dart:isolate';

import 'nounogram_words.dart';

/// A reader over the data files in [directory].
WordReader directoryReader(String directory) =>
    (name) => File('$directory/$name').readAsString();

/// A reader over this package's own `lib/data/`, wherever pub put it.
Future<WordReader> packageDataReader() async {
  final uri = await Isolate.resolvePackageUri(
    Uri.parse('package:nounogram_words/data/'),
  );
  if (uri == null) {
    throw StateError('package:nounogram_words/data/ could not be resolved');
  }
  return directoryReader(uri.toFilePath().replaceAll(RegExp(r'/$'), ''));
}

/// A store over this package's own data files.
Future<WordStore> packageWordStore() async =>
    WordStore(await packageDataReader());
