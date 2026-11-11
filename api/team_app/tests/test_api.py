import pytest
from django.db import connections
from rest_framework.test import APIClient

pytestmark = pytest.mark.django_db(databases=["default", "hotel"])

ENDPOINTS = ["/api/buchungsanfragen/", "/api/rueckrufe/", "/api/anrufe/"]


@pytest.mark.parametrize("url", ENDPOINTS)
def test_nothing_without_login(hotel_rows, url):
    assert APIClient().get(url).status_code == 403


def test_api_runs_as_hotel_team(hotel_rows):
    with connections["hotel"].cursor() as cursor:
        cursor.execute("SELECT current_user")
        assert cursor.fetchone()[0] == "hotel_team"


def test_list_and_filter_by_status(hotel_rows, team_client):
    # The local database may hold demo rows as well, so only our own row is checked by id.
    response = team_client.get("/api/buchungsanfragen/?status=offen")
    assert response.status_code == 200
    assert hotel_rows["buchung_id"] in [row["id"] for row in response.json()]
    assert {row["status"] for row in response.json()} == {"offen"}

    confirmed = team_client.get("/api/buchungsanfragen/?status=bestaetigt").json()
    assert hotel_rows["buchung_id"] not in [row["id"] for row in confirmed]


def test_set_status(hotel_rows, team_client):
    url = f"/api/buchungsanfragen/{hotel_rows['buchung_id']}/"
    response = team_client.patch(url, {"status": "bestaetigt"}, format="json")
    assert response.status_code == 200
    assert team_client.get(url).json()["status"] == "bestaetigt"

    url = f"/api/rueckrufe/{hotel_rows['rueckruf_id']}/"
    response = team_client.patch(url, {"status": "nicht_erreicht"}, format="json")
    assert response.status_code == 200
    assert team_client.get(url).json()["status"] == "nicht_erreicht"


def test_unknown_status_is_refused(hotel_rows, team_client):
    url = f"/api/buchungsanfragen/{hotel_rows['buchung_id']}/"
    response = team_client.patch(url, {"status": "storniert"}, format="json")
    assert response.status_code == 400
    assert "status" in response.json()


@pytest.mark.parametrize("body", [{}, {"name": "Jemand anders"}])
def test_patch_needs_a_status(hotel_rows, team_client, body):
    url = f"/api/rueckrufe/{hotel_rows['rueckruf_id']}/"
    response = team_client.patch(url, body, format="json")
    assert response.status_code == 400
    assert "status" in response.json()


def test_other_fields_stay_unchanged(hotel_rows, team_client):
    url = f"/api/buchungsanfragen/{hotel_rows['buchung_id']}/"
    response = team_client.patch(url, {"status": "abgelehnt", "name": "Jemand anders", "telefon": "1234"}, format="json")
    assert response.status_code == 200
    data = team_client.get(url).json()
    assert (data["name"], data["telefon"], data["status"]) == ("Test Gast", "0000", "abgelehnt")


def test_no_create_replace_or_delete(hotel_rows, team_client):
    url = f"/api/buchungsanfragen/{hotel_rows['buchung_id']}/"
    assert team_client.post("/api/buchungsanfragen/", {}, format="json").status_code == 405
    assert team_client.put(url, {"status": "offen"}, format="json").status_code == 405
    assert team_client.delete(url).status_code == 405


def test_calls_are_read_only_and_show_their_outcome(hotel_rows, team_client):
    calls = {row["anruf_id"]: row["ergebnis"] for row in team_client.get("/api/anrufe/").json()}
    assert calls["conv_pytest_1"] == "buchungsanfrage"
    assert calls["conv_pytest_2"] == "auskunft"
    assert team_client.patch("/api/anrufe/conv_pytest_1/", {"titel": "x"}, format="json").status_code == 405


def test_changes_need_a_csrf_token(hotel_rows, team_user):
    browser = APIClient(enforce_csrf_checks=True)
    browser.force_login(team_user)
    url = f"/api/buchungsanfragen/{hotel_rows['buchung_id']}/"
    assert browser.get(url).status_code == 200
    assert browser.patch(url, {"status": "bestaetigt"}, format="json").status_code == 403
