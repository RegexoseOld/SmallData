import pickle
from pythonosc import dispatcher, osc_server
from UDPClient import Client_MusicServer

def rules(cat):
    if cat == "Kritik":
        return 0
    elif cat == "Lob":
        return 1

class Live:
    def __init__(self, client, message):
        self.client = client
        self.message = message
        self.song_position = 0

    def message_handler(self, address, map):
        map = pickle.loads(map)
        level = map['level']
        advance = rules(map['cat'])
        self.song_position += advance
        # print(self.song_position)
        self.client.send_message('/rack', (level/10))
        self.client.send_message('/advance', (self.song_position, 1.0))
        self.client.send_message('/advance', (self.song_position, 0.0))
        print('address: {} map: {}'.format(address, map))


if __name__ == "__main__":
    dispatcher = dispatcher.Dispatcher()
    mock_OSC_server = osc_server.ThreadingOSCUDPServer(('127.0.0.1', 5020), dispatcher)
    mock_Ableton_server = Client_MusicServer('127.0.0.1', 5010, 'condition')

    live = Live(mock_Ableton_server, ['initial_category', 'initial_level'])

    def print_message(address, map):
        map = pickle.loads(map)
        print('address: {}\nmap: {}'.format(address, map))

    # dispatcher.map("/buildmap", lambda address, map: print_message(address, map))
    dispatcher.map("/buildmap", lambda address, map: live.message_handler(address, map))

    mock_OSC_server.serve_forever()
