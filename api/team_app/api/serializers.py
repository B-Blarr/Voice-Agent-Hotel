from rest_framework import serializers

from team_app.models import Anruf, Buchungsanfrage, Rueckruf


class StatusOnlySerializer(serializers.ModelSerializer):
    """Shows every field, but a PATCH must carry the status and may change nothing else."""

    def validate(self, attrs):
        # A PATCH is partial, so DRF would accept a body without status.
        if "status" not in attrs:
            raise serializers.ValidationError({"status": ["Dieses Feld ist erforderlich."]})
        return attrs


class BuchungsanfrageSerializer(StatusOnlySerializer):
    class Meta:
        model = Buchungsanfrage
        fields = "__all__"
        # The team may only change the status, everything else comes from Nina or the website.
        read_only_fields = [f.name for f in Buchungsanfrage._meta.fields if f.name != "status"]


class RueckrufSerializer(StatusOnlySerializer):
    class Meta:
        model = Rueckruf
        fields = "__all__"
        read_only_fields = [f.name for f in Rueckruf._meta.fields if f.name != "status"]


class AnrufSerializer(serializers.ModelSerializer):
    class Meta:
        model = Anruf
        fields = "__all__"
        read_only_fields = [f.name for f in Anruf._meta.fields]
