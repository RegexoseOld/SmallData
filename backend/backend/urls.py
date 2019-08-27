from django.contrib import admin
from django.urls import path, include
from rest_framework import routers
from smalldata import views


router = routers.DefaultRouter()
router.register(r'utterances', views.UtteranceView, 'utterance')
router.register(r'categories', views.CategoryView, 'category')
router.register(r'training_utterances', views.TrainingUtteranceView, 'training_utterance')

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include(router.urls))
]