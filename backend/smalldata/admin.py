from django.contrib import admin
from .models import Utterance, TrainingUtterance
from import_export import resources


class TrainingUtteranceResource(resources.ModelResource):

    class Meta:
        model = TrainingUtterance


class UtteranceAdmin(admin.ModelAdmin):
    list_display = ('text', )


# Register your models here.
admin.site.register(Utterance, UtteranceAdmin)  # add this
