from rest_framework import serializers
from .models import Utterance, Category


class UtteranceSerializer(serializers.ModelSerializer):
    class Meta:
        model = Utterance
        fields = ('id', 'text')


class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = ('id', 'name', 'description')