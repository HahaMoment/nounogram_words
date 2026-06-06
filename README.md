# nounogram_words

Graded English word lists — **Pre-K through Academic** — built from open
sources, for the [Nounogram](https://github.com/HahaMoment) puzzle game (and
reusable by anyone).

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
| 7 | Academic | New Academic Word List (AWL) headwords |

Only plain A–Z words of length ≥ 2 are kept. The AWL contributes **headwords
only** — its inflected/derived sub-words are dropped to keep the lists clean.

> Grades 6–12 are intentionally not yet split per-grade; that awaits adding the
> NGSL/NAWL (CC BY-SA) sources, which would change the data licence to CC BY-SA.

## Layout

- `data/grade-*.txt` — per-level word lists (canonical, reusable).
- `data/word-levels.csv` — flat `word,level_index,level`.
- `lib/` — Dart binding: `WordLevel`, `levelOf(word)`, `wordsUpToLevel(level)`.
- `tool/build.dart` — regenerates everything from `tool/data/` sources.

Rebuild with `dart run tool/build.dart`.

## Sources & licensing

**Code** (`lib/`, `tool/`): MIT.

**Word data** (`data/`, `lib/src/word_levels_data.dart`): our compilation and
level assignments are dedicated to the public domain (CC0 1.0). The underlying
sources:

- **Fry Instant Word List** (Edward Fry) — public domain.
- **Dolch sight words** (Edward Dolch) — public domain.
- **New Academic Word List / Academic Word List** — © Averil Coxhead, Victoria
  University of Wellington; free to use, attribution requested.
  <https://www.wgtn.ac.nz/lals/resources/academicwordlist>

If you use this data, crediting the AWL is appreciated.
