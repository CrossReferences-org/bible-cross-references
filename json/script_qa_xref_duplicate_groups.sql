-- Check 15b: the same reference group listed more than once under one anchor.
-- Run with the three JSON files in the current directory.

CREATE OR REPLACE VIEW books  AS SELECT * FROM read_json('bible_books.json');
CREATE OR REPLACE VIEW verses AS SELECT * FROM read_json('bible_verses.json');
CREATE OR REPLACE VIEW xrefs  AS SELECT * FROM read_json('cross_references.json');

-- verse id -> "Gen 1:1"
CREATE OR REPLACE VIEW vlbl AS
SELECT v.id, b.abbreviation_eng || ' ' || v.kjv_ch || ':' || v.kjv_vs AS ref
FROM verses v JOIN books b ON b.id = v.book_id;

-- same thing as a map, so ids inside a refs group can be labelled without unnesting
CREATE OR REPLACE TABLE lbl AS SELECT map(list(id), list(ref)) AS m FROM vlbl;

-- one row per (anchor, ref group), keeping the group's ordinal position in refs
CREATE OR REPLACE VIEW anchor_groups AS
SELECT * FROM (
  SELECT verse_id,
         sort,
         kjv,
         unnest(refs)                  AS grp,
         unnest(range(1, len(refs)+1)) AS pos
  FROM xrefs
);

WITH dups AS (
  SELECT verse_id,
         sort,
         kjv,
         grp,
         count(*)                           AS occurrences,
         list_sort(list(pos))               AS positions,
         max(pos) - min(pos) = count(*) - 1 AS adjacent
  FROM anchor_groups
  GROUP BY verse_id, sort, kjv, grp
  HAVING count(*) > 1
)
SELECT h.ref                                              	AS verse,
       d.sort                                             	AS anchor_no,
       d.kjv                                              	AS anchor,
       list_transform(d.grp, lambda x: map_extract(l.m, x)[1]) 	AS dup_group,
       d.grp                                              	AS dup_group_ids,
       d.occurrences,
       d.positions,
       d.adjacent
FROM dups d
JOIN vlbl h ON h.id = d.verse_id
CROSS JOIN lbl l
ORDER BY d.verse_id, d.sort, d.positions[1];
