"""Settings for pytest.

The tests use the databases as they are, because the hotel schema comes from
the SQL migrations and Django cannot build it. Every test runs in a transaction
that is rolled back at the end, so nothing stays behind.

To insert test rows, the hotel connection logs in as the database superuser and
switches to hotel_team with SET LOCAL ROLE before the API is called. From then on
PostgreSQL checks exactly the rights of hotel_team, like in tests/*.sql.
"""

from .settings import *  # noqa: F401,F403
from .settings import DATABASES, env_required, os

DATABASES["hotel"]["USER"] = os.getenv("TEST_DB_SUPERUSER", "n8n")
DATABASES["hotel"]["PASSWORD"] = env_required("TEST_DB_SUPERUSER_PASSWORD")
