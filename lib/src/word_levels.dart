import 'word_levels_data.dart';

/// Reading levels a word can belong to, ordered easiest-first. The index lines
/// up with the values stored in [kWordLevelIndex].
enum WordLevel {
  preK,
  kindergarten,
  grade1,
  grade2,
  grade3,
  grade4,
  grade5,
  grade6,
  grade7,
  grade8,
  grade9,
  grade10,
  grade11,
  grade12;

  /// A full label for menus ("Kindergarten", "Grade 1").
  String get label => switch (this) {
        WordLevel.preK => 'Pre-K',
        WordLevel.kindergarten => 'Kindergarten',
        WordLevel.grade1 => 'Grade 1',
        WordLevel.grade2 => 'Grade 2',
        WordLevel.grade3 => 'Grade 3',
        WordLevel.grade4 => 'Grade 4',
        WordLevel.grade5 => 'Grade 5',
        WordLevel.grade6 => 'Grade 6',
        WordLevel.grade7 => 'Grade 7',
        WordLevel.grade8 => 'Grade 8',
        WordLevel.grade9 => 'Grade 9',
        WordLevel.grade10 => 'Grade 10',
        WordLevel.grade11 => 'Grade 11',
        WordLevel.grade12 => 'Grade 12',
      };

  /// A compact badge ("PK", "K", "1" … "12") for tagging words inline.
  String get badge => switch (this) {
        WordLevel.preK => 'PK',
        WordLevel.kindergarten => 'K',
        WordLevel.grade1 => '1',
        WordLevel.grade2 => '2',
        WordLevel.grade3 => '3',
        WordLevel.grade4 => '4',
        WordLevel.grade5 => '5',
        WordLevel.grade6 => '6',
        WordLevel.grade7 => '7',
        WordLevel.grade8 => '8',
        WordLevel.grade9 => '9',
        WordLevel.grade10 => '10',
        WordLevel.grade11 => '11',
        WordLevel.grade12 => '12',
      };
}

/// The reading level [word] is first learned at, or null if it isn't in the
/// graded lists.
WordLevel? levelOf(String word) {
  final index = kWordLevelIndex[word.toUpperCase()];
  return index == null ? null : WordLevel.values[index];
}

/// Every graded word at [max] or an easier level, uppercased and sorted.
List<String> wordsUpToLevel(WordLevel max) {
  final out = [
    for (final entry in kWordLevelIndex.entries)
      if (entry.value <= max.index) entry.key,
  ]..sort();
  return out;
}
