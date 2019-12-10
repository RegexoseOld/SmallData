from pythonosc.udp_client import SimpleUDPClient
import time
from config import settings


notes = list(settings.note_to_beat.keys())
mock_client = SimpleUDPClient(settings.ip, settings.DISPLAY_PORT)


def run_mock():
    idx = 0
    while True:
        note = notes[idx]
        print('Sending "{}"'.format(note))
        mock_client.send_message(settings.OSCULATOR_TARGET_ADDRESS, note)
        idx = (idx + 1) % len(notes)
        time.sleep(2)
