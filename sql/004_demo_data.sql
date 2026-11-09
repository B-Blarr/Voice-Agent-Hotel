-- Demo occupancy for testing the availability check (optional, after 003).
-- All dates are invented. From 13 to 15 November 2027 every double room is
-- taken, so Nina has to offer something else. Requests for past dates are
-- refused, so the dates move one year ahead once they have passed. On a
-- running server that is one statement as the superuser:
--
--   UPDATE belegungen SET anreise = (anreise + interval '1 year')::date,
--                         abreise = (abreise + interval '1 year')::date;
--
--   sudo docker compose exec postgres psql -U n8n -d hotel
--
-- Rows have no owner, only tables do, so no SET ROLE is needed here.

-- Every double room, two nights: INSERT fed by a SELECT
INSERT INTO belegungen (zimmer, anreise, abreise)
SELECT nummer, DATE '2027-11-13', DATE '2027-11-15'
FROM zimmer
WHERE kategorie = 'doppelzimmer';

-- A few single stays around it
INSERT INTO belegungen (zimmer, anreise, abreise) VALUES
    ('101', '2027-11-10', '2027-11-14'),
    ('307', '2027-11-12', '2027-11-16'),
    ('102', '2027-11-15', '2027-11-17');
