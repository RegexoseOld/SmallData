import time
import os

from backend.settings import BASE_DIR
from rest_framework import viewsets
from .serializers import UtteranceSerializer, CategorySerializer, TrainingUtteranceSerializer
from .models import Utterance, Category, TrainingUtterance

from classification.Classifier_max import Classifier
from sound.UDPClient import Client_MusicServer
from sound.rules import SIMPLE_NOTES

dir_path = os.path.dirname(os.path.realpath(__file__))
clf = Classifier(os.path.join(BASE_DIR, 'model_data'))
#   Client for a simple Feedback from Ableton Live
music_client = Client_MusicServer('127.0.0.1', 5015)


class UtteranceView(viewsets.ModelViewSet):
    serializer_class = UtteranceSerializer
    queryset = Utterance.objects.all()

    def perform_create(self, serializer):
        #  TODO: First detect the correct category,
        # Fetch sent data:
        print(serializer.validated_data)
        text = serializer.validated_data["text"]
        # send text to clf to return a category
        cat, prob = clf.predict_proba(text, verbose=True)
        print('cat: {}\nproba {}'.format(cat, prob))
        # lookup found category in database

        #  TODO: build a test during startup to make sure the db and the model reproduce the same categories!
        categories = Category.objects.all().filter(name=str(cat))
        if not categories:  # if db is inconsistent with model, just use any cat
            categories = Category.objects.all()
            print('WARNING: no matching category in db! Using random assignment')
        category = categories[0]

        serializer.validated_data["category"] = category
        #  Second, send the category to the music server
        #  TODO: build a test during startup to make sure the db and the model reproduce the same categories!
        if cat not in SIMPLE_NOTES:
            note = SIMPLE_NOTES.popitem()[1]
            print('WARNING: category not contained in SIMPLE_NOTES! Using random assignment')
        else:
            note = SIMPLE_NOTES[cat]
        print('note: ', note)
        
        music_client.msg_send(note, 100, 1.0)
        time.sleep(1)
        music_client.msg_send(note, 100, 0.0)
        # display found category in the app
        super(UtteranceView, self).perform_create(serializer)


class CategoryView(viewsets.ModelViewSet):
    serializer_class = CategorySerializer
    queryset = Category.objects.all()


class TrainingUtteranceView(viewsets.ModelViewSet):
    serializer_class = TrainingUtteranceSerializer
    queryset = TrainingUtterance.objects.all()
