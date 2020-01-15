from pythonosc.udp_client import SimpleUDPClient
import time
from config import settings


notes = list(settings.note_to_beat.keys())
processing_client = SimpleUDPClient(settings.ip, settings.PROCESSING_PORT)
song_client = SimpleUDPClient(settings.ip, settings.SONG_SERVER_PORT)


def run_mock():
    idx = 0
    while True:
        note = notes[idx]
        print('Sending "{}"'.format(note))
        processing_client.send_message(settings.OSCULATOR_TARGET_ADDRESS, note)
        song_client.send_message(settings.SONG_BEAT_ADDRESS, note)
        idx = (idx + 1) % (len(notes)-1)
        time.sleep(2)
