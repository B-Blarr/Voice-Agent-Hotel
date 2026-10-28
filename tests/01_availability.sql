-- Availability check: verfuegbarkeit() against the demo stays from 004.
-- In the demo data every double room is taken from 13 to 15 November,
-- room 101 from 10 to 14, room 307 from 12 to 16 and room 102 from 15 to 17.

BEGIN;

DO $$
DECLARE
    r record;
BEGIN
    -- Two adults on the booked out weekend: double rooms are full, one suite is left.
    SELECT * INTO r FROM verfuegbarkeit('2026-11-13', '2026-11-15', 2) WHERE kategorie = 'doppelzimmer';
    ASSERT r.freie_zimmer = 0, 'Doppelzimmer am 13.11. sollten ausgebucht sein';
    SELECT * INTO r FROM verfuegbarkeit('2026-11-13', '2026-11-15', 2) WHERE kategorie = 'suite';
    ASSERT r.freie_zimmer = 1 AND r.naechte = 2 AND r.gesamtpreis = 358.00, 'Suite am 13.11.: 1 frei, 358 Euro erwartet';
    ASSERT NOT EXISTS (SELECT 1 FROM verfuegbarkeit('2026-11-13', '2026-11-15', 2) WHERE kategorie = 'einzelzimmer'),
        'Einzelzimmer darf fuer zwei Erwachsene nicht vorkommen';

    -- One adult: single rooms count, and a double room costs the single use price.
    SELECT * INTO r FROM verfuegbarkeit('2026-11-13', '2026-11-15', 1) WHERE kategorie = 'einzelzimmer';
    ASSERT r.freie_zimmer = 5 AND r.gesamtpreis = 178.00, 'Einzelzimmer am 13.11.: 5 frei, 178 Euro erwartet';
    SELECT * INTO r FROM verfuegbarkeit('2026-11-13', '2026-11-15', 1) WHERE kategorie = 'doppelzimmer';
    ASSERT r.preis_pro_nacht = 99.00 AND r.gesamtpreis = 198.00, 'Alleinnutzung Doppelzimmer: 99 Euro pro Nacht erwartet';

    -- The departure day is not a night: 101 leaves on the 14th and 102 arrives on the 15th.
    SELECT * INTO r FROM verfuegbarkeit('2026-11-14', '2026-11-15', 1) WHERE kategorie = 'einzelzimmer';
    ASSERT r.freie_zimmer = 6, 'Abreisetag ist keine Nacht: alle 6 Einzelzimmer frei erwartet';

    -- A child needs the extra bed, which only double rooms and suites have.
    SELECT * INTO r FROM verfuegbarkeit('2026-11-20', '2026-11-22', 2, 1) WHERE kategorie = 'doppelzimmer';
    ASSERT r.freie_zimmer = 17, 'Doppelzimmer am 20.11. mit Kind: 17 frei erwartet';
    SELECT * INTO r FROM verfuegbarkeit('2026-11-20', '2026-11-22', 2, 1) WHERE kategorie = 'suite';
    ASSERT r.freie_zimmer = 2, 'Suite am 20.11. mit Kind: 2 frei erwartet';
    ASSERT NOT EXISTS (SELECT 1 FROM verfuegbarkeit('2026-11-20', '2026-11-22', 2, 1) WHERE kategorie = 'einzelzimmer'),
        'Einzelzimmer darf mit Kind nicht vorkommen';

    -- Needs filter rooms: barrier free only 103 and 105, separate beds only five double rooms.
    SELECT * INTO r FROM verfuegbarkeit('2026-11-20', '2026-11-22', 2, p_barrierefrei => true) WHERE kategorie = 'doppelzimmer';
    ASSERT r.freie_zimmer = 2, 'Barrierefreie Doppelzimmer: 2 erwartet';
    ASSERT NOT EXISTS (SELECT 1 FROM verfuegbarkeit('2026-11-20', '2026-11-22', 2, p_barrierefrei => true) WHERE kategorie = 'suite'),
        'Keine Suite ist barrierefrei';
    SELECT * INTO r FROM verfuegbarkeit('2026-11-20', '2026-11-22', 2, p_betten_getrennt => true) WHERE kategorie = 'doppelzimmer';
    ASSERT r.freie_zimmer = 6, 'Doppelzimmer mit trennbaren Betten: 6 erwartet';

    -- Too many guests or babies: no category fits.
    ASSERT NOT EXISTS (SELECT 1 FROM verfuegbarkeit('2026-11-20', '2026-11-22', 3)), 'Drei Erwachsene passen in kein Zimmer';
    ASSERT NOT EXISTS (SELECT 1 FROM verfuegbarkeit('2026-11-20', '2026-11-22', 2, 0, 2)), 'Zwei Babybetten passen in kein Zimmer';
END
$$;

ROLLBACK;
