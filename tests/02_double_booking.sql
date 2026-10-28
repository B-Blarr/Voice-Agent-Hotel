-- The database itself refuses overlapping stays in the same room.
-- Demo data: room 307 is taken from 12 to 16 November.

BEGIN;

DO $$
BEGIN
    -- Overlap by one night: must fail with exclusion_violation.
    BEGIN
        INSERT INTO belegungen (zimmer, anreise, abreise) VALUES ('307', '2026-11-15', '2026-11-18');
        RAISE EXCEPTION 'Doppelbelegung von 307 wurde angenommen';
    EXCEPTION WHEN exclusion_violation THEN
        NULL;
    END;

    -- Arriving on the departure day of the last guest is fine.
    INSERT INTO belegungen (zimmer, anreise, abreise) VALUES ('307', '2026-11-16', '2026-11-18');

    -- Departure before arrival: must fail with check_violation.
    BEGIN
        INSERT INTO belegungen (zimmer, anreise, abreise) VALUES ('308', '2026-12-05', '2026-12-05');
        RAISE EXCEPTION 'Aufenthalt ohne Nacht wurde angenommen';
    EXCEPTION WHEN check_violation THEN
        NULL;
    END;
END
$$;

ROLLBACK;
