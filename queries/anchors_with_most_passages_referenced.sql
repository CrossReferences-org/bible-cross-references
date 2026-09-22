-- Anchors with most passages referenced. Top 50
-- Verses referenced, counted as BSB verses per reference group, so a verse
-- stored as several records (superscriptions, versification splits) counts once.
with group_verses as (select distinct g.verse_id, g.sort, g.pos,
                             v.book_id, v.bsb_ch, v.bsb_vs,
                      from (select verse_id, sort, pos, unnest(grp) cited_id
                            from (select x.verse_id, x.sort,
                                         unnest(x.refs) grp,
                                         unnest(range(1, len(x.refs) + 1)) pos,
                                  from '../json/cross_references.json' x)) g
                      inner join '../json/bible_verses.json' v on v.id = g.cited_id),
     verse_counts as (select verse_id, sort, count(*) verses_referenced,
                      from group_verses
                      group by all),
     prel as (select x.verse_id, x.sort,
                     v.book_id, b.name_eng book, v.bsb_ch chapter, v.bsb_vs verse,
                     len(x.refs) passages,
                     c.verses_referenced,
                     v.bsb_text "text",
                     x.bsb anchor_phrase,
              from '../json/cross_references.json' x
              inner join '../json/bible_verses.json' v on v.id = x.verse_id
              inner join '../json/bible_books.json' b on b.id=v.book_id
              inner join verse_counts c on c.verse_id = x.verse_id and c.sort = x.sort)
select row_number() over (order by passages desc, book_id, chapter, verse, sort) "#",
	   passages "Passages", verses_referenced "Verses",
       format('{} {}:{}', book, chapter, verse) Verse,
       anchor_phrase "Anchor Phrase",
       text "Text"
from prel
order by "#"
limit 50;
