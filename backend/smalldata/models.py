from django.db import models


class Utterance(models.Model):
    text = models.CharField(max_length=500)

    def _str_(self):
        return self.text
