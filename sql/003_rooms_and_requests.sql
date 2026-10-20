-- Stage 2: rooms, occupancy and booking requests (run once, after 002).
-- Demo occupancy for testing is in 004_demo_data.sql.
--
-- One data source for Nina and, later, the hotel website.
-- Connect as the superuser from compose.yaml:
--   sudo docker compose exec postgres psql -U n8n -d hotel

-- Needed for the overlap rule in "belegungen" (ships with PostgreSQL).
CREATE EXTENSION IF NOT EXISTS btree_gist;

-- Everything below is created by the owner role, so hotel_owner owns it.
SET ROLE hotel_owner;

-- 1. What the hotel sells and what it costs
CREATE TABLE zimmerkategorien (
    code                text PRIMARY KEY,
    name                text NOT NULL,
    preis_pro_nacht     numeric(7,2) NOT NULL CHECK (preis_pro_nacht > 0),
    preis_alleinnutzung numeric(7,2) CHECK (preis_alleinnutzung > 0),
    aufpreis_waldblick  numeric(7,2) NOT NULL DEFAULT 0 CHECK (aufpreis_waldblick >= 0),
    betten              smallint NOT NULL CHECK (betten BETWEEN 1 AND 4),
    zustellbett         boolean NOT NULL DEFAULT false
);

INSERT INTO zimmerkategorien
    (code, name, preis_pro_nacht, preis_alleinnutzung, aufpreis_waldblick, betten, zustellbett)
VALUES
    ('einzelzimmer', 'Einzelzimmer',  89.00, NULL,  10.00, 1, false),
    ('doppelzimmer', 'Doppelzimmer', 119.00, 99.00, 10.00, 2, true),
    ('suite',        'Suite',        179.00, NULL,   0.00, 2, true);

-- 2. The 25 rooms. The first digit of the number is the floor plus one
--    (1xx ground floor, 2xx first floor, 3xx second floor).
CREATE TABLE zimmer (
    nummer          text PRIMARY KEY CHECK (nummer ~ '^[1-3][0-9]{2}$'),
    kategorie       text NOT NULL REFERENCES zimmerkategorien (code),
    etage           smallint NOT NULL,
    betten_trennbar boolean NOT NULL DEFAULT false,  -- two beds, can be pushed together
    badewanne       boolean NOT NULL DEFAULT false,
    waldblick       boolean NOT NULL DEFAULT false,
    barrierefrei    boolean NOT NULL DEFAULT false,
    CONSTRAINT etage_passt_zur_nummer CHECK (etage = left(nummer, 1)::smallint - 1)
);

INSERT INTO zimmer (nummer, kategorie, etage, betten_trennbar, badewanne, waldblick, barrierefrei) VALUES
    ('101', 'einzelzimmer', 0, false, false, false, true),
    ('102', 'einzelzimmer', 0, false, false, true,  false),
    ('103', 'doppelzimmer', 0, false, false, false, true),
    ('104', 'einzelzimmer', 0, false, false, true,  false),
    ('105', 'doppelzimmer', 0, false, false, false, true),
    ('106', 'einzelzimmer', 0, false, false, true,  false),
    ('107', 'doppelzimmer', 0, true,  false, false, false),
    ('108', 'doppelzimmer', 0, true,  false, true,  false),
    ('201', 'einzelzimmer', 1, false, false, false, false),
    ('202', 'einzelzimmer', 1, false, false, true,  false),
    ('203', 'doppelzimmer', 1, true,  false, false, false),
    ('204', 'doppelzimmer', 1, false, true,  true,  false),
    ('205', 'doppelzimmer', 1, false, true,  false, false),
    ('206', 'doppelzimmer', 1, false, true,  true,  false),
    ('207', 'doppelzimmer', 1, false, true,  false, false),
    ('208', 'doppelzimmer', 1, true,  false, true,  false),
    ('209', 'doppelzimmer', 1, false, false, false, false),
    ('301', 'doppelzimmer', 2, false, true,  false, false),
    ('302', 'doppelzimmer', 2, true,  true,  true,  false),
    ('303', 'doppelzimmer', 2, false, true,  false, false),
    ('304', 'doppelzimmer', 2, false, true,  true,  false),
    ('305', 'doppelzimmer', 2, true,  true,  false, false),
    ('306', 'doppelzimmer', 2, false, true,  true,  false),
    ('307', 'suite',        2, false, true,  true,  false),
    ('308', 'suite',        2, false, true,  true,  false);

-- 3. When a room is taken. The departure day is not a night:
--    daterange(anreise, abreise) includes anreise and excludes abreise.
--    The EXCLUDE rule makes PostgreSQL itself refuse two overlapping stays
--    in the same room, whoever tries to write them.
CREATE TABLE belegungen (
    id      bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    zimmer  text NOT NULL REFERENCES zimmer (nummer),
    anreise date NOT NULL,
    abreise date NOT NULL,
    CONSTRAINT abreise_nach_anreise CHECK (abreise > anreise),
    CONSTRAINT keine_doppelbelegung
        EXCLUDE USING gist (zimmer WITH =, daterange(anreise, abreise) WITH &&)
);

-- 4. What Nina or the website records. A request blocks no room;
--    only the team turns it into a stay in "belegungen".
CREATE TABLE buchungsanfragen (
    id              bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    erstellt_am     timestamptz NOT NULL DEFAULT now(),
    kategorie       text NOT NULL REFERENCES zimmerkategorien (code),
    anreise         date NOT NULL,
    abreise         date NOT NULL,
    erwachsene      smallint NOT NULL CHECK (erwachsene >= 1),
    kinder          smallint NOT NULL DEFAULT 0 CHECK (kinder >= 0),
    betten_getrennt boolean NOT NULL DEFAULT false,   -- need, not a wish
    barrierefrei    boolean NOT NULL DEFAULT false,   -- need, not a wish
    wuensche        text,                             -- e.g. forest view, quiet room
    name            text NOT NULL,
    telefon         text,
    email           text,
    quelle          text NOT NULL CHECK (quelle IN ('telefon', 'website')),
    anruf_id        text,
    status          text NOT NULL DEFAULT 'offen'
                    CHECK (status IN ('offen', 'bestaetigt', 'abgelehnt')),
    CONSTRAINT abreise_nach_anreise CHECK (abreise > anreise),
    CONSTRAINT kontakt_vorhanden CHECK (telefon IS NOT NULL OR email IS NOT NULL)
);

RESET ROLE;

-- Rights for the webhook role: read the hotel, record requests.
GRANT SELECT ON zimmerkategorien, zimmer, belegungen TO hotel_app;
GRANT SELECT, INSERT ON buchungsanfragen TO hotel_app;
