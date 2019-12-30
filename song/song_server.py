import pickle
from pythonosc.osc_server import ThreadingOSCUDPServer
from pythonosc.dispatcher import Dispatcher
from config import settings


class SongServer:
    server = None
    beat_manager = False

    def __init__(self, osculator_client, display_client, machine):
        self.osculator_client = osculator_client
        self.display_client = display_client
        self._song_machine = machine

        dispatcher = Dispatcher()
        dispatcher.map(settings.INTERPRETER_TARGET_ADDRESS, self.message_handler)
        dispatcher.map(settings.BEATMANAGER_ADDRESS, self.message_handler)
        self.server = ThreadingOSCUDPServer((settings.ip, settings.INTERPRETER_PORT), dispatcher)

        self.song_scenes = {k: v for k, v in zip(
            self._song_machine.parser.states,
            range(len(self._song_machine.parser.states)
                  ))}

        self.osculator_client.send_message(settings.SONG_ADVANCE_ADDRESS, (0, 1.0))
        self.osculator_client.send_message(settings.SONG_ADVANCE_ADDRESS, (0, 0.0))

    def _update_song(self, osc_map):
        level = osc_map['level']
        self.osculator_client.send_message('/rack', (level / 10))
        self.osculator_client.send_message('/osc_notes', (level + 90, 100, 1.0))
        self.osculator_client.send_message('/osc_notes', (level + 90, 100, 0.0))
        current_state = self._song_machine.current_state
        self._song_machine.update_state(osc_map['cat'])
        if current_state != self._song_machine.current_state:
            self.advance_to_scene = self.song_scenes[self._song_machine.current_state.name]
            print('update with status: {}\ncurrent_state: {}\nadvance_to_scene: {}'
                  .format(osc_map['cat'], self._song_machine.current_state.name, self.advance_to_scene))
            self.osculator_client.send_message(settings.SONG_ADVANCE_ADDRESS, (self.advance_to_scene, 1.0))
            self.osculator_client.send_message(settings.SONG_ADVANCE_ADDRESS, (self.advance_to_scene, 0.0))
            self.display_client.send_message(settings.SONG_ADVANCE_ADDRESS, self._song_machine.current_state.name)

    def message_handler(self, address, content):
        osc_map = pickle.loads(content)
        print('address: {}\nmap: {}'.format(address, osc_map))
        self._update_song(osc_map)
