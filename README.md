# nounogram_words

Graded English word lists — **per grade, Pre-K through Grade 12** — built from
open sources, for the [Nounogram](https://nounogram.com) puzzle game
(and reusable by anyone).

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

Only plain A–Z words of length ≥ 2 are kept.

## Layout

- `data/grade-*.txt` — per-grade word lists (canonical, reusable).
- `data/word-levels.csv` — flat `word,level_index,level`.
- `lib/` — Dart binding: `WordLevel`, `levelOf(word)`, `wordsUpToLevel(level)`.
- `tool/build.dart` — regenerates everything from `tool/data/` sources.
- `bin/report.dart` — prints a per-grade breakdown.

Rebuild with `dart run tool/build.dart`; report with `dart run bin/report.dart`.

## Sources

- Fry (public domain)
- Dolch (public domain)
- NGSL & NAWL (© Browne, Culligan & Phillips, CC BY-SA 4.0).

See `NOTICE` for full attribution

## Licensing

- **Code** (`lib/`, `tool/`, `bin/`): MIT.
- **Word data** (`data/`, `lib/src/word_levels_data.dart`): **CC BY-SA 4.0**
  (the NGSL/NAWL are ShareAlike, so the derived data is too). Free to use
  commercially with attribution; adaptations must stay CC BY-SA.

See `LICENSE` for terms.
