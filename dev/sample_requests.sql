-- Made-up requests and calls for the local database, so the team area has something to show.
-- Only for dev/compose.yaml, never on the server. Names and numbers are invented.
-- Load:  Get-Content dev/sample_requests.sql | docker compose -f dev/compose.yaml exec -T postgres psql -U n8n -d hotel

BEGIN;

INSERT INTO anrufe (anruf_id, beginn, dauer_sek, kanal, beendet_durch, erfolgreich, titel, stimmung) VALUES
    ('conv_demo_1', now() - interval '2 days',   184, 'sip_trunk', 'agent', 'success', 'Doppelzimmer fuer ein Wochenende angefragt', 'positiv'),
    ('conv_demo_2', now() - interval '1 day',     96, 'sip_trunk', 'user',  'success', 'Rueckruf wegen Hund und Parkplatz',          'neutral'),
    ('conv_demo_3', now() - interval '5 hours',   41, 'sip_trunk', 'user',  'success', 'Frage nach der Anreise am Abend',            'positiv'),
    ('conv_demo_4', now() - interval '2 hours',  132, 'sip_trunk', 'agent', 'failure', 'Suite fuer Familie, Datum unklar',           'neutral');

INSERT INTO buchungsanfragen
    (kategorie, anreise, abreise, erwachsene, kinder, babys, betten_getrennt, barrierefrei, wuensche, name, telefon, email, quelle, anruf_id) VALUES
    ('doppelzimmer', '2027-11-19', '2027-11-21', 2, 0, 0, false, false, 'Waldblick, ruhiges Zimmer', 'Anna Beispiel', '+49 000 0000001', NULL, 'telefon', 'conv_demo_1'),
    ('suite',        '2027-12-03', '2027-12-05', 2, 1, 1, false, false, NULL,                        'Familie Muster', '+49 000 0000002', NULL, 'telefon', 'conv_demo_4');

INSERT INTO rueckrufe (name, telefon, anliegen, erreichbar, anruf_id) VALUES
    ('Peter Probe', '+49 000 0000003', 'Ob der Hund mit ins Zimmer darf und wo man parkt', 'heute ab 17 Uhr', 'conv_demo_2'),
    ('Lena Test',   '+49 000 0000004', 'Frage zu einer Firmenrechnung',                    'vormittags',      NULL);

COMMIT;
