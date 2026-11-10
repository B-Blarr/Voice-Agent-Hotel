-- Stage 5: Django's own database for the team area (run once, after 010).
-- Django keeps its users and sessions in a small database "team" that it owns
-- and migrates itself. The hotel database stays with the SQL migrations.
-- From here on only the roles that need it may connect to a database.
--
-- Connect as the superuser from compose.yaml:
--   sudo docker compose exec postgres psql -U n8n -d n8n
--
-- The password for team_django is set interactively with \password,
-- so it never ends up in this file or in the psql history.

CREATE ROLE team_django LOGIN;
\password team_django

CREATE DATABASE team OWNER team_django;

-- Only Django connects to its own database.
REVOKE CONNECT ON DATABASE team FROM PUBLIC;

-- The hotel database was open to every role so far (CONNECT for PUBLIC is the
-- default). Now only the workflows and the team area connect there.
REVOKE CONNECT ON DATABASE hotel FROM PUBLIC;
GRANT CONNECT ON DATABASE hotel TO hotel_app, hotel_team;

-- Check: team has team_django as owner, hotel lists hotel_app=c and hotel_team=c
\l team
\l hotel
