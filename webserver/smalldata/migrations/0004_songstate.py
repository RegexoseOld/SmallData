# Generated by Django 4.0 on 2021-12-20 11:21

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('smalldata', '0003_auto_20210805_1320'),
    ]

    operations = [
        migrations.CreateModel(
            name='SongState',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('state', models.JSONField()),
            ],
        ),
    ]
