# Cross-References Data

Phrase-level Bible cross-references exported from [CrossReferences.org](https://crossreferences.org).

This dataset is derived from the Treasury of Scripture Knowledge (originally anchored to KJV phrasing) and restructures it so that each translation has its own anchor phrases mapped to its own text and versification.

## Important Note
This is a work in progress. The mapping to new translations are not 100% complete, and a second pass remains to be done to improve quality. [See Report](general_report.md) for details.

## On Curation
The reference set is not a verbatim copy of TSK. References are added, split, merged, or removed where doing so serves the reader. Such changes are deliberate and conservative (currently well under 1% of the set) and are expected to grow modestly as the project matures.  

The aim is to improve the connections themselves, not to pile more references onto every verse. References are removed when they make more sense in the other direction, or when they rest on KJV phrasing that doesn't carry into other translations. A shorter, sounder list serves the reader better — and following the references onward, from verse to verse, recovers the wider picture when it is wanted. Have a look at [this experiment](https://crossreferences.org/sandbox/connection-explorer) to see what becomes possible.

## Format

Each translation has a single TSV file with five columns:

| Column | Description |
|---|---|
| `book` | Book abbreviation in the translation's language |
| `chapter` | Chapter number |
| `verse` | Verse number |
| `anchor` | The phrase in the verse that the cross-references are anchored to |
| `references` | Target references, separated by `\|` |

Example (`s21/crossreferences_s21.tsv`):

```
Gn	1	1	Au commencement	Pr 8:22-24|Pr 16:4|Mc 13:19|Jn 1:1-3|Hé 1:10|1 Jn 1:1
Gn	1	1	Dieu créa	Ps 33:6|Ps 136:5|Ac 17:24
```

## Parser

`parse_crossreferences.py` is a standalone Python script (no dependencies) that parses the TSV files into structured data:

```python
from parse_crossreferences import parse_file

for entry in parse_file('s21/crossreferences_s21.tsv'):
    print(entry['book'], entry['chapter'], entry['verse'])
    print(entry['anchor'])
    for ref in entry['references']:
        print(f"  {ref['book']} {ref['chapter']}:{ref['verses']}")
```

## Translations

| Code | Translation | Language | Status | License |
|---|---|---|---|---|
| KJV | King James Version | English | Complete | Public domain |
| BSB | Berean Standard Bible | English | In progress | Public domain |
| S21 | Segond 21 | French | Complete | Used with permission from Société Biblique de Genève |
| AOV | Afrikaanse Ou Vertaling | Afrikaans | In progress | Public domain |

**Note on S21:** The Segond 21 Bible text is © Société Biblique de Genève. This dataset contains only the anchor phrases (short fragments used to locate cross-references within a verse), not the full Bible text.

## License

The cross-reference data in this repository is licensed under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/).

The parser script is licensed under the [MIT License](https://opensource.org/licenses/MIT).

## About

This data is maintained as part of [CrossReferences.org](https://crossreferences.org), a free Bible study tool. The Treasury of Scripture Knowledge is a remarkable work, and this project stands on it gratefully. The aim is to make it accessible across translations, languages, and devices, as well as to refine it where appropriate.
