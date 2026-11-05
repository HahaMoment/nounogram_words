import 'dart:io';

import 'package:nounogram_words/io.dart';
import 'package:nounogram_words/nounogram_words.dart';

/// Prints a per-level breakdown of the word lists: how many words are
/// introduced at each level, the cumulative pool, and a few examples.
///
///     dart run bin/report.dart
Future<void> main() async {
  final store = await packageWordStore();
  await store.ensureUpTo(WordLevel.values.last);
  final all = store.wordsUpToLevel(WordLevel.values.last);

  final labelWidth = WordLevel.values
      .map((l) => l.label.length)
      .reduce((a, b) => a > b ? a : b);

  stdout.writeln('nounogram_words — ${all.length} words across '
      '${WordLevel.values.length} levels, lexicon '
      '${(await store.lexicon()).length}\n');
  stdout.writeln('${'Level'.padRight(labelWidth)}  ${'New'.padLeft(5)}  '
      '${'Cumulative'.padLeft(10)}  Examples');

  var cumulative = 0;
  for (final level in WordLevel.values) {
    final words = store.wordsAt(level);
    cumulative += words.length;
    stdout.writeln('${level.label.padRight(labelWidth)}  '
        '${words.length.toString().padLeft(5)}  '
        '${cumulative.toString().padLeft(10)}  '
        '${words.take(6).join(', ')}');
  }
}
