from UDPClient import ClientIO
import time
import random
import pickle

mock_client = ClientIO('127.0.0.1', 5020)
categories = ['lecture', 'praise']
level_values = [3, 5, 8]

dict = {}

if __name__ == "__main__":
    while True:
        dict = {'cat': categories[random.randint(0, 1)],
               'level' : level_values[random.randint(0, 2)]}
        map = pickle.dumps(dict)
        mock_client.send_buildmap(map)
        time.sleep(5)

