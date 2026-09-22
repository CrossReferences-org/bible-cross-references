-- Anchors with most passages referenced. Top 50
with prel as (select x.verse_id, x.sort,
                     v.book_id, b.name_eng book, v.bsb_ch chapter, v.bsb_vs verse,
                     len(x.refs) passages,
                     len(flatten(x.refs)) verses_referenced,
                     v.bsb_text "text",
                     x.bsb anchor_phrase,
              from '../json/cross_references.json' x
              inner join '../json/bible_verses.json' v on v.id = x.verse_id
              inner join '../json/bible_books.json' b on b.id=v.book_id)
select row_number() over (order by passages desc, book_id, chapter, verse, sort) "#",
	   passages "Passages", verses_referenced "Verses",
       format('{} {}:{}', book, chapter, verse) Verse,
       anchor_phrase "Anchor Phrase",
       text "Text"
from prel
order by "#"
limit 50;