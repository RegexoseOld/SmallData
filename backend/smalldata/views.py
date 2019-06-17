from django.shortcuts import render
from rest_framework import viewsets
from .serializers import UtteranceSerializer
from .models import Utterance


class UtteranceView(viewsets.ModelViewSet):
    serializer_class = UtteranceSerializer
    queryset = Utterance.objects.all()
