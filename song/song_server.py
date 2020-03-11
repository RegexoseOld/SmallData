import pickle
from pythonosc.osc_server import ThreadingOSCUDPServer
from pythonosc.dispatcher import Dispatcher

from config import settings
from song.song_machine import State


class BeatAdvanceManager:
    """ A simple state machine. Machine starts in 'normal' state. When the next part is changed,
    machine changes to 'prepare'. On the next '1' machine moves to 'warning', then on the next
    '1' back to 'normal' """
    STATE_NORMAL = 0
    STATE_PREPARE = 1
    STATE_WARNING = 2

    def __init__(self, first_part_name):
        self.state = self.STATE_NORMAL
        self.next_part = State(first_part_name, 0)
        self.current_part = State(first_part_name, 0)
        self.__counter = 0

    def update_next_part(self, part):
        if self.state == self.STATE_NORMAL:
            self.state = self.STATE_PREPARE
            self.next_part = part

    def update_beat_counter(self, counter):
        if counter == self.__counter:
            return False
        else:
            self.__counter = counter
            if counter == settings.note_to_beat['first_count_in_bar']:
                if self.state == self.STATE_PREPARE:
                    self.state = self.STATE_WARNING
                elif self.state == self.STATE_WARNING:
                    self.state = self.STATE_NORMAL
                    self.current_part = self.next_part
            return True

    def check_is_one_of_state(self, state):
        return (self.__counter == '1') and (self.state == state)

    def is_warning(self):
        return self.state == self.STATE_WARNING


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

        self.osculator_client.send_message(settings.SONG_ADVANCE_ADDRESS, (9, 1.0))
        self.osculator_client.send_message(settings.SONG_ADVANCE_ADDRESS, (9, 0.0))

    def interpreter_handler(self, _, content):
        if self.song_machine.is_locked():
            return

        osc_map = pickle.loads(content)
        print('SongerServer. receiving: ', osc_map)
        self._send_level(osc_map['level'])

        self.song_machine.update_state(osc_map['cat'])

        if self.song_machine.is_criteria_met():
            self.beat_manager.update_next_part(self.song_machine.current_state)
            self.song_machine.set_lock()

        self._send_utterance_info(osc_map)

    def beat_handler(self, _, note):
        counter = settings.note_to_beat[note]
        if self.beat_manager.update_beat_counter(counter):
            self._send_part(counter)
            if self.beat_manager.check_is_one_of_state(BeatAdvanceManager.STATE_NORMAL):
                self.song_machine.release_lock()

    def _send_level(self, level):
        self.osculator_client.send_message('/rack', (level / 10))
        self.osculator_client.send_message('/osc_notes', (level + 90, 100, 1.0))
        self.osculator_client.send_message('/osc_notes', (level + 90, 100, 0.0))

    def _send_part(self, counter):
        next_part = self.beat_manager.next_part if self.beat_manager.is_warning() else self.beat_manager.current_part

        if self.beat_manager.check_is_one_of_state(BeatAdvanceManager.STATE_WARNING):
            self.osculator_client.send_message(settings.SONG_ADVANCE_ADDRESS, (int(next_part.note), 1.0))
            self.osculator_client.send_message(settings.SONG_ADVANCE_ADDRESS, (int(next_part.note), 0.0))

        message = (counter, str(self.beat_manager.is_warning()), self.beat_manager.current_part.name, next_part.name)
        # print('SongerServer. sending: ', message)
        self.display_client.send_message(settings.SONG_BEAT_ADDRESS, message)

    def _send_utterance_info(self, input_dict):
        print(self.song_machine.category_counter, isinstance(self.song_machine.category_counter, dict))
        input_dict['category_counter'] = self.song_machine.category_counter
        input_dict['is_locked'] = self.song_machine.is_locked()

        content = pickle.dumps(input_dict, protocol=2)
        self.display_client.send_message(settings.DISPLAY_TARGET_ADDRESS, content)
