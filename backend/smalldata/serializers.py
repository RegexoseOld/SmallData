from rest_framework import serializers
from .models import Utterance, Category


class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = ('id', 'name', 'description')


class UtteranceSerializer(serializers.ModelSerializer):
    category_id = CategorySerializer(many=False, read_only=True)

    class Meta:
        model = Utterance
        fields = '__all__'
