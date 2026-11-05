/// Reading levels a word can belong to, ordered easiest-first. The index is
/// the level number in `data/word-levels.csv`.
///
/// Pre-K through Grade 12 come from curriculum lists and carry a grade claim.
/// The three levels after them continue the pool for adult players and claim
/// only how common the words are (see tool/build.dart).
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
  grade12,
  familiar,
  uncommon,
  obscure;

  /// The last level that is a school grade.
  static const lastGrade = grade12;

  /// Whether this level names a school grade (as opposed to a tier past them).
  bool get isGrade => index <= lastGrade.index;

  /// A full label for menus ("Kindergarten", "Grade 1", "Familiar").
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
        WordLevel.familiar => 'Familiar',
        WordLevel.uncommon => 'Uncommon',
        WordLevel.obscure => 'Obscure',
      };

  /// A compact badge ("PK", "K", "1" … "12", "F", "U", "O") for tagging
  /// words inline.
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
        WordLevel.familiar => 'F',
        WordLevel.uncommon => 'U',
        WordLevel.obscure => 'O',
      };

  /// The data file holding this level's words, relative to `lib/data/`.
  String get fileName => switch (this) {
        WordLevel.preK => 'grade-prek.txt',
        WordLevel.kindergarten => 'grade-k.txt',
        WordLevel.grade1 => 'grade-1.txt',
        WordLevel.grade2 => 'grade-2.txt',
        WordLevel.grade3 => 'grade-3.txt',
        WordLevel.grade4 => 'grade-4.txt',
        WordLevel.grade5 => 'grade-5.txt',
        WordLevel.grade6 => 'grade-6.txt',
        WordLevel.grade7 => 'grade-7.txt',
        WordLevel.grade8 => 'grade-8.txt',
        WordLevel.grade9 => 'grade-9.txt',
        WordLevel.grade10 => 'grade-10.txt',
        WordLevel.grade11 => 'grade-11.txt',
        WordLevel.grade12 => 'grade-12.txt',
        WordLevel.familiar => 'familiar.txt',
        WordLevel.uncommon => 'uncommon.txt',
        WordLevel.obscure => 'obscure.txt',
      };
}

/// The data file holding the lexicon, relative to `lib/data/`.
const lexiconFileName = 'lexicon.txt';
