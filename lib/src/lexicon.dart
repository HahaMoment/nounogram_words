/// Every string a solver may take as an English word: the graded and tiered
/// words plus SCOWL's common dictionary vocabulary with inflections.
///
/// It is a superset check, not a pool. A puzzle's answers come from the
/// levels; the lexicon only says whether some other string a board could
/// spell is a word a player would accept, so a solver can tell a real
/// second answer from a letter swap that spells nothing.
class Lexicon {
  Lexicon(Iterable<String> words) : _words = {...words};

  final Set<String> _words;
  final Map<int, List<String>> _byLength = {};
  Map<String, List<String>>? _byBag;

  int get length => _words.length;

  bool contains(String word) => _words.contains(word.toUpperCase());

  /// The words of exactly [n] letters, sorted. Built on first use per length.
  List<String> ofLength(int n) => _byLength[n] ??= [
        for (final w in _words)
          if (w.length == n) w,
      ]..sort();

  /// Every word spelled with exactly the letters of [word], sorted; [word]
  /// itself included when it is one. The spellings a scrambled bag of those
  /// letters could be. The index over every word is built on first use.
  List<String> anagramsOf(String word) {
    final byBag = _byBag ??= _indexBags();
    return byBag[sortedLetters(word)] ?? const [];
  }

  Map<String, List<String>> _indexBags() {
    final byBag = <String, List<String>>{};
    for (final w in _words) {
      (byBag[sortedLetters(w)] ??= []).add(w);
    }
    for (final list in byBag.values) {
      list.sort();
    }
    return byBag;
  }
}

/// A word's letters sorted, upper case: two words share it iff they are
/// anagrams.
String sortedLetters(String word) =>
    (word.toUpperCase().split('')..sort()).join();
