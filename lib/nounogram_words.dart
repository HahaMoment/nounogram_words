/// Graded English word lists (Pre-K through Grade 12, then three tiers by
/// how common the words are) and a lexicon, built from open sources.
///
/// The lists are data files under `lib/data/`; [WordStore] loads them on
/// demand through a reader the caller supplies. See README for sources,
/// licensing, and how the levels were derived.
library;

export 'src/lexicon.dart';
export 'src/word_levels.dart';
export 'src/word_store.dart';
