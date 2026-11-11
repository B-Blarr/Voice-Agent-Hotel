import pytest
from django.contrib.auth.models import User
from django.core.cache import cache
from django.db import connections
from rest_framework.test import APIClient


@pytest.fixture(scope="session")
def django_db_setup():
    """Use the existing databases instead of creating test copies.

    team is migrated by Django, hotel is built from sql/. Tests only ever run
    inside transactions that are rolled back.
    """


@pytest.fixture(autouse=True)
def fresh_login_limit():
    """The login limit counts in the cache, so every test starts with a clean count."""
    cache.clear()


@pytest.fixture
def hotel_rows():
    """Insert made-up rows as superuser, then continue as hotel_team."""
    with connections["hotel"].cursor() as cursor:
        cursor.execute(
            """
            INSERT INTO anrufe (anruf_id, beginn, dauer_sek, kanal, erfolgreich) VALUES
                ('conv_pytest_1', now(), 120, 'sip_trunk', 'success'),
                ('conv_pytest_2', now(),  40, 'sip_trunk', 'failure')
            """
        )
        cursor.execute(
            """
            INSERT INTO buchungsanfragen (kategorie, anreise, abreise, erwachsene, name, telefon, quelle, anruf_id)
            VALUES ('doppelzimmer', '2027-11-20', '2027-11-22', 2, 'Test Gast', '0000', 'telefon', 'conv_pytest_1')
            RETURNING id
            """
        )
        buchung_id = cursor.fetchone()[0]
        cursor.execute(
            "INSERT INTO rueckrufe (name, telefon, anliegen) VALUES ('Test Gast', '0000', 'Frage zum Parken') RETURNING id"
        )
        rueckruf_id = cursor.fetchone()[0]
        # Until the end of the test transaction, PostgreSQL checks the rights of hotel_team.
        cursor.execute("SET LOCAL ROLE hotel_team")
    return {"buchung_id": buchung_id, "rueckruf_id": rueckruf_id}


@pytest.fixture
def team_user():
    return User.objects.create_user(username="pytest_team", password="pytest")


@pytest.fixture
def team_client(team_user):
    """Logged in like the team. CSRF is tested on its own in test_api.py."""
    api_client = APIClient()
    api_client.force_login(team_user)
    return api_client
