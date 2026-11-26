"""The hotel tables the team works with.

The tables come from the SQL migrations in sql/ and keep their German column
names, because n8n and the SQL tests use them as well. Django only describes
them (managed = False) and uses English names in Python and in the API;
db_column links each field to its column. The router in core/routers.py sends
every query for these models to the hotel database, as the role hotel_team.
"""

from django.db import models


class StatusMixin:
    """hotel_team may only change the status column, so only that is saved."""

    def set_status(self, status):
        self.status = self._meta.get_field("status").clean(status, self)
        self.save(update_fields=["status"])


class BookingRequest(StatusMixin, models.Model):
    class Status(models.TextChoices):
        OPEN = "offen", "Offen"
        CONFIRMED = "bestaetigt", "Bestätigt"
        DECLINED = "abgelehnt", "Abgelehnt"

    class Source(models.TextChoices):
        PHONE = "telefon", "Telefon"
        WEBSITE = "website", "Website"

    id = models.BigAutoField(primary_key=True)
    created_at = models.DateTimeField(db_column="erstellt_am")
    category = models.TextField(db_column="kategorie")
    arrival = models.DateField(db_column="anreise")
    departure = models.DateField(db_column="abreise")
    adults = models.SmallIntegerField(db_column="erwachsene")
    children = models.SmallIntegerField(db_column="kinder")
    babies = models.SmallIntegerField(db_column="babys")
    separate_beds = models.BooleanField(db_column="betten_getrennt")
    accessible = models.BooleanField(db_column="barrierefrei")
    wishes = models.TextField(db_column="wuensche", null=True)
    name = models.TextField()
    phone = models.TextField(db_column="telefon", null=True)
    email = models.TextField(null=True)
    source = models.TextField(db_column="quelle", choices=Source.choices)
    call_id = models.TextField(db_column="anruf_id", null=True)
    status = models.TextField(choices=Status.choices)

    class Meta:
        managed = False
        db_table = "buchungsanfragen"
        ordering = ["created_at", "id"]

    def __str__(self):
        return f"BookingRequest {self.id} ({self.status})"


class Callback(StatusMixin, models.Model):
    class Status(models.TextChoices):
        OPEN = "offen", "Offen"
        DONE = "erledigt", "Erledigt"
        NOT_REACHED = "nicht_erreicht", "Nicht erreicht"

    id = models.BigAutoField(primary_key=True)
    created_at = models.DateTimeField(db_column="erstellt_am")
    name = models.TextField()
    phone = models.TextField(db_column="telefon")
    concern = models.TextField(db_column="anliegen")
    reachable = models.TextField(db_column="erreichbar", null=True)
    call_id = models.TextField(db_column="anruf_id", null=True)
    status = models.TextField(choices=Status.choices)

    class Meta:
        managed = False
        db_table = "rueckrufe"
        ordering = ["created_at", "id"]

    def __str__(self):
        return f"Callback {self.id} ({self.status})"


class Call(models.Model):
    """One call from the view anruf_ergebnisse: the call plus what it led to. Read only."""

    class Outcome(models.TextChoices):
        BOOKING_REQUEST = "buchungsanfrage", "Buchungsanfrage"
        CALLBACK = "rueckruf", "Rückruf"
        INFORMATION = "auskunft", "Auskunft"

    call_id = models.TextField(db_column="anruf_id", primary_key=True)
    started_at = models.DateTimeField(db_column="beginn")
    duration_sec = models.IntegerField(db_column="dauer_sek")
    cost_credits = models.IntegerField(db_column="kosten_credits", null=True)
    cost_usd = models.DecimalField(db_column="kosten_usd", max_digits=8, decimal_places=4, null=True)
    channel = models.TextField(db_column="kanal")
    ended_by = models.TextField(db_column="beendet_durch", null=True)
    call_successful = models.TextField(db_column="erfolgreich", null=True)
    title = models.TextField(db_column="titel", null=True)
    sentiment = models.TextField(db_column="stimmung", null=True)
    received_at = models.DateTimeField(db_column="eingegangen_am")
    outcome = models.TextField(db_column="ergebnis", choices=Outcome.choices)

    class Meta:
        managed = False
        db_table = "anruf_ergebnisse"
        ordering = ["-started_at"]

    def __str__(self):
        return f"Call {self.call_id} ({self.outcome})"
