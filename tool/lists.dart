// Loaders for the open word lists in tool/data/ that are not grade-tagged:
// SCOWL (sized spell-checker tiers) and 12dicts (3esl, 2of12). Shared by
// build.dart and overlap.dart.
import 'dart:convert';
import 'dart:io';

/// SCOWL tier sizes, smallest first. Each file holds only the words that
/// tier adds; a tier's full list is the union of it and every smaller one.
const scowlSizes = [10, 20, 35, 40, 50, 55, 60, 70, 80];

final _plain = RegExp(r'^[a-z]{2,}$');

/// Lower-case plain words (a-z, length >= 2) from a 12dicts or SCOWL file,
/// upper-cased. Possessives, hyphenations, capitalised entries and marker
/// characters are dropped: the lists mark proper nouns by case and
/// neologisms and odd plurals with a prefix or suffix, and none of those
/// belong on a board.
Set<String> plainWords(String path) {
  // SCOWL files are ISO-8859-1 (a few entries carry accents); 12dicts are
  // ASCII, which latin1 also covers.
  final text = latin1.decode(File(path).readAsBytesSync());
  final out = <String>{};
  for (final raw in const LineSplitter().convert(text)) {
    final w = raw.replaceAll(RegExp(r'[!%]'), '');
    if (_plain.hasMatch(w)) out.add(w.toUpperCase());
  }
  return out;
}

/// Words that SCOWL tier [size] adds over the next smaller tier, American
/// spelling (the english-* file plus the american-* file).
Set<String> scowlTierDelta(int size) => {
      ...plainWords('tool/data/scowl/english-words.$size'),
      ...plainWords('tool/data/scowl/american-words.$size'),
    };

/// Every word in SCOWL tier [size] and below.
Set<String> scowlUpTo(int size) => {
      for (final s in scowlSizes)
        if (s <= size) ...scowlTierDelta(s),
    };

Set<String> twelveDicts(String list) => plainWords('tool/data/12dicts/$list.txt');
