// How the levels sit against SCOWL's tiers and the 12dicts lists: which tier
// each level lives in, how much of each tier is leveled, and a sample of what
// each tier holds that the levels do not. For judging where a level belongs.
//
//     dart run tool/overlap.dart
import 'dart:io';
import 'dart:math';

import 'package:nounogram_words/io.dart';
import 'package:nounogram_words/nounogram_words.dart';

import 'lists.dart';

String pct(int part, int whole) =>
    whole == 0 ? '-' : '${(100 * part / whole).round()}%'.padLeft(4);

Future<void> main() async {
  final store = await packageWordStore();
  await store.ensureUpTo(WordLevel.values.last);
  final deltas = {for (final s in scowlSizes) s: scowlTierDelta(s)};
  final esl = twelveDicts('3esl');
  final twoOf12 = twelveDicts('2of12');

  // Level groups keep the table readable; the levels inside a group come
  // from the same source family.
  final groups = <String, List<WordLevel>>{
    'PK-3': WordLevel.values.sublist(0, 5),
    '4-5': [WordLevel.grade4, WordLevel.grade5],
    '6-8': [WordLevel.grade6, WordLevel.grade7, WordLevel.grade8],
    '9-12': WordLevel.values.sublist(10, 14),
    'F': [WordLevel.familiar],
    'U': [WordLevel.uncommon],
    'O': [WordLevel.obscure],
  };

  stdout.writeln('SCOWL tier delta -> how much is leveled, and where\n');
  stdout.writeln('${'tier'.padRight(5)}${'words'.padLeft(7)}'
      '${'leveled'.padLeft(8)}  ${groups.keys.map((g) => g.padLeft(5)).join()}'
      '   unleveled sample');
  final rng = Random(1);
  for (final s in scowlSizes) {
    final d = deltas[s]!;
    final leveled = d.where((w) => store.levelOf(w) != null).length;
    final perGroup = groups.values.map((levels) {
      final n = d.where((w) => levels.contains(store.levelOf(w))).length;
      return pct(n, d.length);
    });
    final rest = d.where((w) => store.levelOf(w) == null).toList()
      ..shuffle(rng);
    stdout
        .writeln('${s.toString().padRight(5)}${d.length.toString().padLeft(7)}'
            '${pct(leveled, d.length).padLeft(8)}  '
            '${perGroup.map((p) => p.padLeft(5)).join()}'
            '   ${rest.take(6).join(', ')}');
  }

  stdout.writeln('\nEach level -> share found by SCOWL tier (cumulative) and '
      'by 12dicts list\n');
  final tiers = [10, 20, 35, 50, 70];
  final cumulative = {for (final t in tiers) t: scowlUpTo(t)};
  stdout.writeln('${'level'.padRight(13)}${'words'.padLeft(6)}  '
      '${tiers.map((t) => '≤$t'.padLeft(5)).join()}   '
      '${'3esl'.padLeft(5)}${'2of12'.padLeft(6)}');
  for (final level in WordLevel.values) {
    final words = store.wordsAt(level);
    final byTier = tiers.map(
        (t) => pct(words.where(cumulative[t]!.contains).length, words.length));
    stdout.writeln(
        '${level.label.padRight(13)}${words.length.toString().padLeft(6)}  '
        '${byTier.map((p) => p.padLeft(5)).join()}   '
        '${pct(words.where(esl.contains).length, words.length).padLeft(5)}'
        '${pct(words.where(twoOf12.contains).length, words.length).padLeft(6)}');
  }
}
