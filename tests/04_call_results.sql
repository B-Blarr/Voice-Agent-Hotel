-- The view anruf_ergebnisse derives the outcome of a call from the other tables.

BEGIN;

INSERT INTO anrufe (anruf_id, beginn, dauer_sek, kanal) VALUES
    ('conv_ci_buchung',  now(), 120, 'sip_trunk'),
    ('conv_ci_rueckruf', now(),  90, 'sip_trunk'),
    ('conv_ci_beides',   now(), 200, 'sip_trunk'),
    ('conv_ci_auskunft', now(),  40, 'react_sdk');

INSERT INTO buchungsanfragen (kategorie, anreise, abreise, erwachsene, name, telefon, quelle, anruf_id) VALUES
    ('doppelzimmer', '2026-11-20', '2026-11-22', 2, 'Test Gast', '0000', 'telefon', 'conv_ci_buchung'),
    ('suite',        '2026-11-20', '2026-11-22', 2, 'Test Gast', '0000', 'telefon', 'conv_ci_beides');

INSERT INTO rueckrufe (name, telefon, anliegen, anruf_id) VALUES
    ('Test Gast', '0000', 'Frage zur Anreise', 'conv_ci_rueckruf'),
    ('Test Gast', '0000', 'Frage zum Parken',  'conv_ci_beides');

DO $$
BEGIN
    ASSERT (SELECT ergebnis FROM anruf_ergebnisse WHERE anruf_id = 'conv_ci_buchung')  = 'buchungsanfrage', 'Buchung erwartet';
    ASSERT (SELECT ergebnis FROM anruf_ergebnisse WHERE anruf_id = 'conv_ci_rueckruf') = 'rueckruf', 'Rueckruf erwartet';
    ASSERT (SELECT ergebnis FROM anruf_ergebnisse WHERE anruf_id = 'conv_ci_auskunft') = 'auskunft', 'Auskunft erwartet';
    -- Both in one call: the booking request counts.
    ASSERT (SELECT ergebnis FROM anruf_ergebnisse WHERE anruf_id = 'conv_ci_beides')   = 'buchungsanfrage', 'Buchung vor Rueckruf erwartet';

    -- One row per call, even with two follow ups.
    ASSERT (SELECT count(*) FROM anruf_ergebnisse WHERE anruf_id LIKE 'conv_ci_%') = 4, 'Vier Zeilen erwartet';

    -- Only ElevenLabs conversation ids are accepted.
    BEGIN
        INSERT INTO anrufe (anruf_id, beginn, dauer_sek, kanal) VALUES ('irgendwas', now(), 10, 'sip_trunk');
        RAISE EXCEPTION 'anruf_id ohne conv_ wurde angenommen';
    EXCEPTION WHEN check_violation THEN
        NULL;
    END;
END
$$;

ROLLBACK;
