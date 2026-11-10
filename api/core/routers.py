"""Send the hotel models to the hotel database and everything else to default."""

HOTEL_APP = "team_app"


class HotelRouter:
    def db_for_read(self, model, **hints):
        if model._meta.app_label == HOTEL_APP:
            return "hotel"
        return None

    def db_for_write(self, model, **hints):
        if model._meta.app_label == HOTEL_APP:
            return "hotel"
        return None

    def allow_relation(self, obj1, obj2, **hints):
        # Rows from two different databases can never point at each other.
        return obj1._state.db == obj2._state.db

    def allow_migrate(self, db, app_label, **hints):
        # The hotel schema lives in sql/, Django never migrates the hotel database.
        if db == "hotel":
            return False
        # And the hotel models never end up in Django's own database.
        if app_label == HOTEL_APP:
            return False
        return None
