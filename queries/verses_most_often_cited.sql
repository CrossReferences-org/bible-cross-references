-- Verses most often cited, counting inward rather than outward. Top 50
create or replace temp table citations as
(select x.verse_id citing_id, unnest(flatten(x.refs)) cited_id,
 from '../json/cross_references.json' x);

create or replace temp table verse_text as
(select book_id, bsb_ch, bsb_vs,
        string_agg(bsb_text, ' ' order by bsb_sort) "text",
 from '../json/bible_verses.json'
 group by all);

with prel as (select v.book_id, b.name_eng book, v.bsb_ch chapter, v.bsb_vs verse,
                     count(*) citations,
                     count(distinct c.citing_id) citing_verses,
                     t."text",
              from citations c
              inner join '../json/bible_verses.json' v on v.id = c.cited_id
              inner join '../json/bible_books.json' b on b.id = v.book_id
              inner join verse_text t on t.book_id = v.book_id
                                     and t.bsb_ch = v.bsb_ch
                                     and t.bsb_vs = v.bsb_vs
              group by all)
select row_number() over (order by citations desc) "#",
	   citations "Citations", citing_verses "Citing Verses",
       format('{} {}:{}', book, chapter, verse) Verse,
       "text" "Text",
from prel
order by citations desc
limit 50;
