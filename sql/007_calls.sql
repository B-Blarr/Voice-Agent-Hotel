-- Stage 4: one row per call, sent by the ElevenLabs post-call webhook (run once, after 006).
-- Only what the evaluation needs is stored. No caller number, no transcript and no summary,
-- because all three contain personal data.
-- Connect as the superuser from compose.yaml:
--   sudo docker compose exec postgres psql -U n8n -d hotel

SET ROLE hotel_owner;

CREATE TABLE anrufe (
    anruf_id        text PRIMARY KEY CHECK (anruf_id ~ '^conv_'),
    beginn          timestamptz NOT NULL,
    dauer_sek       integer NOT NULL CHECK (dauer_sek >= 0),
    kosten_credits  integer CHECK (kosten_credits >= 0),
    kosten_usd      numeric(8,4) CHECK (kosten_usd >= 0),
    kanal           text NOT NULL,
    beendet_durch   text,
    erfolgreich     text CHECK (erfolgreich IN ('success', 'failure', 'unknown')),
    titel           text,
    stimmung        text,
    eingegangen_am  timestamptz NOT NULL DEFAULT now()
);

RESET ROLE;

-- The workflow may add and read calls, nothing else.
GRANT SELECT, INSERT ON anrufe TO hotel_app;
