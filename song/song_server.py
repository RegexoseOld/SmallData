import pickle
from pythonosc.osc_server import ThreadingOSCUDPServer
from pythonosc.dispatcher import Dispatcher

from config import settings


class SongServer:
    def __init__(self, osculator_client, display_client, machine, beat_manager):
        self.osculator_client = osculator_client
        self.display_client = display_client
        self.song_machine = machine
        self.beat_manager = beat_manager

        dispatcher = Dispatcher()
        dispatcher.map(settings.INTERPRETER_TARGET_ADDRESS, self.interpreter_handler)
        dispatcher.map(settings.SONG_BEAT_ADDRESS, self.beat_handler)
        self.server = ThreadingOSCUDPServer((settings.ip, settings.SONG_SERVER_PORT), dispatcher)

        self.song_scenes = {k: v for k, v in zip(
            self.song_machine.parser.states,
            range(len(self.song_machine.parser.states)
                  ))}

        self.osculator_client.send_message(settings.SONG_ADVANCE_ADDRESS, (0, 1.0))
        self.osculator_client.send_message(settings.SONG_ADVANCE_ADDRESS, (0, 0.0))

    def interpreter_handler(self, _, content):
        if self.song_machine.is_locked():
            return

        osc_map = pickle.loads(content)
        self.send_level(osc_map['level'])

        current_state = self.song_machine.current_state
        self.song_machine.update_state(osc_map['cat'])

        if current_state != self.song_machine.current_state:
            self.beat_manager.update_next_part(self.song_machine.current_state)
            self.song_machine.set_lock()

    def beat_handler(self, _, counter):
        print('SongServer, beat: {}'.format(counter))
        self.beat_manager.update_beat_counter(counter)
        self.send_part(counter)
        if self.beat_manager.is_start_of_normal():
            self.song_machine.release_lock()

    def send_level(self, level):
        self.osculator_client.send_message('/rack', (level / 10))
        self.osculator_client.send_message('/osc_notes', (level + 90, 100, 1.0))
        self.osculator_client.send_message('/osc_notes', (level + 90, 100, 0.0))

    def send_part(self, counter):
        next_part = self.beat_manager.next_part if self.beat_manager.is_warning() else self.beat_manager.current_part

        self.osculator_client.send_message(settings.SONG_ADVANCE_ADDRESS, (next_part, 1.0))
        self.osculator_client.send_message(settings.SONG_ADVANCE_ADDRESS, (next_part, 0.0))
        self.display_client.send_message(
            settings.SONG_ADVANCE_ADDRESS,
            (counter, self.beat_manager.is_warning(), self.beat_manager.current_part, next_part)
        )
