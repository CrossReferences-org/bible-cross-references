CREATE OR REPLACE MACRO squash(s) AS
  ' ' || trim(regexp_replace(s, '[^\p{L}\p{N}'']+', ' ', 'g')) || ' ';
CREATE OR REPLACE MACRO norm(s, keep_case := false, fuse := false) AS
  squash(
    CASE WHEN fuse
         THEN regexp_replace(
                CASE WHEN keep_case THEN s ELSE lower(s) END,
                '[-–—'']', '', 'g')
         ELSE CASE WHEN keep_case THEN s ELSE lower(s) END
    END
  );
WITH j AS (
  SELECT
    c.verse_id,
    c.sort AS xref_sort,
    unnest([
      {'translation': 'kjv', 'anchor': c.kjv, 'text': v.kjv_text},
      {'translation': 'bsb', 'anchor': c.bsb, 'text': v.bsb_text},
      {'translation': 'aov', 'anchor': c.aov, 'text': v.aov_text}
    ]) AS t
  FROM 'cross_references.json' c
  INNER JOIN 'bible_verses.json' v ON v.id = c.verse_id
),
m AS (
  SELECT
    verse_id,
    xref_sort,
    t.translation,
    t.anchor,
    t.text,
    contains(norm(t.text, keep_case := true),
             norm(t.anchor, keep_case := true))       AS exact_match,
    contains(norm(t.text), norm(t.anchor))            AS ci_match,
    contains(norm(t.text, fuse := true),
             norm(t.anchor, fuse := true))            AS fused_match,
    array_to_string(
      list_filter(
        str_split(trim(norm(t.anchor, fuse := true)), ' '),
        lambda w: NOT contains(norm(t.text, fuse := true), ' ' || w || ' ')
      ), '|'
    ) AS missing_words
  FROM j
)
SELECT *,
  CASE WHEN text IS NULL or text = ''               THEN 'empty_verse'
       WHEN anchor IS NULL OR anchor = ''           THEN 'empty_anchor'
       WHEN exact_match                             THEN 'exact'
       WHEN ci_match                                THEN 'case_only'
       WHEN fused_match                             THEN 'hyphenation'
       WHEN regexp_matches(anchor, 'A.*[0-9]')      THEN 'dating_comment'
       ELSE 'mismatch'
  END AS match_kind
FROM m
WHERE NOT coalesce(exact_match, false)
ORDER BY translation, match_kind, verse_id;
