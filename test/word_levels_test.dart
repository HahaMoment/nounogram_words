import 'package:nounogram_words/io.dart';
import 'package:nounogram_words/nounogram_words.dart';
import 'package:test/test.dart';

void main() {
  late WordStore store;

  setUpAll(() async {
    store = await packageWordStore();
    await store.ensureUpTo(WordLevel.obscure);
  });

  group('word levels', () {
    test('tags a very common word at an early level', () {
      expect(store.levelOf('the')!.index,
          lessThanOrEqualTo(WordLevel.kindergarten.index));
    });

    test('is case-insensitive and null for unknown words', () {
      expect(store.levelOf('The'), store.levelOf('THE'));
      expect(store.levelOf('zzzxq'), isNull);
    });

    test('levels are cumulative (each includes all easier ones)', () {
      final k = store.wordsUpToLevel(WordLevel.kindergarten).toSet();
      final g6 = store.wordsUpToLevel(WordLevel.grade6).toSet();
      final g12 = store.wordsUpToLevel(WordLevel.grade12).toSet();
      expect(g6.containsAll(k), isTrue);
      expect(g12.containsAll(g6), isTrue);
      expect(g12.length, greaterThan(g6.length));
    });

    test('a range leaves out the easier levels', () {
      final band = store.wordsInRange(WordLevel.grade3, WordLevel.grade5);
      expect(band, contains(store.wordsAt(WordLevel.grade4).first));
      expect(band, isNot(contains('THE')));
    });

    test('only contains plain A-Z words of length >= 2', () {
      for (final word in store.wordsUpToLevel(WordLevel.obscure)) {
        expect(word, matches(RegExp(r'^[A-Z]{2,}$')), reason: word);
      }
    });

    test('every word has exactly one level', () {
      final seen = <String>{};
      for (final level in WordLevel.values) {
        for (final word in store.wordsAt(level)) {
          expect(seen.add(word), isTrue, reason: '$word twice');
        }
      }
    });

    test('every level has a label, a badge and a file', () {
      for (final level in WordLevel.values) {
        expect(level.label, isNotEmpty);
        expect(level.badge, isNotEmpty);
        expect(level.fileName, endsWith('.txt'));
      }
    });

    test('covers Pre-K..Grade 12 and three tiers past them', () {
      expect(WordLevel.values.length, 17);
      expect(WordLevel.values.first, WordLevel.preK);
      expect(WordLevel.lastGrade, WordLevel.grade12);
      expect(WordLevel.values.last, WordLevel.obscure);
      expect(WordLevel.grade12.isGrade, isTrue);
      expect(WordLevel.familiar.isGrade, isFalse);
    });

    test('the tiers hold plain, everyday words where SCOWL does', () {
      expect(store.levelOf('PACKET'), WordLevel.familiar);
      expect(store.levelOf('CHAMELEON'), WordLevel.uncommon);
      expect(store.levelOf('POPLIN'), WordLevel.obscure);
    });
  });

  group('loading', () {
    test('a level is unavailable until it is loaded', () async {
      final fresh = await packageWordStore();
      expect(fresh.isLoaded(WordLevel.preK), isFalse);
      expect(() => fresh.wordsAt(WordLevel.preK), throwsStateError);
      expect(fresh.levelOf('the'), isNull);
      await fresh.ensureUpTo(WordLevel.kindergarten);
      expect(fresh.isLoaded(WordLevel.kindergarten), isTrue);
      expect(fresh.isLoaded(WordLevel.grade1), isFalse);
      expect(fresh.levelOf('the'), isNotNull);
    });

    test('reads each file once even when asked twice at the same time',
        () async {
      var reads = 0;
      final counted = WordStore((name) async {
        reads++;
        return 'ONE\ntwo\n\n';
      });
      await Future.wait([
        counted.ensure([WordLevel.grade1]),
        counted.ensure([WordLevel.grade1]),
      ]);
      await counted.ensure([WordLevel.grade1]);
      expect(reads, 1);
      expect(counted.wordsAt(WordLevel.grade1), ['ONE', 'TWO']);
    });
  });

  group('lexicon', () {
    late Lexicon lexicon;
    setUpAll(() async => lexicon = await store.lexicon());

    test('knows every leveled word', () {
      for (final word in store.wordsUpToLevel(WordLevel.obscure)) {
        expect(lexicon.contains(word), isTrue, reason: word);
      }
    });

    test('knows inflections the levels leave out, not nonsense', () {
      expect(store.levelOf('WALKED'), isNull);
      expect(lexicon.contains('walked'), isTrue);
      expect(lexicon.contains('ZZXQ'), isFalse);
    });

    test('lists words by length', () {
      final fives = lexicon.ofLength(5);
      expect(fives, contains('HOUSE'));
      expect(fives.every((w) => w.length == 5), isTrue);
      expect(fives, isNot(contains('HOUSES')));
    });
  });
}
