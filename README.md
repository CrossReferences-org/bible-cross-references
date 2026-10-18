# Cross-References Data

Phrase-level Bible cross-references exported from [CrossReferences.org](https://crossreferences.org).

This dataset is derived from the Treasury of Scripture Knowledge (originally anchored to KJV phrasing) and restructures it so that each translation has its own anchor phrases mapped to its own text and versification.

If you want to explore the data _interactively_, check out the [Bible Reader](https://crossreferences.org/read/19/23/BSB/) (code is [here](https://github.com/CrossReferences-org/reader-template)).

## Phrase-Level References
References are attached to the words they explain, usually a word or short phrase, sometimes the whole verse, as in the Treasury of Scripture Knowledge. When a verse holds several ideas, this shows the reader why each passage is cited, and lets them follow one thread at a time.

**Job 1:21** has four anchor phrases. Below are its references as one list for the verse, and then grouped by phrase.

> saying: “**Naked I came**<sup>1</sup> from my mother’s womb, and naked I will return. **The LORD gave**<sup>2</sup>, and **the LORD has taken away**<sup>3</sup>. **Blessed be the name of the LORD**<sup>4</sup>.”

**As one list for the verse** (27 references):

> Gen 3:19 · Gen 30:2 · Gen 45:5 · 1 Sam 3:18 · 2 Sam 16:12 · 1 Kgs 12:15 · 2 Kgs 20:19 · Job 1:11 · Job 2:10 · Ps 34:1 · Ps 39:9 · Ps 49:17 · Ps 89:38-52 · Eccl 5:15 · Eccl 5:19 · Eccl 12:7 · Isa 24:15 · Isa 42:24 · Isa 45:7 · Lam 3:38 · Amos 3:6 · Matt 20:15 · Acts 4:28 · Eph 5:20 · 1 Thess 5:18 · 1 Tim 6:7 · Jas 1:17

**Anchored to phrases:**

|  | Phrase | References |
|---|---|---|
| 1 | Naked I came | Gen 3:19 · Ps 49:17 · Eccl 5:15 · Eccl 12:7 · 1 Tim 6:7 |
| 2 | The LORD gave | Job 2:10 · Gen 30:2 · Eccl 5:19 · Lam 3:38 · Jas 1:17 |
| 3 | the LORD has taken away | Gen 45:5 · 2 Sam 16:12 · 1 Kgs 12:15 · Ps 39:9 · Isa 42:24 · Isa 45:7 · Amos 3:6 · Matt 20:15 · Acts 4:28 |
| 4 | Blessed be the name of the LORD | Job 1:11 · 1 Sam 3:18 · 2 Kgs 20:19 · Ps 34:1 · Ps 89:38-52 · Isa 24:15 · Eph 5:20 · 1 Thess 5:18 |

## On Curation
The reference set is not a verbatim copy of TSK. References are added, split, merged, or removed where doing so serves the reader. Such changes are deliberate and conservative (currently well under 1% of the set) and are expected to grow modestly as the project matures.  

The aim is to improve the connections themselves, not to pile more references onto every verse. References are removed when they make more sense in the other direction, or when they depend on KJV phrasing that doesn't carry into other translations. A shorter, sounder list serves the reader better — and following the references onward, from verse to verse, recovers the wider picture when it is wanted. Have a look at [this experiment](https://crossreferences.org/sandbox/connection-explorer) to see what becomes possible.

Refinements are released in rolling updates; [the report](general_report.md) tracks anchor quality across translations.

## Format

### JSON

The json folder includes everything you need to get started with your own app or research.
#### bible_books.json
```json
{
    "id": 1,
    "name_eng": "Genesis",
    "name_fra": "Genèse",
    "name_afr": "Genesis",
    "abbreviation_eng": "Gen",
    "abbreviation_fra": "Gn",
    "abbreviation_afr": "Gen"
  },
```
#### bible_verses.json
```json
{
    "id": 10,
    "book_id": 1,
    "kjv_ch": 1,
    "kjv_vs": 1,
    "kjv_sort": 1,
    "kjv_text": "In the beginning God created the heaven and the earth.",
    "bsb_ch": 1,
    "bsb_vs": 1,
    "bsb_sort": 1,
    "bsb_text": "In the beginning God created the heavens and the earth.",
    "aov_ch": 1,
    "aov_vs": 1,
    "aov_sort": 1,
    "aov_text": "IN die begin het God die hemel en die aarde geskape."
  },
```

#### cross_references.json
```jsonc
{
    "verse_id": 10,  // References are for this verse
    "sort": 1,
    "kjv": "beginning",  
    "bsb": "beginning",  // The phrase in the verse to which the references are anchored
    "aov": "IN die begin",
    "s21": "commencement",
    "refs": [   // Each entry is a collection of verses meant to be one reference
      [166970, 166980, 166990],  // Prov 8:22-24
      [169170],                  // Prov 16:4
      [248100],                  // Mark 13:19
      [261190, 261200, 261210],  // John 1:1-3
      [300490],                  // Heb 1:10
      [306170]                   // 1 John 1:1
    ]
  },
```
### TSV
Each translation has a single TSV file with five columns:

| Column | Description |
|---|---|
| `book` | Book abbreviation in the translation's language |
| `chapter` | Chapter number |
| `verse` | Verse number |
| `anchor` | The phrase in the verse that the cross-references are anchored to |
| `references` | Target references, separated by `\|` |

Example (`tsv/crossreferences_bsb.tsv`):

```
Gen	1	1	beginning	Prov 8:22-24|Prov 16:4|Mark 13:19|John 1:1-3|Heb 1:10|1 John 1:1
```

Example (`tsv/crossreferences_s21.tsv`):

```
Gn	1	1	commencement	Pr 8:22-24|Pr 16:4|Mc 13:19|Jn 1:1-3|He 1:10|1 Jn 1:1
```

### SQL

The [`queries`](queries/) folder has a few [DuckDB](https://duckdb.org) queries that run
straight against the JSON files — top-cited verses, densest chapters, and so on.
Run them from inside that folder, since the paths are relative:
```
cd queries
duckdb < verses_most_often_cited.sql
```
They double as worked examples if you want to write your own.


## Translations

| Code | Translation | Language | Status | License |
|---|---|---|---|---|
| KJV | King James Version | English | Complete | Public domain |
| BSB | Berean Standard Bible | English | Complete | Public domain |
| S21 | Segond 21 | French | Complete | Used with permission from Société Biblique de Genève |
| AOV | Afrikaanse Ou Vertaling | Afrikaans | Complete | Public domain |

**Note on S21:** The Segond 21 Bible text is © Société Biblique de Genève. This dataset contains only the anchor phrases (short fragments used to locate cross-references within a verse), not the full Bible text.

## License

The cross-reference data in this repository is licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).

## Corrections

Corrections are welcome. [Open an issue](../../issues/new?title=Correction:%20&labels=correction&body=**Verse:**%20%0A**Anchor%20phrase:**%20%0A**Reference:**%20%0A%0A**Why:**%20)
with the verse, the anchor phrase, and why you think the reference is wrong.
Note that the data files are _generated exports_, so pull requests against them
can't be merged.

## About

This data is maintained as part of [CrossReferences.org](https://crossreferences.org), a free Bible study tool. The Treasury of Scripture Knowledge is a remarkable work, and this project stands on it gratefully. The aim is to make it accessible across translations, languages, and devices, as well as to refine it where appropriate.
