from django.shortcuts import render
from rest_framework import viewsets
from .serializers import UtteranceSerializer, CategorySerializer
from .models import Utterance, Category


class UtteranceView(viewsets.ModelViewSet):
    serializer_class = UtteranceSerializer
    queryset = Utterance.objects.all()


class CategoryView(viewsets.ModelViewSet):
    serializer_class = CategorySerializer
    queryset = Category.objects.all()
