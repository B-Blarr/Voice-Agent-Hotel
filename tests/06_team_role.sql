-- hotel_team (the team area) may read requests, callbacks and calls
-- and may change only the status of a booking request or a callback.

BEGIN;

INSERT INTO anrufe (anruf_id, beginn, dauer_sek, kanal) VALUES
    ('conv_ci_team', now(), 120, 'sip_trunk');

INSERT INTO buchungsanfragen (kategorie, anreise, abreise, erwachsene, name, telefon, quelle, anruf_id) VALUES
    ('doppelzimmer', '2027-11-20', '2027-11-22', 2, 'Test Gast', '0000', 'telefon', 'conv_ci_team');

INSERT INTO rueckrufe (name, telefon, anliegen, anruf_id) VALUES
    ('Test Gast', '0000', 'Frage zur Anreise', 'conv_ci_team');

DO $$
BEGIN
    -- What the team area needs
    ASSERT has_table_privilege('hotel_team', 'buchungsanfragen', 'SELECT'), 'hotel_team muss Buchungsanfragen lesen';
    ASSERT has_table_privilege('hotel_team', 'rueckrufe', 'SELECT'), 'hotel_team muss Rueckrufe lesen';
    ASSERT has_table_privilege('hotel_team', 'anruf_ergebnisse', 'SELECT'), 'hotel_team muss die Anrufe mit Ergebnis lesen';
    ASSERT has_column_privilege('hotel_team', 'buchungsanfragen', 'status', 'UPDATE'), 'hotel_team muss den Status einer Buchungsanfrage setzen';
    ASSERT has_column_privilege('hotel_team', 'rueckrufe', 'status', 'UPDATE'), 'hotel_team muss den Status eines Rueckrufs setzen';

    -- Only the status, no other column
    ASSERT NOT has_table_privilege('hotel_team', 'buchungsanfragen', 'UPDATE'), 'hotel_team darf nicht die ganze Buchungsanfrage aendern';
    ASSERT NOT has_table_privilege('hotel_team', 'rueckrufe', 'UPDATE'), 'hotel_team darf nicht den ganzen Rueckruf aendern';
    ASSERT NOT has_column_privilege('hotel_team', 'buchungsanfragen', 'telefon', 'UPDATE'), 'hotel_team darf keine Telefonnummer aendern';

    -- Nothing added, nothing removed
    ASSERT NOT has_table_privilege('hotel_team', 'buchungsanfragen', 'INSERT, DELETE, TRUNCATE'), 'hotel_team darf keine Buchungsanfragen anlegen oder loeschen';
    ASSERT NOT has_table_privilege('hotel_team', 'rueckrufe', 'INSERT, DELETE, TRUNCATE'), 'hotel_team darf keine Rueckrufe anlegen oder loeschen';
    ASSERT NOT has_table_privilege('hotel_team', 'anrufe', 'SELECT, INSERT, UPDATE, DELETE, TRUNCATE'), 'hotel_team liest Anrufe nur ueber anruf_ergebnisse';
    ASSERT NOT has_table_privilege('hotel_team', 'belegungen', 'SELECT, INSERT, UPDATE, DELETE'), 'Belegungen sind nicht fuer hotel_team';

    -- Not the functions of the workflows and not the n8n database
    ASSERT NOT has_function_privilege('hotel_team', 'verfuegbarkeit(date, date, int, int, int, boolean, boolean)', 'EXECUTE'),
        'verfuegbarkeit() ist nicht fuer hotel_team';
    ASSERT NOT has_function_privilege('hotel_team', 'alte_daten_loeschen()', 'EXECUTE'), 'hotel_team darf nicht aufraeumen';
    ASSERT NOT has_database_privilege('hotel_team', 'n8n', 'CONNECT'), 'hotel_team darf nicht in die n8n-Datenbank';

    -- hotel_team owns nothing
    ASSERT NOT EXISTS (SELECT 1 FROM pg_class WHERE relowner = 'hotel_team'::regrole), 'hotel_team darf nichts besitzen';
END
$$;

-- The same as real attempts, as hotel_team.
SET LOCAL ROLE hotel_team;

DO $$
DECLARE
    anzahl bigint;
BEGIN
    ASSERT (SELECT ergebnis FROM anruf_ergebnisse WHERE anruf_id = 'conv_ci_team') = 'buchungsanfrage', 'Anruf mit Ergebnis lesbar';

    UPDATE buchungsanfragen SET status = 'bestaetigt' WHERE anruf_id = 'conv_ci_team';
    GET DIAGNOSTICS anzahl = ROW_COUNT;
    ASSERT anzahl = 1, 'Status der Buchungsanfrage nicht gesetzt';

    UPDATE rueckrufe SET status = 'erledigt' WHERE anruf_id = 'conv_ci_team';
    GET DIAGNOSTICS anzahl = ROW_COUNT;
    ASSERT anzahl = 1, 'Status des Rueckrufs nicht gesetzt';

    -- The CHECK constraint still applies.
    BEGIN
        UPDATE buchungsanfragen SET status = 'storniert' WHERE anruf_id = 'conv_ci_team';
        RAISE EXCEPTION 'unbekannter Status wurde angenommen';
    EXCEPTION WHEN check_violation THEN
        NULL;
    END;

    BEGIN
        UPDATE buchungsanfragen SET name = 'Jemand anders' WHERE anruf_id = 'conv_ci_team';
        RAISE EXCEPTION 'hotel_team konnte einen Namen aendern';
    EXCEPTION WHEN insufficient_privilege THEN
        NULL;
    END;

    BEGIN
        DELETE FROM rueckrufe WHERE anruf_id = 'conv_ci_team';
        RAISE EXCEPTION 'hotel_team konnte loeschen';
    EXCEPTION WHEN insufficient_privilege THEN
        NULL;
    END;

    BEGIN
        INSERT INTO rueckrufe (name, telefon, anliegen) VALUES ('Test Gast', '0000', 'Erfunden');
        RAISE EXCEPTION 'hotel_team konnte einen Rueckruf anlegen';
    EXCEPTION WHEN insufficient_privilege THEN
        NULL;
    END;
END
$$;

ROLLBACK;
