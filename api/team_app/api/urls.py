from rest_framework.routers import DefaultRouter

from .views import AnrufViewSet, BuchungsanfrageViewSet, RueckrufViewSet

router = DefaultRouter()
router.register("buchungsanfragen", BuchungsanfrageViewSet)
router.register("rueckrufe", RueckrufViewSet)
router.register("anrufe", AnrufViewSet)

urlpatterns = router.urls
