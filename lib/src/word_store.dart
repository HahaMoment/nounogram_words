import 'lexicon.dart';
import 'word_levels.dart';

/// Reads one data file by its name under `lib/data/` (a [WordLevel.fileName]
/// or [lexiconFileName]) and returns its text.
///
/// The package has no opinion on where the bytes live: a Flutter app reads
/// `packages/nounogram_words/data/<name>` from its bundle, a web worker
/// fetches the same URL, a VM tool reads the file (see `io.dart`).
typedef WordReader = Future<String> Function(String fileName);

/// The word lists, loaded level by level on demand and kept.
///
/// The grades are small (about 4 000 words together) and an app loads them
/// at boot; the tiers past Grade 12 are larger and load the first time a
/// puzzle in that band is opened. Lookups are synchronous over whatever is
/// loaded, so whoever opens a puzzle calls [ensure] for its band first.
class WordStore {
  WordStore(this._read);

  final WordReader _read;
  final Map<WordLevel, List<String>> _words = {};
  final Map<String, WordLevel> _levelOf = {};
  final Map<WordLevel, Future<void>> _loading = {};
  Future<Lexicon>? _lexicon;

  /// Upper-cased words of a level file, one per line, blank lines dropped.
  static List<String> parse(String text) => [
        for (final line in text.split('\n'))
          if (line.trim().isNotEmpty) line.trim().toUpperCase(),
      ];

  bool isLoaded(WordLevel level) => _words.containsKey(level);

  /// Loads every level in [levels] that is not loaded yet.
  Future<void> ensure(Iterable<WordLevel> levels) =>
      Future.wait(levels.map(_load));

  /// Loads every level from Pre-K up to [max].
  Future<void> ensureUpTo(WordLevel max) =>
      ensure(WordLevel.values.take(max.index + 1));

  Future<void> _load(WordLevel level) {
    if (_words.containsKey(level)) return Future.value();
    return _loading[level] ??= _read(level.fileName).then((text) {
      final words = parse(text)..sort();
      _words[level] = words;
      for (final w in words) {
        _levelOf[w] = level;
      }
      _loading.remove(level);
    });
  }

  /// The level [word] is first learned at, among the loaded levels, or null
  /// if no loaded level has it. A word in an unloaded tier reads as null too,
  /// so load the band a puzzle was drawn from before tagging its words.
  WordLevel? levelOf(String word) => _levelOf[word.toUpperCase()];

  /// Words introduced at exactly [level], upper-cased and sorted.
  List<String> wordsAt(WordLevel level) {
    final words = _words[level];
    if (words == null) {
      throw StateError('${level.name} is not loaded; call ensure() first');
    }
    return words;
  }

  /// Every word at [max] or an easier level, upper-cased and sorted.
  List<String> wordsUpToLevel(WordLevel max) =>
      wordsInRange(WordLevel.preK, max);

  /// Every word first learned at a level from [min] to [max] inclusive,
  /// upper-cased and sorted. Throws if any level in the range is not loaded.
  List<String> wordsInRange(WordLevel min, WordLevel max) {
    final out = <String>[];
    for (var i = min.index; i <= max.index; i++) {
      out.addAll(wordsAt(WordLevel.values[i]));
    }
    return out..sort();
  }

  /// The lexicon, read once and kept.
  Future<Lexicon> lexicon() =>
      _lexicon ??= _read(lexiconFileName).then((t) => Lexicon(parse(t)));
}
