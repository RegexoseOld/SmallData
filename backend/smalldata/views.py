from rest_framework import viewsets
from .serializers import UtteranceSerializer, CategorySerializer
from .models import Utterance, Category


class UtteranceView(viewsets.ModelViewSet):
    serializer_class = UtteranceSerializer
    queryset = Utterance.objects.all()

    def perform_create(self, serializer):
        #  TODO: First detect the correct category,
        #Fetch sent data:
        text = serializer.validated_data["text"]

        """
        #predict class
        category_name, prob = Classifier.predict_proba(text)
        """
        category_name = 'Lob'
        category = Category.objects.all().filter(name=category_name)[0]
        serializer.validated_data["category"] = category
        #  TODO:  Second, send the category to the music server
        super(UtteranceView, self).perform_create(serializer)


class CategoryView(viewsets.ModelViewSet):
    serializer_class = CategorySerializer
    queryset = Category.objects.all()
