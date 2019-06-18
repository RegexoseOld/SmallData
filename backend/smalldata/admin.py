from django.contrib import admin
from .models import Utterance# add this


class UtteranceAdmin(admin.ModelAdmin):
    list_display = ('text', )


# Register your models here.
admin.site.register(Utterance, UtteranceAdmin) # add this
