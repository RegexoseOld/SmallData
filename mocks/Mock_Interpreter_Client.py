from pythonosc.udp_client import SimpleUDPClient
import time
import random
import pickle

mock_client = SimpleUDPClient('127.0.0.1', 5020)
categories = ['Kritik', 'Lob']
level_values = [3, 5, 8]

osc_dict = {}

if __name__ == "__main__":

    # add file to path so import works, see https://stackoverflow.com/a/19190695/7414040
    from os import sys, path
    sys.path.append(path.dirname(path.dirname(path.abspath(__file__))))
    from song import song_server

    while True:
        osc_dict = {'text' : 'Dies ist ein Kommentar von Mock_Interpreter_Client',
                    'cat': categories[random.randint(0, 1)],
                    'level': level_values[random.randint(0, 2)]}
        osc_map = pickle.dumps(osc_dict)
        mock_client.send_message(song_server.INTERPRETER_TARGET_ADDRESS, osc_map)
        time.sleep(5)
