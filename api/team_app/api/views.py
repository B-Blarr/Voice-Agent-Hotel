from rest_framework import mixins, viewsets

from team_app.models import Anruf, Buchungsanfrage, Rueckruf

from .serializers import AnrufSerializer, BuchungsanfrageSerializer, RueckrufSerializer


class StatusFilterMixin:
    """?status=offen shows only the requests the team still has to handle."""

    def get_queryset(self):
        queryset = super().get_queryset()
        status = self.request.query_params.get("status")
        if status:
            queryset = queryset.filter(status=status)
        return queryset


class StatusUpdateViewSet(
    StatusFilterMixin,
    mixins.ListModelMixin,
    mixins.RetrieveModelMixin,
    mixins.UpdateModelMixin,
    viewsets.GenericViewSet,
):
    """List, show one and change the status. No create, no delete, no PUT."""

    http_method_names = ["get", "patch", "head", "options"]

    def perform_update(self, serializer):
        # A normal save() writes every column, which hotel_team may not do.
        serializer.instance.set_status(serializer.validated_data["status"])


class BuchungsanfrageViewSet(StatusUpdateViewSet):
    queryset = Buchungsanfrage.objects.all()
    serializer_class = BuchungsanfrageSerializer


class RueckrufViewSet(StatusUpdateViewSet):
    queryset = Rueckruf.objects.all()
    serializer_class = RueckrufSerializer


class AnrufViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Anruf.objects.all()
    serializer_class = AnrufSerializer
