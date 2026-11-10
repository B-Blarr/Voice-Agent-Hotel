-- Each role connects only to the database it needs.

BEGIN;

DO $$
BEGIN
    -- Django owns its own database and only that one.
    ASSERT (SELECT pg_get_userbyid(datdba) FROM pg_database WHERE datname = 'team') = 'team_django',
        'Die Datenbank team muss team_django gehoeren';
    ASSERT has_database_privilege('team_django', 'team', 'CONNECT'), 'team_django muss in team';
    ASSERT NOT has_database_privilege('team_django', 'hotel', 'CONNECT'), 'team_django darf nicht in hotel';
    ASSERT NOT has_database_privilege('team_django', 'n8n', 'CONNECT'), 'team_django darf nicht in n8n';

    -- The hotel roles stay in the hotel database.
    ASSERT has_database_privilege('hotel_app', 'hotel', 'CONNECT'), 'hotel_app muss in hotel';
    ASSERT has_database_privilege('hotel_team', 'hotel', 'CONNECT'), 'hotel_team muss in hotel';
    ASSERT NOT has_database_privilege('hotel_app', 'team', 'CONNECT'), 'hotel_app darf nicht in team';
    ASSERT NOT has_database_privilege('hotel_team', 'team', 'CONNECT'), 'hotel_team darf nicht in team';

    -- No database is open to every role any more, except the template.
    ASSERT NOT EXISTS (
        SELECT 1 FROM pg_database
        WHERE datname <> 'template1'
          AND NOT datistemplate
          AND has_database_privilege('public', datname, 'CONNECT')
    ), 'Eine Datenbank ist noch fuer PUBLIC offen';
END
$$;

ROLLBACK;
