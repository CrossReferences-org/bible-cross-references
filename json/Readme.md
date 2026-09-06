# bible_books.json

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

# bible_verses.json

```json
{
    "id": 10,
    "book_id": 1,  <-- Join on bible_books.json's id
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

## Verse ID

Verse IDs are generally 10 apart, but not always. Due to versification 
differences some verses had to be split into multiple records. To leave
room for insertion of records when splitting, a gap of 10 was chosen.
Some records will therefore have IDs that are not a multiple of 10.

## Sort fields
When reconstructing any given verse you will need to sort it, since 
the records are only in reading order once ordered by that 
translation's own sort field.

To rebuild a verse: take every record matching that translation's `ch`
and `vs`, order by its `sort`, concatenate the text.

Each translation has its own sort field because the split falls in a
different place in each. Below, one passage divides three ways:

|     | 3:19             | 3:20             |
|-----|------------------|------------------|
| KJV | 270900, 270905   | 270910           |
| BSB | 270900           | 270905, 270910   |
| AOV | 270900, 270905   | 270910           |

```json

{
    "id": 270900,
    "book_id": 44,
    "kjv_ch": 3,
    "kjv_vs": 19,
    "kjv_sort": 1,  
    "kjv_text": "Repent ye therefore, and be converted, that your sins may be blotted out,",
    "bsb_ch": 3,
    "bsb_vs": 19,
    "bsb_sort": 1,
    "bsb_text": "Repent, then, and turn back, so that your sins may be wiped away,",
    "aov_ch": 3,
    "aov_vs": 19,
    "aov_sort": 1,
    "aov_text": "Kom dan tot inkeer en bekeer julle, sodat julle sondes uitgewis kan word"
  },
  {
    "id": 270905,
    "book_id": 44,
    "kjv_ch": 3,
    "kjv_vs": 19,
    "kjv_sort": 2,  <--
    "kjv_text": "when the times of refreshing shall come from the presence of the Lord;",
    "bsb_ch": 3,
    "bsb_vs": 20,
    "bsb_sort": 1,
    "bsb_text": "that times of refreshing may come from the presence of the Lord,",
    "aov_ch": 3,
    "aov_vs": 19,
    "aov_sort": 2,  <--
    "aov_text": "en tye van verkwikking van die aangesig van die Here mag kom,"
  },
  {
    "id": 270910,
    "book_id": 44,
    "kjv_ch": 3,
    "kjv_vs": 20,
    "kjv_sort": 1,
    "kjv_text": "And he shall send Jesus Christ, which before was preached unto you:",
    "bsb_ch": 3,
    "bsb_vs": 20,
    "bsb_sort": 2,  <--
    "bsb_text": "and that He may send Jesus, the Christ, who has been appointed for you.",
    "aov_ch": 3,
    "aov_vs": 20,
    "aov_sort": 1,
    "aov_text": "en Hy Hom mag stuur wat vooraf aan julle verkondig is, naamlik Jesus Christus,"
  },
```

# cross_references.json
```jsonc
{
    "verse_id": 10,  // References are for this verse
    "sort": 1,
    "kjv": "beginning",  
    "bsb": "beginning",  // The phrase in the verse to which the references are anchored
    "aov": "IN die begin",
    "s21": "commencement",
    "refs": [   // Each entry is a collection of verses meant to be one reference
                // Join on bible_verses.json's id
      [166970, 166980, 166990],  // Prov 8:22-24
      [169170],                  // Prov 16:4
      [248100],                  // Mark 13:19
      [261190, 261200, 261210],  // John 1:1-3
      [300490],                  // Heb 1:10
      [306170]                   // 1 John 1:1
    ]
  },
```
## Nesting in `refs` field
While it might be tempting to collapse all the references into one flat list of verse IDs,
doing so would lose important information. In the example above, there are 6 entries,
each having meaning and intent. The two entries that have multiple verses, namely
`Prov 8:22-24` and `John 1:1-3` are meant to be read as such, not as 6 unconnected
verses. 

You may of course use this data as you wish. This is just a note to inform you of the 
cost flattening would entail.

## What `sort` is for

`sort` orders the anchors within a verse, and it exists for the KJV specifically.

The Treasury of Scripture Knowledge locates its anchors sequentially: the second anchor's 
phrase is understood to be the next occurrence after the first, the third after the 
second, and so on. Where a word appears more than once in a verse, this ordering is the 
only thing that identifies which occurrence is meant.

For the other translations there is no cursor. The anchor is simply matched against the 
verse, in the expectation of finding it once.

## A note on S21

The Segond 21 appears in cross_references.json as an anchor phrase only. 
There is no `s21_text` in bible_verses.json, and no S21 chapter or verse numbering.

This is a licensing boundary, not an omission. The S21 text is © Société Biblique de Genève; 
the dataset carries only the short fragments needed to locate a reference within a verse. 
Building an S21 reader from this data would require the text from its rights holder.
