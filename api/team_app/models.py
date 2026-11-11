"""The hotel tables the team works with.

The tables already exist: they come from the SQL migrations in sql/ and are
owned by hotel_owner. managed = False tells Django to only describe them and
never create, change or drop them. The router in core/routers.py sends every
query for these models to the hotel database, as the role hotel_team.
"""

from django.db import models


class StatusMixin:
    """hotel_team may only change the status column, so only that is saved."""

    def set_status(self, status):
        # Check the value against the choices first, then save only this one column.
        self.status = self._meta.get_field("status").clean(status, self)
        self.save(update_fields=["status"])


class Buchungsanfrage(StatusMixin, models.Model):
    class Status(models.TextChoices):
        OFFEN = "offen", "Offen"
        BESTAETIGT = "bestaetigt", "Bestätigt"
        ABGELEHNT = "abgelehnt", "Abgelehnt"

    class Quelle(models.TextChoices):
        TELEFON = "telefon", "Telefon"
        WEBSITE = "website", "Website"

    id = models.BigAutoField(primary_key=True)
    erstellt_am = models.DateTimeField()
    kategorie = models.TextField()
    anreise = models.DateField()
    abreise = models.DateField()
    erwachsene = models.SmallIntegerField()
    kinder = models.SmallIntegerField()
    babys = models.SmallIntegerField()
    betten_getrennt = models.BooleanField()
    barrierefrei = models.BooleanField()
    wuensche = models.TextField(null=True)
    name = models.TextField()
    telefon = models.TextField(null=True)
    email = models.TextField(null=True)
    quelle = models.TextField(choices=Quelle.choices)
    anruf_id = models.TextField(null=True)
    status = models.TextField(choices=Status.choices)

    class Meta:
        managed = False
        db_table = "buchungsanfragen"
        ordering = ["-erstellt_am"]

    def __str__(self):
        return f"Buchungsanfrage {self.id} ({self.status})"


class Rueckruf(StatusMixin, models.Model):
    class Status(models.TextChoices):
        OFFEN = "offen", "Offen"
        ERLEDIGT = "erledigt", "Erledigt"
        NICHT_ERREICHT = "nicht_erreicht", "Nicht erreicht"

    id = models.BigAutoField(primary_key=True)
    erstellt_am = models.DateTimeField()
    name = models.TextField()
    telefon = models.TextField()
    anliegen = models.TextField()
    erreichbar = models.TextField(null=True)
    anruf_id = models.TextField(null=True)
    status = models.TextField(choices=Status.choices)

    class Meta:
        managed = False
        db_table = "rueckrufe"
        ordering = ["-erstellt_am"]

    def __str__(self):
        return f"Rueckruf {self.id} ({self.status})"


class Anruf(models.Model):
    """One call from the view anruf_ergebnisse: the call plus what it led to. Read only."""

    class Ergebnis(models.TextChoices):
        BUCHUNGSANFRAGE = "buchungsanfrage", "Buchungsanfrage"
        RUECKRUF = "rueckruf", "Rückruf"
        AUSKUNFT = "auskunft", "Auskunft"

    anruf_id = models.TextField(primary_key=True)
    beginn = models.DateTimeField()
    dauer_sek = models.IntegerField()
    kosten_credits = models.IntegerField(null=True)
    kosten_usd = models.DecimalField(max_digits=8, decimal_places=4, null=True)
    kanal = models.TextField()
    beendet_durch = models.TextField(null=True)
    erfolgreich = models.TextField(null=True)
    titel = models.TextField(null=True)
    stimmung = models.TextField(null=True)
    eingegangen_am = models.DateTimeField()
    ergebnis = models.TextField(choices=Ergebnis.choices)

    class Meta:
        managed = False
        db_table = "anruf_ergebnisse"
        ordering = ["-beginn"]

    def __str__(self):
        return f"Anruf {self.anruf_id} ({self.ergebnis})"
