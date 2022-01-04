import subprocess
import os
import json
# from flask import Flask
from http.server import BaseHTTPRequestHandler
from http.server import ThreadingHTTPServer
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
    p = subprocess.check_call(["python", "webserver/manage.py", "runserver", "0.0.0.0:8000"])
elif args.app == 'song':
    from pythonosc import udp_client
    from song import song_machine
    from song.song_server import SongServer, BeatAdvanceManager
    from song.user_feedback import Tonality, SynthFeedback

    oscul_client = udp_client.SimpleUDPClient(settings.ips['song_server'], settings.OSCULATOR_PORT)
    audience_client = udp_client.SimpleUDPClient(settings.ips['audience'], settings.AUDIENCE_PORT)
    performer_client = udp_client.SimpleUDPClient(settings.ips['performer'], settings.PERFORMER_PORT)
    sc_client = udp_client.SimpleUDPClient("127.0.0.1", 57121)

    machine_instance = song_machine.create_instance(settings.song_path)
    synth_fb = machine_instance.parser.data[machine_instance.parser.SYNTH_CC]

    synth_feedback = SynthFeedback(synth_fb)
    tonality = Tonality(synth_feedback)
    beat_manager = BeatAdvanceManager(machine_instance.current_part)

    song_server = SongServer(oscul_client, audience_client, performer_client, sc_client, machine_instance, beat_manager,
                             tonality, settings.ips['song_server'])
    song_parts = list(machine_instance.parser.song_parts.keys())
    [audience_client.send_message('/parts', part) for part in song_parts]
    audience_client.send_message('/parts', 'all_sent')
    song_server.server.serve_forever()
elif args.app == 'frontend':
    os.chdir('frontend')
    p = subprocess.check_call(["npm", "start"])
elif args.app == 'interpreter':
    # from mocks import mock_interpreter_client
    from mocks import mock_interpreter_keyboard, mock_interpreter_client
    mock_interpreter_client.run_mock()
elif args.app == 'osculator':
    from mocks import beat_mock
    beat_mock.run_mock()

else:
    raise Exception('Unknown command: {}. Please see run.py for options'.format(args.app))

