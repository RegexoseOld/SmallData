from pythonosc.udp_client import SimpleUDPClient
import time
import random
import pickle
from config import settings
from song import song_machine

song_client = SimpleUDPClient(settings.ip, settings.SONG_SERVER_PORT)
processing_client = SimpleUDPClient(settings.ip, settings.PROCESSING_PORT)
texts = ['Dies ist der nullte Kommentar von Mock_Interpreter_Client',
         'Dies ist der erste Kommentar',
         'der zweite Kommentar',
         'der dritte Kommentar von Mock_Interpreter_Client. '
         'Ich weiss gar nicht mehr, wann ich das letzte Mal so richtig viel geschrieben habe',
         'Dies ist der vierte und finite Kommentar von Mock_Interpreter_Client']


def run_mock():
    machine = song_machine.create_instance(settings.song_path)
    categories = list(machine.category_counter.keys())

    while True:
        osc_dict = {'text': random.sample(texts, 1)[0],
                    'cat': random.sample(categories, 1)[0],
                    'f_dura': random.sample(settings.note_durations,1)[0]
                    }
        osc_map = pickle.dumps(osc_dict)
        song_client.send_message(settings.INTERPRETER_TARGET_ADDRESS, osc_map)
        time.sleep(3)


if __name__ == "__main__":
    run_mock()
