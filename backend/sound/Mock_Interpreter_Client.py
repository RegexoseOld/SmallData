from pythonosc.udp_client import SimpleUDPClient
from song_server import INTERPRETER_TARGET_ADDRESS
import time
import random
import pickle

mock_client = SimpleUDPClient('127.0.0.1', 5020)
categories = ['Kritik', 'Lob']
level_values = [3, 5, 8]

if __name__ == "__main__":
    while True:
        osc_dict = {'cat': categories[random.randint(0, 1)],
               'level' : level_values[random.randint(0, 2)]}
        osc_map = pickle.dumps(osc_dict)
        mock_client.send_message(INTERPRETER_TARGET_ADDRESS, osc_map)
        time.sleep(4)

