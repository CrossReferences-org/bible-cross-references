-- DuckDB script
-- Extract the KJV and export it as TSV
copy (select b.id book_nr,
                b.name_eng book_name,
                b.abbreviation_eng book_abbreviation,
                v.kjv_ch chapter,
                v.kjv_vs verse,
                string_agg(v.kjv_text, ' ' order by v.kjv_sort) "text", -- aggregate because of verses that are split into multiple records
         from 'bible_verses.json' v
         inner join 'bible_books.json' b on b.id=v.book_id
         group by all
         order by b.id, chapter, verse)
         to 'bible_kjv.tsv' (DELIMITER '\t', HEADER);
