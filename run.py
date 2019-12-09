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
parser.add_argument('app')
parser.add_argument('--skip-checks', help='skip consistency checks', action="store_true")
args = parser.parse_args()

if not args.skip_checks:
    check_model_song_cats()

if args.app == 'backend':
    p = subprocess.check_call(["python", "webserver/manage.py", "runserver"])
elif args.app == 'song':
    from pythonosc import udp_client
    from os import sys, path

    # sys.path.append(path.dirname(path.dirname(path.abspath(__file__))))
    from song import song_machine
    from song.song_server import SongServer

    oscul_client = udp_client.SimpleUDPClient(settings.ip, settings.OSCULATOR_PORT)
    disp_client = udp_client.SimpleUDPClient(settings.ip, settings.DISPLAY_PORT)

    machine_instance = song_machine.create_instance(settings.song_path)

    song_server = SongServer(oscul_client, disp_client, machine_instance)
    song_server.server.serve_forever()
    # p = subprocess.check_call(["python", "song/song_server.py"])
elif args.app == 'frontend':
    os.chdir('frontend')
    p = subprocess.check_call(["npm", "start"])
elif args.app == 'display':
    from song.display.playhead import Playhead
    from song.display.status_display import SongStatus
    from song.display.display_server import DisplayServer
    import asyncio

    playhead = Playhead()
    #  TODO use actula states of song
    song_graphic = SongStatus(settings.song_file, ["intro", "scene02", "scene03"], playhead)
    display_server = DisplayServer(song_graphic)

    loop = asyncio.get_event_loop()
    result = loop.run_until_complete(display_server.init_main())
elif args.app == 'mock':
    from mocks import Mock_Interpreter_Client

    Mock_Interpreter_Client.run_mock()

else:
    raise Exception('Unknown command: {}'.format(args.app))
