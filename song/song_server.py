import pickle
import json
from collections import Counter
import requests
import pyttsx3
from pythonosc.osc_server import ThreadingOSCUDPServer
from pythonosc.dispatcher import Dispatcher
from song.timer import RepeatTimer

from config import settings

def speak(words):
    engine = pyttsx3.init()
    volume = engine.getProperty('volume')
    engine.setProperty('volume', volume / 3)
    engine.say(words)
    engine.startLoop(True)


class BeatAdvanceManager:
    """ A simple state machine. Machine starts in 'normal' state. When the next part is changed,
    machine changes to 'prepare'. On the next '1' machine moves to 'warning', then on the next
    '1' back to 'normal' """
    STATE_NORMAL = 0
    STATE_PREPARE = 1
    STATE_WARNING = 2

    def __init__(self, first_part):
        self.state = self.STATE_NORMAL
        self.next_part = first_part
        self.current_part = first_part
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
                next_state = self.STATE_NORMAL
                if self.state == self.STATE_PREPARE:
                    next_state = self.STATE_WARNING
                elif self.state == self.STATE_WARNING:
                    self.current_part = self.next_part
                self.state = next_state
            return True

    def is_one_of_normal_state(self):
        return (self.__counter == '1') and (self.state == self.STATE_NORMAL)

    def is_warning(self):
        return self.state == self.STATE_WARNING


