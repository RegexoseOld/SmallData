from rest_framework import viewsets
from .serializers import UtteranceSerializer, CategorySerializer
from .models import Utterance, Category


class UtteranceView(viewsets.ModelViewSet):
    serializer_class = UtteranceSerializer
    queryset = Utterance.objects.all()

    def perform_create(self, serializer):
        #  TODO: First detect the correct category,
        serializer.validated_data["category"] = self.__get_category_for_utterance(serializer)
        #  TODO:  Second, send the category to the music server
        super(UtteranceView, self).perform_create(serializer)

    def __get_category_for_utterance(self, serializer):
        category = None
        if len(Category.objects.all())>0:
            category = Category.objects.all()[0]
        return category


class CategoryView(viewsets.ModelViewSet):
    serializer_class = CategorySerializer
    queryset = Category.objects.all()
