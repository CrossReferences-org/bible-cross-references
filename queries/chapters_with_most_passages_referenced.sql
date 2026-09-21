-- Chapters with most passages referenced. Top 50, ordered by density.
create or replace temp table chapter_counts as 
(select v.book_id, v.bsb_ch, count(distinct v.bsb_vs) verse_count,
 from '../json/bible_verses.json' v
 group by all);

create or replace temp table prel as
(select 
       v.book_id, b.name_eng book, v.bsb_ch chapter,
       sum(len(x.refs)) passages,
       count(*) anchor_phrases,
       c.verse_count,
from '../json/cross_references.json' x
inner join '../json/bible_verses.json' v on v.id = x.verse_id
inner join '../json/bible_books.json' b on b.id=v.book_id
inner join chapter_counts c on c.book_id=b.id and c.bsb_ch=v.bsb_ch
group by all);

create or replace table output as
select row_number() over (order by passages / verse_count desc) "#",
	   passages::int "Passages Referenced", 
       anchor_phrases::int "Anchor Phrases",
       format('{} {}', book, chapter) Chapter,
       verse_count::int,
       round(passages / verse_count, 1) "Avg Passages/Verse",
from prel 
order by "Avg Passages/Verse" desc
limit 50;

select * from output
union all
select null,
	   round(avg(passages))::int, 
       round(avg(anchor_phrases))::int, 
       '** Average **', 
       round(avg(verse_count))::int, 
       round(sum(passages) / sum(verse_count), 1),
from prel
order by "Avg Passages/Verse" desc

