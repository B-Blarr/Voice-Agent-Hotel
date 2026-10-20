-- Least privilege for the webhook role (run once, after 001).
--
-- In 001, hotel_app created the table and owns the database, so it could also
-- UPDATE, DELETE or DROP everything. From here on a separate role without login
-- owns database and table, and hotel_app may only do what the workflow needs:
-- INSERT a callback request and SELECT it back (RETURNING id).
--
-- Connect as the superuser from compose.yaml:
--   sudo docker compose exec postgres psql -U n8n -d n8n

CREATE ROLE hotel_owner NOLOGIN;
ALTER DATABASE hotel OWNER TO hotel_owner;

\c hotel

ALTER TABLE rueckrufe OWNER TO hotel_owner;
REVOKE ALL ON rueckrufe FROM hotel_app;
GRANT SELECT, INSERT ON rueckrufe TO hotel_app;

-- The default database "postgres" is not needed by anyone but the superuser.
REVOKE CONNECT ON DATABASE postgres FROM PUBLIC;

-- Check: hotel_app=ar/hotel_owner (a = INSERT, r = SELECT)
\dp rueckrufe
