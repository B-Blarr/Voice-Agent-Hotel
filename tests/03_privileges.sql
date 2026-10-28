-- Least privilege: hotel_app may read the hotel and record requests and calls,
-- but may not change or delete anything.

BEGIN;

-- A role that stands for "everyone else" (PUBLIC).
CREATE ROLE ci_fremd NOLOGIN;

DO $$
BEGIN
    -- What the workflows need
    ASSERT has_table_privilege('hotel_app', 'zimmer', 'SELECT'), 'hotel_app muss zimmer lesen';
    ASSERT has_table_privilege('hotel_app', 'buchungsanfragen', 'INSERT'), 'hotel_app muss Buchungsanfragen anlegen';
    ASSERT has_table_privilege('hotel_app', 'rueckrufe', 'INSERT'), 'hotel_app muss Rueckrufe anlegen';
    ASSERT has_table_privilege('hotel_app', 'anrufe', 'INSERT'), 'hotel_app muss Anrufe anlegen';
    ASSERT has_function_privilege('hotel_app', 'verfuegbarkeit(date, date, int, int, int, boolean, boolean)', 'EXECUTE'),
        'hotel_app muss verfuegbarkeit() aufrufen';
    ASSERT has_function_privilege('hotel_app', 'alte_daten_loeschen()', 'EXECUTE'), 'hotel_app muss alte_daten_loeschen() aufrufen';

    -- What it must not do
    ASSERT NOT has_table_privilege('hotel_app', 'buchungsanfragen', 'UPDATE, DELETE, TRUNCATE'), 'hotel_app darf Buchungsanfragen nicht aendern';
    ASSERT NOT has_table_privilege('hotel_app', 'rueckrufe', 'UPDATE, DELETE, TRUNCATE'), 'hotel_app darf Rueckrufe nicht aendern';
    ASSERT NOT has_table_privilege('hotel_app', 'anrufe', 'UPDATE, DELETE, TRUNCATE'), 'hotel_app darf Anrufe nicht aendern';
    ASSERT NOT has_table_privilege('hotel_app', 'belegungen', 'INSERT, UPDATE, DELETE'), 'hotel_app darf keine Belegungen schreiben';
    ASSERT NOT has_table_privilege('hotel_app', 'zimmerkategorien', 'UPDATE'), 'hotel_app darf keine Preise aendern';
    ASSERT NOT has_table_privilege('hotel_app', 'anruf_ergebnisse', 'SELECT'), 'Die Auswertung ist nicht fuer hotel_app';

    -- Functions are callable by everyone by default; here only by hotel_app.
    ASSERT NOT has_function_privilege('ci_fremd', 'verfuegbarkeit(date, date, int, int, int, boolean, boolean)', 'EXECUTE'),
        'verfuegbarkeit() ist noch fuer PUBLIC freigegeben';
    ASSERT NOT has_function_privilege('ci_fremd', 'alte_daten_loeschen()', 'EXECUTE'),
        'alte_daten_loeschen() ist noch fuer PUBLIC freigegeben';

    -- hotel_app owns nothing, hotel_owner owns everything.
    ASSERT NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tableowner <> 'hotel_owner'),
        'Jede Tabelle muss hotel_owner gehoeren';
    ASSERT (SELECT pg_get_userbyid(datdba) FROM pg_database WHERE datname = 'hotel') = 'hotel_owner',
        'Die Datenbank hotel muss hotel_owner gehoeren';
END
$$;

-- The same as a real attempt: DELETE as hotel_app is refused.
SET LOCAL ROLE hotel_app;

DO $$
BEGIN
    BEGIN
        DELETE FROM rueckrufe;
        RAISE EXCEPTION 'hotel_app konnte loeschen';
    EXCEPTION WHEN insufficient_privilege THEN
        NULL;
    END;
END
$$;

ROLLBACK;
