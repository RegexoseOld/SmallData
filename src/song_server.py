import pickle
from pythonosc import dispatcher, osc_server

import json
from UDPClient import Client_MusicServer

INTERPRETER_TARGET_ADDRESS = "/interpreter_input"

def rules(cat):
    if cat == "Kritik":
        return 0
    elif cat == "Lob":
        return 1


class SongServer:
    """
    Receives msseages from the Interpreter translates them and forwards the result to the osculator
    """
    def __init__(self, client, song_machine):
        self.osculator_client = client
        self._song_machine = song_server
        song_dispatcher = dispatcher.Dispatcher()
        song_dispatcher.map(INTERPRETER_TARGET_ADDRESS, lambda address, map: self.message_handler(address, map))
        self.interpreter_server = osc_server.ThreadingOSCUDPServer(('127.0.0.1', 5020), song_dispatcher)

    def message_handler(self, address, osc_map):
        osc_map = pickle.loads(osc_map)
        level = osc_map['level']
        advance = rules(osc_map['cat'])
        current_state = self._song_machine.current_state
        self._song_machine.update_state(osc_map['cat'])
        if current_state != self._song_machine.current_state:
            # print(self.song_position)
            self.osculator_client.send_message('/rack', (level / 10))
            self.osculator_client.send_message('/advance', (self.song_position, 1.0)) # was braucht Osculator hier?
            self.osculator_client.send_message('/advance', (self.song_position, 0.0))
        print('address: {} map: {}'.format(address, osc_map))

    def serve_forever(self, *args):
        self.interpreter_server.serve_forever(*args)


if __name__ == "__main__":
    mock_osculator_client = Client_MusicServer('127.0.0.1', 5010, 'condition')

    path_to_song_file = '../config/heavy_lemon.json'
    with open(path_to_song_file, 'r') as f:
        json_data = json.load(f)

    SongMachine.SongValidator(json_data).validate()
    json_parser = SongMachine.SongParser(json_data)
    json_parser.parse()
    song = SongMachine.SongMachine(json_parser)

    song_server = SongServer(mock_osculator_client, song)
    song_server.serve_forever()
