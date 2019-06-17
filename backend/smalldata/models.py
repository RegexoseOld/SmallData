from django.db import models


class Utterance(models.Model):
    text = models.CharField(max_length=500)

    def _str_(self):
        return self.text


class Category(models.Model):
    name = models.CharField(max_length=25, unique=True)
    description = models.CharField(max_length=250, blank=True, null=True)

    def _str_(self):
        return self.name