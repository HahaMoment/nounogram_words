# nounogram_words

Graded English word lists — **per grade, Pre-K through Grade 12, then three
tiers by how common the words are** — and a lexicon, built from open sources
for the [Nounogram](https://nounogram.com) puzzle game (and reusable by
anyone).

Each word is tagged with the **earliest** reading level it appears at, so a word
a young child already knows isn't labelled harder than it is.

## Levels

| Index | Level | Source |
|---|---|---|
| 0 | Pre-K | Dolch pre-primer |
| 1 | Kindergarten | Dolch primer + Dolch nouns, Fry 1–50 |
| 2 | Grade 1 | Dolch first grade, Fry 51–100 |
| 3 | Grade 2 | Dolch second grade, Fry 101–200 |
| 4 | Grade 3 | Dolch third grade, Fry 201–300 |
| 5 | Grade 4 | Fry 301–500 |
| 6 | Grade 5 | Fry 501–1000 |
| 7–9 | Grades 6–8 | NGSL, split into thirds by frequency rank |
| 10–13 | Grades 9–12 | NAWL, split into quarters by frequency rank |
| 14 | Familiar | 12dicts 3esl words rated common by SCOWL (tiers 10–20) |
| 15 | Uncommon | 12dicts 3esl words in SCOWL tier 35 |
| 16 | Obscure | the rest of 3esl, and 2of12 |

The grades carry a grade claim from curriculum lists. The three tiers after
them only say how common the words are; they come from lemma lists, so they
continue the pool without flooding it with inflections.

Only plain A–Z words of length ≥ 2 are kept.

## Lexicon

`lib/data/lexicon.txt` holds every plain word SCOWL knows up to tier 70, plus
every leveled word: a superset for checking that a string is an English word.
It is not a pool to draw answers from. `Lexicon.anagramsOf` lists the words a
bag of letters could spell, for checking that a scrambled word has one reading.

## Layout

- `lib/data/<level>.txt` — one file per level (`grade-prek.txt` … `obscure.txt`)
  and `lexicon.txt`. Under `lib/` so a Flutter app can bundle them as package
  assets (`packages/nounogram_words/data/<file>`).
- `data/word-levels.csv` — flat `word,level_index,level`.
- `lib/` — Dart binding: `WordLevel`, `WordStore` (loads levels on demand
  through a reader you supply), `Lexicon`. `package:nounogram_words/io.dart`
  has file readers for VM tools and tests.
- `tool/build.dart` — regenerates everything from `tool/data/` sources.
- `tool/overlap.dart` — how the levels sit against SCOWL's tiers.
- `bin/report.dart` — prints a per-level breakdown.

Rebuild with `dart run tool/build.dart`; report with `dart run bin/report.dart`.

## Usage

```dart
final store = WordStore((name) => rootBundle.loadString('packages/nounogram_words/data/$name'));
await store.ensureUpTo(WordLevel.grade12);   // at boot: ~4 000 words
final pool = store.wordsInRange(WordLevel.grade3, WordLevel.grade5);
await store.ensure([WordLevel.familiar]);    // when a puzzle in that band opens
final lexicon = await store.lexicon();       // when a solver needs it
```

## Sources

- Fry (public domain)
- Dolch (public domain)
- NGSL & NAWL (© Browne, Culligan & Phillips, CC BY-SA 4.0).
- SCOWL (© Kevin Atkinson, permissive) and 12dicts (Alan Beale, public domain).

See `NOTICE` for full attribution

## Licensing

- **Code** (`lib/`, `tool/`, `bin/`): MIT.
- **Word data** (`data/`, `lib/data/`): **CC BY-SA 4.0**
  (the NGSL/NAWL are ShareAlike, so the derived data is too). Free to use
  commercially with attribution; adaptations must stay CC BY-SA.

See `LICENSE` for terms.
