// Builds the word data from the open source lists in tool/data/ and writes:
//   - lib/data/<level>.txt   one file per level (grade-prek.txt .. obscure.txt),
//                            the files WordStore loads and apps bundle as assets
//   - lib/data/lexicon.txt   every word the solver may take as English
//   - data/word-levels.csv   flat word,level_index,level for any consumer
//
// Run from the package root:  dart run tool/build.dart
//
// A word takes the EARLIEST (lowest) level it appears at. Levels (index):
//   0  Pre-K        Dolch pre-primer
//   1  Kindergarten Dolch primer + Dolch nouns, Fry 1-50
//   2  Grade 1      Dolch first grade, Fry 51-100
//   3  Grade 2      Dolch second grade, Fry 101-200
//   4  Grade 3      Dolch third grade, Fry 201-300
//   5  Grade 4      Fry 301-500
//   6  Grade 5      Fry 501-1000
//   7  Grade 6      NGSL frequency rank, 1st third
//   8  Grade 7      NGSL 2nd third
//   9  Grade 8      NGSL 3rd third
//   10 Grade 9      NAWL frequency rank, 1st quarter
//   11 Grade 10     NAWL 2nd quarter
//   12 Grade 11     NAWL 3rd quarter
//   13 Grade 12     NAWL 4th quarter
//   14 Familiar     12dicts 3esl words in SCOWL tiers 10-20
//   15 Uncommon     12dicts 3esl words in SCOWL tier 35
//   16 Obscure      the rest of 3esl, and 2of12
//
// The three tiers past Grade 12 come from lemma lists, so they continue the
// graded pool for adult players without flooding it with inflections. They
// are split by how common SCOWL rates the words, not by any grade claim.
//
// Sources: Fry (public domain), Dolch (public domain), NGSL & NAWL
// (CC BY-SA 4.0), SCOWL (permissive), 12dicts (public domain). Only plain
// A-Z words of length >= 2 survive. See README and NOTICE.
import 'dart:io';

import 'package:nounogram_words/nounogram_words.dart';

import 'lists.dart';

/// SCOWL tier the lexicon is cut at. 70 ("large") is common dictionary
/// vocabulary with inflections; 80 adds ENABLE and the UK cryptics list,
/// which hold strings few players would accept as words.
const lexiconSize = 70;

void main() {
  final dolch = File('tool/data/dolch.js').readAsStringSync();
  final fry = File('tool/data/fry.txt').readAsStringSync();
  final ngslNawl = File('tool/data/ngsl_nawl.csv').readAsLinesSync();

  final level = <String, int>{};
  void tag(String raw, int lvl) {
    final w = raw.trim().toUpperCase();
    if (!RegExp(r'^[A-Z]{2,}$').hasMatch(w)) return;
    final existing = level[w];
    if (existing == null || lvl < existing) level[w] = lvl;
  }

  void tagAll(Iterable<String> words, int lvl) {
    for (final w in words) {
      tag(w, lvl);
    }
  }

  // --- Dolch: explicit grade groups (public domain) -----------------------
  String dolchGroup(String name) {
    final m = RegExp("let $name\\s*=\\s*'([^']*)'").firstMatch(dolch);
    if (m == null) throw StateError('Dolch group $name not found');
    return m.group(1)!;
  }

  tagAll(dolchGroup('dolchPreK').split(','), 0);
  tagAll(dolchGroup('dolchK').split(','), 1);
  tagAll(dolchGroup('dolchNouns').split(','), 1);
  tagAll(dolchGroup('dolchFirst').split(','), 2);
  tagAll(dolchGroup('dolchSecond').split(','), 3);
  tagAll(dolchGroup('dolchThird').split(','), 4);

  // --- Fry: 4 columns, column-major frequency order (ranks 1..1000) -------
  final fryLines = fry
      .split('\n')
      .map((l) => l.trimRight())
      .where((l) => l.isNotEmpty)
      .toList()
    ..removeAt(0); // header "List 1 .. List 4"
  final ranked = <String>[];
  for (var col = 0; col < 4; col++) {
    for (final line in fryLines) {
      final cells = line.split('\t');
      if (col < cells.length && cells[col].trim().isNotEmpty) {
        ranked.add(cells[col].trim());
      }
    }
  }
  int fryLevel(int rank) {
    if (rank <= 50) return 1;
    if (rank <= 100) return 2;
    if (rank <= 200) return 3;
    if (rank <= 300) return 4;
    if (rank <= 500) return 5;
    return 6;
  }

  for (var i = 0; i < ranked.length; i++) {
    tag(ranked[i], fryLevel(i + 1));
  }

  // --- NGSL (-> G6-8) and NAWL (-> G9-12), split by frequency rank --------
  final ngsl = <(String, int)>[]; // (lemma, rank)
  final nawl = <(String, int)>[];
  for (final line in ngslNawl.skip(1)) {
    final c = line.split(',');
    if (c.length < 3) continue;
    final lemma = c[0];
    final rank = int.tryParse(c[2]);
    if (rank == null) continue;
    if (c[1] == 'NGSL') {
      ngsl.add((lemma, rank));
    } else if (c[1] == 'NAWL') {
      nawl.add((lemma, rank));
    }
  }
  ngsl.sort((a, b) => a.$2.compareTo(b.$2));
  nawl.sort((a, b) => a.$2.compareTo(b.$2));

  // Split a rank-ordered list into [buckets] even bands starting at [baseLevel].
  void tagBands(List<(String, int)> list, int buckets, int baseLevel) {
    for (var i = 0; i < list.length; i++) {
      final bucket = (i * buckets) ~/ list.length;
      tag(list[i].$1, baseLevel + bucket);
    }
  }

  tagBands(ngsl, 3, 7); // G6, G7, G8
  tagBands(nawl, 4, 10); // G9, G10, G11, G12

  // --- Tiers past Grade 12, from the lemma lists ----------------------------
  // The graded words are tagged first, so "earliest level wins" keeps every
  // grade exactly as the curricula rank it; the tiers only take what is left.
  final common = scowlUpTo(20);
  final small = scowlUpTo(35);
  final esl = twelveDicts('3esl');
  tagAll(esl.where(common.contains), WordLevel.familiar.index);
  tagAll(esl.where(small.contains), WordLevel.uncommon.index);
  tagAll(esl, WordLevel.obscure.index);
  tagAll(twelveDicts('2of12'), WordLevel.obscure.index);

  // --- Emit -----------------------------------------------------------------
  final words = level.keys.toList()..sort();
  final counts = List.filled(WordLevel.values.length, 0);
  for (final w in words) {
    counts[level[w]!]++;
  }

  void writeList(String path, Iterable<String> list) {
    File(path).writeAsStringSync('${list.join('\n')}\n');
  }

  for (final lvl in WordLevel.values) {
    writeList('lib/data/${lvl.fileName}', [
      for (final w in words)
        if (level[w] == lvl.index) w,
    ]);
  }

  final csv = StringBuffer('word,level_index,level\n');
  for (final w in words) {
    csv.writeln('$w,${level[w]},${WordLevel.values[level[w]!].name}');
  }
  File('data/word-levels.csv').writeAsStringSync(csv.toString());

  final lexicon = scowlUpTo(lexiconSize)..addAll(words);
  writeList('lib/data/lexicon.txt', lexicon.toList()..sort());

  stdout.writeln('built ${words.length} words; per-level ${counts.join(', ')}; '
      'lexicon ${lexicon.length} (SCOWL $lexiconSize)');
}
