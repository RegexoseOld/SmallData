import pickle
from pythonosc import dispatcher, osc_server
from UDPClient import Client_MusicServer

class Live:
    def __init__(self, client, message):
        self.client = client
        self.message = message

    def message_handler(self, address, map):
        map = pickle.loads(map)

        self.client.send_message('/rack', [20, 1.0])
        self.client.send_message('/rack', [20, 0.0])
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
