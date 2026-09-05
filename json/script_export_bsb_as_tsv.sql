-- DuckDB script
-- Extract the BSB and export it as TSV
copy (select b.id book_nr,
                b.name_eng book_name,
                b.abbreviation_eng book_abbreviation,
                v.bsb_ch chapter,
                v.bsb_vs verse,
                string_agg(v.bsb_text, ' ' order by v.bsb_sort) "text", -- aggregate because of verses that are split into multiple records
         from 'bible_verses.json' v
         inner join 'bible_books.json' b on b.id=v.book_id
         group by all
         order by b.id, chapter, verse)
         to 'bible_bsb.tsv' (DELIMITER '\t', HEADER);
