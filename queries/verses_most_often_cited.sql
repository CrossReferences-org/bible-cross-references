-- Verses most often cited, counting inward rather than outward. Top 50
-- One row per reference group, keeping its position so the group stays identifiable.
create or replace temp table groups as
(select x.verse_id citing_id, x.sort anchor_sort,
        unnest(x.refs) grp, unnest(range(1, len(x.refs) + 1)) pos,
 from '../json/cross_references.json' x);

-- Resolve each group's ids to BSB verses. The distinct stops a verse stored as
-- several records (superscriptions, versification splits) counting more than once
-- per group. The citing side is resolved too, so a split citing verse counts once.
create or replace temp table citations as
(select distinct g.citing_id, g.anchor_sort, g.pos,
        v.book_id, v.bsb_ch, v.bsb_vs,
        cv.book_id citing_book, cv.bsb_ch citing_ch, cv.bsb_vs citing_vs,
 from (select citing_id, anchor_sort, pos, unnest(grp) cited_id from groups) g
 inner join '../json/bible_verses.json' v on v.id = g.cited_id
 inner join '../json/bible_verses.json' cv on cv.id = g.citing_id);

create or replace temp table verse_text as
(select book_id, bsb_ch, bsb_vs,
        string_agg(bsb_text, ' ' order by bsb_sort) "text",
 from '../json/bible_verses.json'
 group by all);

with prel as (select c.book_id, b.name_eng book, c.bsb_ch chapter, c.bsb_vs verse,
                     count(*) citations,
                     count(distinct (c.citing_book, c.citing_ch, c.citing_vs)) citing_verses,
                     t."text",
              from citations c
              inner join '../json/bible_books.json' b on b.id = c.book_id
              inner join verse_text t on t.book_id = c.book_id
                                     and t.bsb_ch = c.bsb_ch
                                     and t.bsb_vs = c.bsb_vs
              group by all)
select row_number() over (order by citations desc, book_id, chapter, verse) "#",
	   citations "Citations", citing_verses "Citing Verses",
       format('{} {}:{}', book, chapter, verse) Verse,
       "text" "Text",
from prel
order by "#"
limit 50;
