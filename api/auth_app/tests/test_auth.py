import pytest
from rest_framework.test import APIClient

pytestmark = pytest.mark.django_db


@pytest.fixture
def browser():
    """Behaves like a browser: CSRF is checked, cookies are kept."""
    return APIClient(enforce_csrf_checks=True)


def with_csrf(browser):
    """Fetch the CSRF cookie and send it back in the header, like the React app will."""
    if "csrftoken" not in browser.cookies:
        assert browser.get("/api/auth/csrf/").status_code == 204
    browser.credentials(HTTP_X_CSRFTOKEN=browser.cookies["csrftoken"].value)
    return browser


def log_in(browser, password="pytest"):
    return with_csrf(browser).post(
        "/api/auth/login/", {"username": "pytest_team", "password": password}, format="json"
    )


def test_csrf_endpoint_sets_the_cookie(browser):
    response = browser.get("/api/auth/csrf/")
    assert response.status_code == 204
    assert "csrftoken" in response.cookies


def test_login_and_who_is_logged_in(browser, team_user):
    assert browser.get("/api/auth/me/").status_code == 403

    response = log_in(browser)
    assert response.status_code == 200
    assert response.json() == {"username": "pytest_team"}
    assert browser.get("/api/auth/me/").json() == {"username": "pytest_team"}


@pytest.mark.parametrize(
    "username, password", [("pytest_team", "falsch"), ("niemand", "pytest")]
)
def test_wrong_login_gives_the_same_answer(browser, team_user, username, password):
    response = with_csrf(browser).post(
        "/api/auth/login/", {"username": username, "password": password}, format="json"
    )
    assert response.status_code == 400
    assert response.json() == {"detail": "Benutzername oder Passwort ist falsch."}
    assert browser.get("/api/auth/me/").status_code == 403


def test_login_needs_a_csrf_token(browser, team_user):
    response = browser.post(
        "/api/auth/login/", {"username": "pytest_team", "password": "pytest"}, format="json"
    )
    assert response.status_code == 403
    assert browser.get("/api/auth/me/").status_code == 403


def test_logout(browser, team_user):
    log_in(browser)
    # After the login Django hands out a new CSRF token, so it is read again.
    response = with_csrf(browser).post("/api/auth/logout/")
    assert response.status_code == 204
    assert browser.get("/api/auth/me/").status_code == 403


def test_logout_needs_a_csrf_token(browser, team_user):
    log_in(browser)
    browser.credentials()
    assert browser.post("/api/auth/logout/").status_code == 403
    assert browser.get("/api/auth/me/").status_code == 200


def test_too_many_login_attempts_are_slowed_down(browser, team_user):
    for _ in range(10):
        assert log_in(browser, password="falsch").status_code == 400
    assert log_in(browser, password="falsch").status_code == 429
    # Even the right password has to wait now.
    assert log_in(browser).status_code == 429
