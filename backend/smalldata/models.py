from django.db import models


class Category(models.Model):
    name = models.CharField(max_length=25, unique=True)
    description = models.CharField(max_length=250, blank=True, null=True)

    def _str_(self):
        return self.name


class Utterance(models.Model):
    category = models.ForeignKey('Category', on_delete=models.CASCADE, null=True)
    text = models.CharField(max_length=500)

    def _str_(self):
        return self.text


class TrainingUtterance(models.Model):
    category = models.CharField(max_length=500)
    text = models.CharField(max_length=500)

    def _str_(self):
        return self.text