class SongServer:
    received_utts = 0
    timer = None
    timer_lock = False
    rack_fade_val = 0
    tonality_counter = Counter()

    def __init__(self, osculator_client, audience_client, performer_client, sc_client, machine, beat_manager,
                 server_ip):
        self.osculator_client = osculator_client
        self.audience_client = audience_client
        self.performer_client = performer_client
        self.sc_client = sc_client
        self.song_machine = machine
        self.beat_manager = beat_manager
        self.most_common = ''

        dispatcher = Dispatcher()
        dispatcher.map(settings.INTERPRETER_TARGET_ADDRESS, self.interpreter_handler)
        dispatcher.map(settings.SONG_BEAT_ADDRESS, self.beat_handler)
        # dispatcher.map(settings.SONG_SYNTH_RESET_ADDRESS, self.reset_handler)
        self.server = ThreadingOSCUDPServer((server_ip, settings.SONG_SERVER_PORT), dispatcher)

        self.song_scenes = {k: v for k, v in zip(
            self.song_machine.parser.song_parts,
            range(len(self.song_machine.parser.song_parts)
                  ))}

        self.sc_client.send_message('/init', ['rauschen', 1])
        # self.__send_state_to_backend()

    def interpreter_handler(self, _, content):
        self.received_utts += 1
        if self.song_machine.is_locked():
            print("machine locked")
        elif self.received_utts >= self.song_machine.parser.max_utterances:
            end_message = "Von  {} moeglichen Meinungen sind {} abgegeben worden" \
                .format(self.song_machine.parser.max_utterances, self.received_utts)
            self.end_of_song(end_message)
        else:
            print("utterances received: ", self.received_utts)

            osc_map = pickle.loads(content)
            osc_map['text'] = osc_map['text'].decode('utf-8')
            cat = osc_map['cat']

            speak(osc_map['text'])

            # Update tonality
            self.tonality_counter[cat] += 1
            temp_most_common = self.tonality_counter.most_common(1)[0][0]
            print("cat {}   most common: {} counter {}".format(cat, temp_most_common, self.tonality_counter))

            # Send Quittung
            current_part = self.beat_manager.current_part.name
            #  synth_note = self.song_machine.parser.song_parts[current_part].fb_note
            self.send_quittung(temp_most_common, cat, self.tonality_counter[cat])

            # Update part
            if self.song_machine.update_part(cat):
                self.beat_manager.update_next_part(self.song_machine.current_part)

            self._send_utterance(osc_map)


    def end_of_song(self, end_message):
        input_dict = {'text': end_message,
                      'cat': str(self.received_utts)}
        if self.received_utts == self.song_machine.parser.max_utterances:
            self._send_utterance(input_dict)

            self.song_machine.set_lock()
            self.osculator_client.send_message(settings.SONG_ADVANCE_ADDRESS, (settings.note_end, 1.0))
            self.osculator_client.send_message(settings.SONG_ADVANCE_ADDRESS, (settings.note_end, 0.0))

    def beat_handler(self, val, note):
        counter = settings.note_to_beat[note]
        # print('receiving beat', note)
        if self.beat_manager.update_beat_counter(counter):

            # update performer view (show counter and next part)
            self._send_part_info(counter, self.beat_manager.next_part)

            if self.beat_manager.is_one_of_normal_state() and self.song_machine.is_locked():
                self._advance_song(self.beat_manager.next_part)
                self.song_machine.release_lock()
                self._send_utterance({}, send_to_audience=False)  # resets the counter visuals

    def fade(self, val, increment):
        if self.rack_fade_val >= 0:
            self.rack_fade_val -= abs(val/increment)
            self.send_fx(self.rack_fade_val)
        else:
            self.timer.cancel()
            self.timer_lock = False
            # print("closing fader Thread", threading.enumerate())

    def send_fx(self, val):
        # print('fx sent: cc {}  value: {}'.format(self.tonality.chain[1], val))
        self.rack_fade_val = val
        self.osculator_client.send_message(settings.SONG_RACK_ADDRESS, self.tonality.chain_value)
        self.osculator_client.send_message(settings.SONG_MIDICC_ADDRESS + '{}'.format(self.tonality.ccnr),
                                           val)
        if not self.timer_lock:
            self.timer = RepeatTimer(0.5, self.fade, args=(val, 10,))
            self.timer.start()
            self.timer_lock = True

    def send_quittung(self, temp_most_common, cat,  count):
        print("sending quittung", [cat, count, temp_most_common])
        if self.most_common != temp_most_common:
            self.sc_client.send_message('/common', temp_most_common)
            self.most_common = temp_most_common
        self.sc_client.send_message('/{}'.format(cat), [cat, count])


    def _send_part_info(self, counter, next_part):
        message = (counter, str(self.beat_manager.is_warning()), self.beat_manager.current_part.name, next_part.name)
        # print('SongerServer. sending: ', message)
        self.performer_client.send_message(settings.SONG_BEAT_ADDRESS, message)
        if next_part.name != self.beat_manager.current_part.name:
            with open('frontend/public/assets/parts.json', 'w', encoding='utf-8') as f:
                json.dump([self.beat_manager.current_part.name, next_part.name], f, ensure_ascii=False)

    def _advance_song(self, next_part):
        print("next_part.note", next_part.note)
        self.osculator_client.send_message(settings.SONG_ADVANCE_ADDRESS, (int(next_part.note), 1.0))
        self.osculator_client.send_message(settings.SONG_ADVANCE_ADDRESS, (int(next_part.note), 0.0))
        # self.tonality.synth.reset_synth()

    def _send_utterance(self, input_dict, send_to_audience=True):
        state_data = self.__send_state_to_backend() # backend umgehen
        input_dict.update(state_data)

        data = json.dumps(input_dict)
        self.performer_client.send_message(settings.PERFORMER_COUNTER_ADDRESS, data)

        input_dict["kin"] = {"text": " dingens",
                             "cat": "praise"}
        data = json.dumps(input_dict)
        if send_to_audience:
            self.audience_client.send_message(settings.DISPLAY_UTTERANCE_ADDRESS, data)

    def _send_init_to_display(self):
        category_dict = {idx: i for idx, i in enumerate(self.song_machine.parser.categories)}
        data = {"max_utts": self.song_machine.parser.max_utterances,
                "categories": category_dict}
        data_init = json.dumps(data)
        self.audience_client.send_message(settings.DISPLAY_INIT_ADDRESS, data_init)
        # self.audience_client.send_message(settings.DISPLAY_PARTINFO_ADDRESS,
        # pickle.dumps(self.song_machine.current_part.get_targets(), protocol=2))

    def __send_state_to_backend(self):
        data = {'category_counter': self.song_machine.get_counter_for_visuals(),
                'is_locked': self.song_machine.is_locked()}

        #  Inform django-backend about changes
        requests.post('http://localhost:8000/api/song_state/',
                      data={},
                      json={"state": data}
                      )
        return data
