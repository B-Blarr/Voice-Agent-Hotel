from rest_framework.routers import DefaultRouter

from .views import BookingRequestViewSet, CallbackViewSet, CallViewSet

router = DefaultRouter()
router.register("booking-requests", BookingRequestViewSet)
router.register("callbacks", CallbackViewSet)
router.register("calls", CallViewSet)

urlpatterns = router.urls
