-- Hotel database for the callback requests (run once).
--
-- Connect to the Postgres container as the superuser from compose.yaml:
--   sudo docker compose exec postgres psql -U n8n -d n8n
--
-- The password for hotel_app is set interactively with \password,
-- so it never ends up in this file or in the psql history.

CREATE ROLE hotel_app LOGIN;
\password hotel_app

CREATE DATABASE hotel OWNER hotel_app;

-- n8n keeps its own tables in the database "n8n". No other role needs to connect there.
REVOKE CONNECT ON DATABASE n8n FROM PUBLIC;

\c hotel hotel_app

-- Show timestamps in German local time (storage stays timezone-aware).
ALTER DATABASE hotel SET timezone TO 'Europe/Berlin';

CREATE TABLE rueckrufe (
    id           bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    erstellt_am  timestamptz NOT NULL DEFAULT now(),
    name         text NOT NULL,
    telefon      text NOT NULL,
    anliegen     text NOT NULL,
    erreichbar   text,
    anruf_id     text,
    status       text NOT NULL DEFAULT 'offen'
                 CHECK (status IN ('offen', 'erledigt', 'nicht_erreicht'))
);
