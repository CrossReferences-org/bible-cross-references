-- DuckDB script
-- Extract the BSB and export it as TSV
copy (select b.id book_nr,
                b.name_afr book_name,
                b.abbreviation_afr book_abbreviation,
                v.aov_ch chapter,
                v.aov_vs verse,
                string_agg(v.aov_text, ' ' order by v.aov_sort) "text", -- aggregate because of verses that are split into multiple records
         from 'bible_verses.json' v
         inner join 'bible_books.json' b on b.id=v.book_id
         group by all
         order by b.id, chapter, verse)
         to 'bible_aov.tsv' (DELIMITER '\t', HEADER);
