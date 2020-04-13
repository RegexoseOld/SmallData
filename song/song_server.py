import pickle
from pythonosc.osc_server import ThreadingOSCUDPServer
from pythonosc.dispatcher import Dispatcher
from collections import Counter
import time

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

        self.osculator_client.send_message(settings.SONG_ADVANCE_ADDRESS, (1, 1.0))
        self.osculator_client.send_message(settings.SONG_ADVANCE_ADDRESS, (1, 0.0))
        self.tonality = Tonality(self.song_machine.parser.categories)
        self._send_init_to_display()

    def interpreter_handler(self, _, content):
        if self.song_machine.is_locked():
            return

        osc_map = pickle.loads(content)
        self.send_FX()

        self.tonality.update_tonality(osc_map['cat'])
        note = settings.category_to_note[osc_map['cat']]
        dura = osc_map['f_dura']
        self.send_quittung(note, 100, dura)

        if self.song_machine.update_state(osc_map['cat']):  # True if state is changed
            self.beat_manager.update_next_part(self.song_machine.current_state)

        self._send_utterance_to_display(osc_map)

    def beat_handler(self, _, note):
        counter = settings.note_to_beat[note]
        if self.beat_manager.update_beat_counter(counter):
            self._send_part(counter)
            if self.beat_manager.check_is_one_of_state(BeatAdvanceManager.STATE_NORMAL) and self.song_machine.is_locked():
                self.song_machine.release_lock()
                self._send_partinfo_to_display()

    def send_FX(self):
        print("chain: {}\nctrl_val: {}".format(self.tonality.chain, self.tonality.ctrl_val))
        self.osculator_client.send_message('/rack', self.tonality.chain[0])
        self.osculator_client.send_message('/control{}'.format(self.tonality.chain[1]),  self.tonality.ctrl_val)

    def send_quittung(self, note, velo, dura):
        self.osculator_client.send_message('/quittung', (note, velo, 1.0))
        time.sleep(dura)
        self.osculator_client.send_message('/quittung', (note, velo, 0.0))


    def _send_part(self, counter):
        next_part = self.beat_manager.next_part if self.beat_manager.is_warning() else self.beat_manager.current_part

        if self.beat_manager.check_is_one_of_state(BeatAdvanceManager.STATE_WARNING):
            self.osculator_client.send_message(settings.SONG_ADVANCE_ADDRESS, (int(next_part.note), 1.0))
            self.osculator_client.send_message(settings.SONG_ADVANCE_ADDRESS, (int(next_part.note), 0.0))

        message = (counter, str(self.beat_manager.is_warning()), self.beat_manager.current_part.name, next_part.name)
        # print('SongerServer. sending: ', message)
        self.display_client.send_message(settings.SONG_BEAT_ADDRESS, message)

    def _send_utterance_to_display(self, input_dict):
        print(self.song_machine.category_counter, isinstance(self.song_machine.category_counter, dict))
        input_dict['category_counter'] = self.song_machine.category_counter
        input_dict['is_locked'] = self.song_machine.is_locked()

        content = pickle.dumps(input_dict, protocol=2)
        self.display_client.send_message(settings.DISPLAY_UTTERANCE_ADDRESS, content)

    def _send_partinfo_to_display(self):
        self.display_client.send_message(settings.DISPLAY_PARTINFO_ADDRESS,
                                         pickle.dumps(self.song_machine.current_state.get_targets(), protocol=2)
                                         )

    def _send_init_to_display(self):
        self.display_client.send_message(settings.DISPLAY_INIT_ADDRESS,
                                         pickle.dumps(self.song_machine.parser.categories, protocol=2)
                                         )

class Tonality:
    '''
    idea of tonality counter combined with rules for FX chains and Sample Triggering in
    Ableton Live
    '''

    tonality_counter = Counter()
    FX_KEY = 'Clean'
    ctrl_val = 0
    last_cats = []
    last_value = 0
    most_common = ''
    tonality_lock = False

    category_to_chain = {
        # every category points to a FX Chain and a ctrl value
        'praise': ['Delay', 5],
        'lecture': ['Vocoder', 8],
        'insinuation': ['FreqShift', -7],
        'dissence': ['Distortion', -5],
        'concession': ['Delay', 2]
    }
    chain_controls = {
        # every chain has a chain_value, a ccnr and a standard ctrl_value
        'FreqShift' : [15, 10, 65],
        'Vocoder': [32, 15, 95],
        'Distortion': [60, 20, 25],
        'Delay': [90, 25, 65],
        'Clean': [115, 0, 0]
    }

    def __init__(self, categories):
        # self.tonality_counter = {categories[i]: 0 for i in range(len(categories))}
        self.tonality_counter = Counter(categories)
        self.chain = self.chain_controls[self.FX_KEY]

    def update_tonality(self, cat):
        # print("tonalities: ", self.tonality_counter)
        self.tonality_counter[cat] += 1
        self.calculate_rack_values(cat)

    def calculate_rack_values(self, cat):
        '''
        1. after 10 utterances, the most_common category defines the FX chain
        2. only if all other categories have had at least had 5 updates (self.last_cats), a new FX_kEY is
        generated by the most_common category at that moment
        3. the self.ctrl_value is calculated as a deviation from a standard value defined in self.chain_controls
        '''
        #  an FX chain is selected, if more than 10 entries have occured
        if sum(self.tonality_counter.values()) > 10:
            # print("cat {}   locked?: {} most common: {}".format(cat, self.tonality_lock, self.most_common))
            if not self.tonality_lock:
                self.most_common = [x for x,_ in self.tonality_counter.most_common(1)]
                self.most_common = self.most_common[0]
                # print("most common: ", self.most_common)
                self.FX_KEY = self.category_to_chain[self.most_common][0]
                self.tonality_lock = True
            if cat not in self.last_cats and self.tonality_counter[cat] % settings.CHAIN_DURATION == 0:
                self.last_cats.append(cat)
            elif len(self.last_cats) == len(self.tonality_counter):
                print("\t RESET FX")
                self.tonality_lock = False
                self.last_cats = []
        self.chain = self.chain_controls[self.FX_KEY]
        self.last_value = self.chain[2]
        self.ctrl_val = self.last_value + self.category_to_chain[cat][1]
        # print("self.chain: {} self.ctrl_val: {}". format(self.chain, self.ctrl_val))
        return self.chain, self.ctrl_val