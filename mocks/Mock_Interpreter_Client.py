from pythonosc.udp_client import SimpleUDPClient
import time
import random
import pickle
from config import settings

mock_client = SimpleUDPClient('127.0.0.1', 5020)
texts = ['Dies ist der nullte Kommentar von Mock_Interpreter_Client',
         'Dies ist der erste Kommentar',
         'der zweite Kommentar' ,
         'der dritte Kommentar von Mock_Interpreter_Client. Ich weiss gar nicht mehr, wann ich das letzte Mal so richtig viel geschrieben habe',
         'Dies ist der vierte und finite Kommentar von Mock_Interpreter_Client']

level_values = [3, 5, 8]

osc_dict = {}

if __name__ == "__main__":

    # add file to path so import works, see https://stackoverflow.com/a/19190695/7414040
    from os import sys, path
    sys.path.append(path.dirname(path.dirname(path.abspath(__file__))))
    from song import song_server, song_machine

    song_machine = song_machine.create_instance(settings.song_path)
    categories = song_machine.category_counter.keys()

    while True:
        osc_dict = {'text': texts[random.randint(0, 4)],
                    'cat': categories[random.randint(0, len(categories))],
                    'level': level_values[random.randint(0, 2)]}
        osc_map = pickle.dumps(osc_dict)
        mock_client.send_message(song_server.INTERPRETER_TARGET_ADDRESS, osc_map)
        time.sleep(2)
