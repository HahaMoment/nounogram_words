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
  academic;

  /// A full label for menus ("Kindergarten", "Grade 1", "Academic").
  String get label => switch (this) {
        WordLevel.preK => 'Pre-K',
        WordLevel.kindergarten => 'Kindergarten',
        WordLevel.grade1 => 'Grade 1',
        WordLevel.grade2 => 'Grade 2',
        WordLevel.grade3 => 'Grade 3',
        WordLevel.grade4 => 'Grade 4',
        WordLevel.grade5 => 'Grade 5',
        WordLevel.academic => 'Academic',
      };

  /// A compact badge ("K", "1", "AC") for tagging words inline.
  String get badge => switch (this) {
        WordLevel.preK => 'PK',
        WordLevel.kindergarten => 'K',
        WordLevel.grade1 => '1',
        WordLevel.grade2 => '2',
        WordLevel.grade3 => '3',
        WordLevel.grade4 => '4',
        WordLevel.grade5 => '5',
        WordLevel.academic => 'AC',
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
