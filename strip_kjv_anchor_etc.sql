-- =====================================================================
-- strip_kjv_anchor_etc.sql
--
-- Strips the trailing ", etc" / ", etc." from cross_reference.kjv_anchor
--   "Do not, etc"        ->  "Do not"
--   "for the tree, etc." ->  "for the tree"
--
-- Only matches at the END of the string, so ", etc" appearing mid-anchor
-- is left untouched.
--
-- EXCLUSIONS: anchors listed in the exclusions table below are skipped
-- even though they match the pattern. Add to that INSERT if the preview
-- turns up other prose-style anchors that should keep their ", etc".
--
-- Safety: runs in one transaction; takes a backup table first; aborts on
--         any assertion failure, leaving the database untouched.
--
-- Run with:
--   psql -h 127.0.0.1 -p 5432 -U django_user -d project_bible \
--        -v ON_ERROR_STOP=1 -f strip_kjv_anchor_etc.sql
--
-- NOTE: bypasses django-auditlog. No LogEntry rows are written.
-- =====================================================================

\set ON_ERROR_STOP on
\timing on
\pset pager off

BEGIN;

SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '120s';

-- ---------------------------------------------------------------------
-- 0. Anchors to leave alone. Add rows here as needed.
-- ---------------------------------------------------------------------
CREATE TEMP TABLE anchor_etc_exclusions (txt text PRIMARY KEY);

INSERT INTO anchor_etc_exclusions (txt) VALUES
    ('or, the verse may be read, being an husband among his people, he shall not defile himself for his wife, etc');

-- ---------------------------------------------------------------------
-- 1. Backup. Fails loudly if the table already exists, which means this
--    script has already been run against this database.
-- ---------------------------------------------------------------------
CREATE TABLE cross_reference_anchor_etc_backup_20260911 AS
SELECT id, kjv_anchor
FROM cross_reference
WHERE kjv_anchor ~ ',\s*etc\.?\s*$'
  AND btrim(kjv_anchor) NOT IN (SELECT txt FROM anchor_etc_exclusions);

-- ---------------------------------------------------------------------
-- 2. Pre-flight checks, the update, and post-flight checks.
--    Any RAISE EXCEPTION here rolls the whole thing back.
-- ---------------------------------------------------------------------
DO $$
DECLARE
    n_target    integer;
    n_backup    integer;
    n_excluded  integer;
    n_empty     integer;
    n_updated   integer;
    n_remaining integer;
BEGIN
    SELECT count(*) INTO n_target
    FROM cross_reference
    WHERE kjv_anchor ~ ',\s*etc\.?\s*$'
      AND btrim(kjv_anchor) NOT IN (SELECT txt FROM anchor_etc_exclusions);

    SELECT count(*) INTO n_backup
    FROM cross_reference_anchor_etc_backup_20260911;

    SELECT count(*) INTO n_excluded
    FROM cross_reference
    WHERE btrim(kjv_anchor) IN (SELECT txt FROM anchor_etc_exclusions);

    RAISE NOTICE 'Rows matching trailing ", etc": %', n_target;
    RAISE NOTICE 'Rows captured in backup table:  %', n_backup;
    RAISE NOTICE 'Rows deliberately excluded:     %', n_excluded;

    IF n_target = 0 THEN
        RAISE EXCEPTION 'Nothing to update. Already run against this database?';
    END IF;

    IF n_target <> n_backup THEN
        RAISE EXCEPTION 'Backup count (%) does not match target count (%)',
            n_backup, n_target;
    END IF;

    IF n_excluded = 0 THEN
        RAISE EXCEPTION 'No exclusion rows matched. Check the exclusions text against the live data.';
    END IF;

    -- Guard: no anchor may be reduced to an empty string.
    SELECT count(*) INTO n_empty
    FROM cross_reference
    WHERE kjv_anchor ~ ',\s*etc\.?\s*$'
      AND btrim(kjv_anchor) NOT IN (SELECT txt FROM anchor_etc_exclusions)
      AND btrim(regexp_replace(kjv_anchor, ',\s*etc\.?\s*$', '')) = '';

    IF n_empty > 0 THEN
        RAISE EXCEPTION '% row(s) would be left with an empty anchor', n_empty;
    END IF;

    -- The actual update.
    UPDATE cross_reference
    SET kjv_anchor = btrim(regexp_replace(kjv_anchor, ',\s*etc\.?\s*$', ''))
    WHERE kjv_anchor ~ ',\s*etc\.?\s*$'
      AND btrim(kjv_anchor) NOT IN (SELECT txt FROM anchor_etc_exclusions);

    GET DIAGNOSTICS n_updated = ROW_COUNT;
    RAISE NOTICE 'Rows updated: %', n_updated;

    IF n_updated <> n_target THEN
        RAISE EXCEPTION 'Updated % row(s), expected %', n_updated, n_target;
    END IF;

    -- Nothing left but the deliberate exclusions.
    SELECT count(*) INTO n_remaining
    FROM cross_reference
    WHERE kjv_anchor ~ ',\s*etc\.?\s*$'
      AND btrim(kjv_anchor) NOT IN (SELECT txt FROM anchor_etc_exclusions);

    IF n_remaining <> 0 THEN
        RAISE EXCEPTION '% row(s) still carry a trailing ", etc"', n_remaining;
    END IF;

    -- Nothing blank, and no dangling comma, in the touched set.
    SELECT count(*) INTO n_empty
    FROM cross_reference c
    JOIN cross_reference_anchor_etc_backup_20260911 b ON b.id = c.id
    WHERE btrim(c.kjv_anchor) = '' OR c.kjv_anchor ~ ',\s*$';

    IF n_empty > 0 THEN
        RAISE EXCEPTION '% row(s) ended up empty or with a dangling comma', n_empty;
    END IF;

    RAISE NOTICE 'All checks passed.';
END
$$;

-- ---------------------------------------------------------------------
-- 3. Confirm the exclusions survived untouched.
-- ---------------------------------------------------------------------
SELECT id, kjv_anchor
FROM cross_reference
WHERE btrim(kjv_anchor) IN (SELECT txt FROM anchor_etc_exclusions)
ORDER BY id;

-- ---------------------------------------------------------------------
-- 4. Spot-check a sample of the changes, longest first.
-- ---------------------------------------------------------------------
SELECT b.id, b.kjv_anchor AS before, c.kjv_anchor AS after
FROM cross_reference_anchor_etc_backup_20260911 b
JOIN cross_reference c ON c.id = b.id
ORDER BY length(b.kjv_anchor) DESC
LIMIT 25;

COMMIT;

-- ---------------------------------------------------------------------
-- Rollback after commit, if ever needed:
--
--   UPDATE cross_reference c
--   SET kjv_anchor = b.kjv_anchor
--   FROM cross_reference_anchor_etc_backup_20260911 b
--   WHERE c.id = b.id;
--
-- Clean up once you are satisfied:
--
--   DROP TABLE cross_reference_anchor_etc_backup_20260911;
-- ---------------------------------------------------------------------
