import subprocess
import os
import json
import argparse
from config import settings
import joblib
from song.song_machine import SongValidator


def check_model_song_cats():
    #  validate consistency of trained model and song
    with open(settings.song_path, 'r') as f:
        json_data = json.load(f)
    song_validator = SongValidator(json_data)
    song_validator.validate()
    song_categories = song_validator.categories

    clf = joblib.load(os.path.join(settings.DATA_DIR, 'sgd_clf.pkl'))

    missing_cats = []
    for clf_cat in clf.classes_:
        if clf_cat not in song_categories:
            missing_cats.append(clf_cat)

    if missing_cats:
        raise Exception('Categories are inconsistent: {} not in song'.format(missing_cats))


parser = argparse.ArgumentParser()
parser.add_argument("app")
args = parser.parse_args()

check_model_song_cats()

if args.app == 'backend':
    p = subprocess.check_call(["python", "webserver/manage.py", "runserver"])
elif args.app == 'song':
    p = subprocess.check_call(["python", "song/song_server.py"])
elif args.app == 'frontend':
    os.chdir('frontend')
    p = subprocess.check_call(["npm", "start"])
