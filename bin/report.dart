import 'dart:io';

import 'package:nounogram_words/nounogram_words.dart';

/// Prints a per-grade breakdown of the graded word lists: how many words are
/// introduced at each level, the cumulative pool, and a few examples.
///
///     dart run bin/report.dart
void main() {
  final all = wordsUpToLevel(WordLevel.values.last);
  final byLevel = {for (final level in WordLevel.values) level: <String>[]};
  for (final word in all) {
    byLevel[levelOf(word)!]!.add(word);
  }

  final labelWidth = WordLevel.values
      .map((l) => l.label.length)
      .reduce((a, b) => a > b ? a : b);

  stdout.writeln('nounogram_words — ${all.length} words across '
      '${WordLevel.values.length} levels\n');
  stdout.writeln('${'Level'.padRight(labelWidth)}  ${'New'.padLeft(5)}  '
      '${'Cumulative'.padLeft(10)}  Examples');

  var cumulative = 0;
  for (final level in WordLevel.values) {
    final words = byLevel[level]!..sort();
    cumulative += words.length;
    stdout.writeln('${level.label.padRight(labelWidth)}  '
        '${words.length.toString().padLeft(5)}  '
        '${cumulative.toString().padLeft(10)}  '
        '${words.take(6).join(', ')}');
  }
}
