// How the graded lists sit against SCOWL's tiers and the 12dicts lists:
// which tier each grade lives in, how much of each tier is graded, and what
// the rungs past Grade 12 look like. For deciding where new rungs belong.
//
//     dart run tool/overlap.dart
import 'dart:io';
import 'dart:math';

import 'package:nounogram_words/nounogram_words.dart';

import 'lists.dart';

String pct(int part, int whole) =>
    whole == 0 ? '-' : '${(100 * part / whole).round()}%'.padLeft(4);

void main() {
  final graded = <String, WordLevel>{};
  for (final w in wordsUpToLevel(WordLevel.values.last)) {
    graded[w] = levelOf(w)!;
  }
  final deltas = {for (final s in scowlSizes) s: scowlTierDelta(s)};
  final esl = twelveDicts('3esl');
  final twoOf12 = twelveDicts('2of12');

  // Grade groups keep the table readable; the grades inside a group come
  // from the same source family.
  final groups = <String, List<WordLevel>>{
    'PK-3': WordLevel.values.sublist(0, 5),
    '4-5': [WordLevel.grade4, WordLevel.grade5],
    '6-8': [WordLevel.grade6, WordLevel.grade7, WordLevel.grade8],
    '9-12': WordLevel.values.sublist(10),
  };

  stdout.writeln('SCOWL tier delta -> how much is graded, and where\n');
  stdout.writeln('${'tier'.padRight(5)}${'words'.padLeft(7)}'
      '${'graded'.padLeft(8)}  ${groups.keys.map((g) => g.padLeft(5)).join()}'
      '   ungraded sample');
  final rng = Random(1);
  for (final s in scowlSizes) {
    final d = deltas[s]!;
    final inGrades = d.where(graded.containsKey).length;
    final perGroup = groups.values.map((levels) {
      final n = d.where((w) => levels.contains(graded[w])).length;
      return pct(n, d.length);
    });
    final rest = d.where((w) => !graded.containsKey(w)).toList()..shuffle(rng);
    stdout.writeln('${s.toString().padRight(5)}${d.length.toString().padLeft(7)}'
        '${pct(inGrades, d.length).padLeft(8)}  ${perGroup.map((p) => p.padLeft(5)).join()}'
        '   ${rest.take(6).join(', ')}');
  }

  stdout.writeln('\nEach grade -> share found by SCOWL tier (cumulative) and '
      'by 12dicts list\n');
  final tiers = [10, 20, 35, 50, 70];
  final cumulative = {for (final t in tiers) t: scowlUpTo(t)};
  stdout.writeln('${'grade'.padRight(13)}${'words'.padLeft(6)}  '
      '${tiers.map((t) => '≤$t'.padLeft(5)).join()}   '
      '${'3esl'.padLeft(5)}${'2of12'.padLeft(6)}');
  for (final level in WordLevel.values) {
    final words = graded.entries
        .where((e) => e.value == level)
        .map((e) => e.key)
        .toList();
    final byTier = tiers.map(
        (t) => pct(words.where(cumulative[t]!.contains).length, words.length));
    stdout.writeln('${level.label.padRight(13)}${words.length.toString().padLeft(6)}  '
        '${byTier.map((p) => p.padLeft(5)).join()}   '
        '${pct(words.where(esl.contains).length, words.length).padLeft(5)}'
        '${pct(words.where(twoOf12.contains).length, words.length).padLeft(6)}');
  }

  stdout.writeln('\nRungs past Grade 12 (lemma lists minus the grades)\n');
  final rung1 = esl.difference(graded.keys.toSet());
  final rung2 = twoOf12.difference(graded.keys.toSet()).difference(rung1);
  for (final (name, rung) in [('3esl - grades', rung1), ('2of12 - 3esl', rung2)]) {
    final inTier = {
      for (final t in tiers) t: rung.where(cumulative[t]!.contains).length
    };
    final sample = rung.toList()..shuffle(rng);
    stdout.writeln('${name.padRight(14)}${rung.length.toString().padLeft(6)}  '
        '${tiers.map((t) => pct(inTier[t]!, rung.length).padLeft(5)).join()}');
    stdout.writeln('${''.padRight(22)}${sample.take(14).join(', ')}');
  }
}
