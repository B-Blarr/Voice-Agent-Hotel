-- Demo occupancy for testing the availability check (optional, after 003).
-- All dates are invented. On the weekend of 13 to 15 November every double
-- room is taken, so Nina has to offer something else.
--
--   sudo docker compose exec postgres psql -U n8n -d hotel
--
-- Rows have no owner, only tables do, so no SET ROLE is needed here.

-- Every double room, one weekend: INSERT fed by a SELECT
INSERT INTO belegungen (zimmer, anreise, abreise)
SELECT nummer, DATE '2026-11-13', DATE '2026-11-15'
FROM zimmer
WHERE kategorie = 'doppelzimmer';

-- A few single stays around it
INSERT INTO belegungen (zimmer, anreise, abreise) VALUES
    ('101', '2026-11-10', '2026-11-14'),
    ('307', '2026-11-12', '2026-11-16'),
    ('102', '2026-11-15', '2026-11-17');
