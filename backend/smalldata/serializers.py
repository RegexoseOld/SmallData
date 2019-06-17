from rest_framework import serializers
from .models import Utterance

class UtteranceSerializer(serializers.ModelSerializer):
    class Meta:
        model = Utterance
        fields = ('id', 'text')