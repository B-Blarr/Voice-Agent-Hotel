-- Stage 5: a role for the team area (run once, after 009).
-- The Django API behind the team area connects as hotel_team. It may read the
-- booking requests, the callbacks and the calls, and it may change exactly one
-- column: the status of a booking request or a callback. Adding, deleting or
-- changing anything else is refused by PostgreSQL itself, so a bug in the API
-- or a leaked password can at worst set a wrong status.
--
-- Connect as the superuser from compose.yaml:
--   sudo docker compose exec postgres psql -U n8n -d hotel
--
-- The password for hotel_team is set interactively with \password,
-- so it never ends up in this file or in the psql history.

CREATE ROLE hotel_team LOGIN;
\password hotel_team

-- Read what the team works with. The view anruf_ergebnisse contains every
-- column of anrufe plus the outcome of the call, so the table itself is not needed.
GRANT SELECT ON buchungsanfragen, rueckrufe, anruf_ergebnisse TO hotel_team;

-- Change only the status. The CHECK constraints from 001 and 003 still decide
-- which values are allowed.
GRANT UPDATE (status) ON buchungsanfragen, rueckrufe TO hotel_team;

-- Check: hotel_team=r/hotel_owner on the table, status: hotel_team=w/hotel_owner on the column
\dp buchungsanfragen
\dp rueckrufe
