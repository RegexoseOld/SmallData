import pickle
from pythonosc import dispatcher, osc_server
from UDPClient import Client_MusicServer

def rules(cat):
    if cat == "Kritik":
        return 0
    elif cat == "Lob":
        return 1


class SongServer:
    """
    Receives msseages from the Interpreter translates them and forwards the result to the osculator
    """
    def __init__(self, client):
        self.osculator_client = client
        song_dispatcher = dispatcher.Dispatcher()
        song_dispatcher.map("/buildmap", lambda address, map: self.message_handler(address, map))
        self.interpreter_server = osc_server.ThreadingOSCUDPServer(('127.0.0.1', 5020), song_dispatcher)
        self.song_position = 0

    def message_handler(self, address, osc_map):
        osc_map = pickle.loads(osc_map)
        level = osc_map['level']
        advance = rules(osc_map['cat'])
        self.song_position += advance
        # print(self.song_position)
        self.osculator_client.send_message('/rack', (level / 10))
        self.osculator_client.send_message('/advance', (self.song_position, 1.0))
        self.osculator_client.send_message('/advance', (self.song_position, 0.0))
        print('address: {} map: {}'.format(address, osc_map))

    def serve_forever(self, *args):
        self.interpreter_server.serve_forever(*args)


if __name__ == "__main__":

    mock_osculator_client = Client_MusicServer('127.0.0.1', 5010, 'condition')

    song_server = SongServer(mock_osculator_client)

    def print_message(address, osc_map):
        osc_map = pickle.loads(osc_map)
        print('address: {}\nmap: {}'.format(address, osc_map))

    # dispatcher.map("/buildmap", lambda address, map: print_message(address, map))


    song_server.serve_forever()
