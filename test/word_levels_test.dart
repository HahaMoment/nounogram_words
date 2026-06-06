import 'package:nounogram_words/nounogram_words.dart';
import 'package:test/test.dart';

void main() {
  group('word levels', () {
    test('tags a very common word at an early level', () {
      expect(levelOf('the')!.index,
          lessThanOrEqualTo(WordLevel.kindergarten.index));
    });

    test('is case-insensitive and null for unknown words', () {
      expect(levelOf('The'), levelOf('THE'));
      expect(levelOf('zzzxq'), isNull);
    });

    test('levels are cumulative (each includes all easier ones)', () {
      final k = wordsUpToLevel(WordLevel.kindergarten).toSet();
      final g6 = wordsUpToLevel(WordLevel.grade6).toSet();
      final g12 = wordsUpToLevel(WordLevel.grade12).toSet();
      expect(g6.containsAll(k), isTrue);
      expect(g12.containsAll(g6), isTrue);
      expect(g12.length, greaterThan(g6.length));
    });

    test('only contains plain A-Z words of length >= 2', () {
      for (final word in wordsUpToLevel(WordLevel.grade12)) {
        expect(word, matches(RegExp(r'^[A-Z]{2,}$')), reason: word);
      }
    });

    test('every level has a label and a badge', () {
      for (final level in WordLevel.values) {
        expect(level.label, isNotEmpty);
        expect(level.badge, isNotEmpty);
      }
    });

    test('covers all 14 grade bands Pre-K..Grade 12', () {
      expect(WordLevel.values.length, 14);
      expect(WordLevel.values.first, WordLevel.preK);
      expect(WordLevel.values.last, WordLevel.grade12);
    });
  });
}
