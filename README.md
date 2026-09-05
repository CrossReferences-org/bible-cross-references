# Cross-References Data

Phrase-level Bible cross-references exported from [CrossReferences.org](https://crossreferences.org).

This dataset is derived from the Treasury of Scripture Knowledge (originally anchored to KJV phrasing) and restructures it so that each translation has its own anchor phrases mapped to its own text and versification.

## Important Note
This is a work in progress. The mapping to new translations are complete. A second pass remains to be done to improve the quality of the mappings. [See Report](general_report.md) for details.

## On Curation
The reference set is not a verbatim copy of TSK. References are added, split, merged, or removed where doing so serves the reader. Such changes are deliberate and conservative (currently well under 1% of the set) and are expected to grow modestly as the project matures.  

The aim is to improve the connections themselves, not to pile more references onto every verse. References are removed when they make more sense in the other direction, or when they depend on KJV phrasing that doesn't carry into other translations. A shorter, sounder list serves the reader better — and following the references onward, from verse to verse, recovers the wider picture when it is wanted. Have a look at [this experiment](https://crossreferences.org/sandbox/connection-explorer) to see what becomes possible.

## Format

### JSON

The json folder includes everything you need to get started with you own app or research.
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
    "sort": 2,
    "kjv": "beginning",  
    "bsb": "beginning",  // The phase in the verse to which the references are anchored
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

Example (`bsb/crossreferences_bsb.tsv`):

```
Gen	1	1	beginning	Prov 8:22-24|Prov 16:4|Mark 13:19|John 1:1-3|Heb 1:10|1 John 1:1
```

Example (`s21/crossreferences_s21.tsv`):

```
Gn	1	1	Au commencement	Pr 8:22-24|Pr 16:4|Mc 13:19|Jn 1:1-3|Hé 1:10|1 Jn 1:1
```

## Translations

| Code | Translation | Language | Status | License |
|---|---|---|---|---|
| KJV | King James Version | English | Complete | Public domain |
| BSB | Berean Standard Bible | English | Pass 1 Complete | Public domain |
| S21 | Segond 21 | French | Pass 1 Complete | Used with permission from Société Biblique de Genève |
| AOV | Afrikaanse Ou Vertaling | Afrikaans | Pass 1 Complete | Public domain |

**Note on S21:** The Segond 21 Bible text is © Société Biblique de Genève. This dataset contains only the anchor phrases (short fragments used to locate cross-references within a verse), not the full Bible text.

## License

The cross-reference data in this repository is licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).

## About

This data is maintained as part of [CrossReferences.org](https://crossreferences.org), a free Bible study tool. The Treasury of Scripture Knowledge is a remarkable work, and this project stands on it gratefully. The aim is to make it accessible across translations, languages, and devices, as well as to refine it where appropriate.
