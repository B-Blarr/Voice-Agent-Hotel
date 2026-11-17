from rest_framework import serializers

from team_app.models import BookingRequest, Call, Callback


class StatusOnlySerializer(serializers.ModelSerializer):
    """Shows every field, but a PATCH must carry the status and may change nothing else."""

    def validate(self, attrs):
        # A PATCH is partial, so DRF would accept a body without status.
        if "status" not in attrs:
            raise serializers.ValidationError({"status": ["Dieses Feld ist erforderlich."]})
        return attrs


class BookingRequestSerializer(StatusOnlySerializer):
    class Meta:
        model = BookingRequest
        fields = "__all__"
        read_only_fields = [f.name for f in BookingRequest._meta.fields if f.name != "status"]


class CallbackSerializer(StatusOnlySerializer):
    class Meta:
        model = Callback
        fields = "__all__"
        read_only_fields = [f.name for f in Callback._meta.fields if f.name != "status"]


class CallSerializer(serializers.ModelSerializer):
    class Meta:
        model = Call
        fields = "__all__"
        read_only_fields = [f.name for f in Call._meta.fields]
