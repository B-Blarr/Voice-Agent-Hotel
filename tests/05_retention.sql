-- Retention: alte_daten_loeschen() removes requests after 30 days and calls
-- after 90 days, and nothing younger. It runs as hotel_app, like the nightly workflow.

BEGIN;

INSERT INTO buchungsanfragen (erstellt_am, kategorie, anreise, abreise, erwachsene, name, telefon, quelle) VALUES
    (now() - interval '31 days', 'doppelzimmer', '2026-11-20', '2026-11-22', 2, 'Alt',  '0000', 'telefon'),
    (now() - interval '29 days', 'doppelzimmer', '2026-11-20', '2026-11-22', 2, 'Neu',  '0000', 'telefon');

INSERT INTO rueckrufe (erstellt_am, name, telefon, anliegen) VALUES
    (now() - interval '31 days', 'Alt', '0000', 'alt'),
    (now() - interval '29 days', 'Neu', '0000', 'neu');

INSERT INTO anrufe (anruf_id, beginn, dauer_sek, kanal) VALUES
    ('conv_ci_alt', now() - interval '91 days', 60, 'sip_trunk'),
    ('conv_ci_neu', now() - interval '89 days', 60, 'sip_trunk');

SET LOCAL ROLE hotel_app;

DO $$
DECLARE
    r record;
BEGIN
    FOR r IN SELECT * FROM alte_daten_loeschen() LOOP
        ASSERT r.geloescht = 1, format('%s: genau 1 geloeschte Zeile erwartet, nicht %s', r.tabelle, r.geloescht);
    END LOOP;
    ASSERT (SELECT count(*) FROM alte_daten_loeschen()) = 3, 'Drei Ergebniszeilen erwartet';
END
$$;

RESET ROLE;

DO $$
BEGIN
    ASSERT (SELECT array_agg(name) FROM buchungsanfragen) = ARRAY['Neu'], 'Nur die neue Buchungsanfrage darf bleiben';
    ASSERT (SELECT array_agg(name) FROM rueckrufe) = ARRAY['Neu'], 'Nur der neue Rueckruf darf bleiben';
    ASSERT (SELECT array_agg(anruf_id) FROM anrufe) = ARRAY['conv_ci_neu'], 'Nur der neue Anruf darf bleiben';
END
$$;

ROLLBACK;
