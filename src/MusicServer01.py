
import argparse
import time
import threading
import logging
import pickle
import random
import collections

import copy
from itertools import *
from collections import Counter

from pythonosc import osc_message_builder # für client aufgaben?
from pythonosc import udp_client
from pythonosc.udp_client import SimpleUDPClient

from pythonosc import dispatcher
from pythonosc import osc_server
from arp import Arp
from osc_server05 import Noten, Chords, Counter

logging.basicConfig(level =logging.DEBUG, format = '(%(threadName)-10s) %(message)s',)
PLAYOBJECTS = [] # ist wahrscheinlich zu unspezifisch
NOTEOBJECTS = [] # ist wahrscheinlich zu unspezifisch
noteobject_dict = collections.OrderedDict()
play_dict = collections.OrderedDict()
init = []
AKTUELL =['irgendein Startwert muss hier rein']
PLAYTHREADS = collections.OrderedDict()
COND1 = threading.Condition()
COND2 = threading.Condition()
COND3 = threading.Condition()
RL = threading.RLock()
playmap = collections.OrderedDict()

TRACKS = ['synth01', 'synth02', 'synth03', 'synth04', 'synth05', 'synth06', 'synth07', 'synth08', 'master']
FADER =['vol', 'send1', 'send2', 'plug1', 'plug2', 'plug3' ]
DEFAULT = [0.1, 0.5]

melo01 = [52, 57, 60, 60, 59, 58, 57, 57, 59, 60, 60, 54, 57, 60, 59, 59, 52]
velo01 = [110, 100, 100, 110, 105, 100, 95, 105, 100, 100, 110, 100, 105, 105, 100, 110, 100]

chords1 = [[60, 66], [56, 60, 68], [60, 66], [56, 64]]
tm_ch1 = [2, 2, 2, 2]
chords2 = [[64, 69], [64, 70], [62, 69], [64, 69], [64, 70], [62, 69]]
tm_ch2 = [1, 1, 1, 1, 1, 1, 1]
chords3 = [[56, 64], [56, 64], [56, 64], [56, 64]]
tm_ch3 = [1.5, 0.5, 1, 1]
chords4 = [[60, 64], [66, 69], [66, 70], [66, 69], [66, 72], [66, 69], [63, 66], [64, 68]]
tm_ch4 = [1, 1, 1, 1, 0.5, 0.5, 1, 1]
chords5 = [[60, 66], [60, 64], [64, 68], [66, 68], [66, 69], [63, 69], [66, 72], [60, 71], [64, 68]]
tm_ch5 = [1, 1, 1, 0.5, 0.5, 1, 1, 0.5, 0.5]

# play_dict[play_init] = play_init

def chord_objects(nr, chords):
    timings = [tm_ch1, tm_ch2, tm_ch3, tm_ch4, tm_ch5]
    chord_object = Chords('chords_{}'.format(nr), [i for i in range(len(chords))],
                          chords,
                          [110 for i in range(len(chords))],
                          timings[(nr - 1)],
                          [0 for i in range(len(chords))],
                          [[21, 24, 33, 34, 35] for i in range(len(chords))],
                          [[0.0, 0.8, 0.9, 0.0, 0.0] for i in range(len(chords))])
    return chord_object


def dict_values(tracks, fader):
    addresses = []
    LIVE_VALUES2 = collections.OrderedDict()
    for i in range(len(tracks)):
        for j in range(len(fader)):
            addresses.append('/{}/{}'.format(tracks[i], fader[j]))
    LIVE_VALUES2 = {addresses[k] : 0.5 for k in range(len(addresses))}
    return LIVE_VALUES2

LIVE_VALUES = dict_values(TRACKS, FADER)

# print('LIVE_VALUES 48: ', LIVE_VALUES)

def ChangeMonitor(cls):
    _sentinel = object()
    old_setattr = getattr(cls, '__setattr__', None)
    def __setattr__(self, name, value):
        old = getattr(self, name, _sentinel)
        if not old is _sentinel and old != value:
            print ("Old {0} = {1!r}, new {0} = {2!r}".format(name, old, value))
        if old_setattr:
            old_setattr(self, name, value)
        else:
            # Old-style class
            self.__dict__[name] = value

    cls.__setattr__ = __setattr__

    return cls

# @ChangeMonitor
class Play(object):
    def __init__(self, notenObj):
        self.notenObj = notenObj
        self.pos = self.notenObj.noteId[0]
        self.tempo = self.notenObj.tempo
        self.arp = Arp(len(self.notenObj.notes),1)
        self.chord = 1
        self.track = 1
        self.wheel = 0
        self.ccnr = [21, 12, 33, 34, 35]
        self.ccval = [0.0, 0.6, 0.9, 0.0, 0.0]
        play_dict['{}'.format(self.notenObj.name)] = self

    def __repr__(self):
        return "'Play_{}'".format(self.notenObj)

    def arp_edit(self, richtung):
        self.arp.richtung(richtung)
        print(self.arp.richt)

    def track_change(self, Oscu_client, track):
        # print('69 track? ', self.track)
        if self.track != track:
            Oscu_client.track_send(track, 1)
            Oscu_client.track_send(track, 1)
            Oscu_client.track_send(self.track, 1)
            Oscu_client.track_send(self.track, 1)
            self.track = track
        else:
            pass
        # print('78 track? ', self.track)

    def set_tempo(self, tempo):
        #print('playdict.notObj: ', id(play_dict['akk_01']))
        #print('self.tempo {}  change to  {} '.format(self.tempo, tempo))
        self.tempo = tempo

        #print('114 notenobjekt.pause: ', self.notenObj.pause)

    def play_loop(self, Oscu_client):
        #print('Chord? {}, self.N_Obj {}'.format(self.chord, self.notenObj))
        if self.chord == 0:
            for pos in self.arp:
                self.pos = pos
                # print('self.pos = ', self.pos)
                self.msgplay(Oscu_client)
        else:
            for pos in self.arp:
                self.pos = pos
                self.akkord_play(Oscu_client)
        #self.track_change(Oscu_client, track)


    def msgplay(self, oscul_client):
        note = self.notenObj.getNote(self.pos)
        # print('self.pos: {}, note:  {}'.format(self.pos, note))
        # wheel = self.notenObj.getPitchwheel(self.pos)
        ctrlnr= self.notenObj.getCtrlnr(self.pos)
        ccval = self.notenObj.getCCval(self.pos)
        velo= self.notenObj.getVEL(self.pos)
        self.tempo = self.notenObj.getPause(self.pos)
        # print('tempo play: ', self.tempo)
        oscul_client.msg_send(note, velo, 1.0)
        oscul_client.control_send(ctrlnr, ccval)
        # oscul_client.trigger_send(1.0)
        time.sleep(self.tempo)
        oscul_client.msg_send(note, velo, 0.0)

    def akkord_play(self, oscul_client):
        self.notenObj.tempo_change(self.tempo)
        chord = self.notenObj.getNote(self.pos)
        vel = self.notenObj.getVEL(self.pos)
        tm = self.notenObj.getPause(self.pos)
        wheel = self.notenObj.getWheel(self.pos)
        ctrlnr = self.notenObj.getCtrlnr(self.pos)
        ccval = self.notenObj.getCCval(self.pos)
        #print('notenobjekt.pause: ', self.notenObj.pause)
        #print('self.tempo: ', self.tempo)
        #print('chord: {}, time: {}'.format(chord, time.time()))
        #print('ccnr {}, ccval: {}, wheel: {}'.format(self.ccnr, self.ccval, self.wheel))
        for n in range(len(chord)):
            oscul_client.akk_send(chord[n], n, vel, 1.0)
            oscul_client.wheel_send(self.wheel)
        for c, v in zip(self.ccnr, self.ccval):
            oscul_client.control_send(c, v)
        time.sleep(tm)
        for n in range(len(chord)):
            oscul_client.akk_send(chord[n], n, vel, 0.0)

class Edit:
    def __init__(self, Noten_objekt, Play_object, client):
        self.N_Obj = Noten_objekt
        self.P_Obj = Play_object
        self.Copy_Obj = copy.deepcopy(self.N_Obj)
        self.playmap = {}
        self.user = self.N_Obj.name
        self.userlist = []
        self.replist = list(self.playmap.values())
        self.client = client
        self.point = ""
        self.user_count = 1

    def __repr__(self):
        return '(edit {})'.format(self.Copy_Obj)

    def set_playmap(self, playmap):
        self.playmap = playmap

    def function_dispatch(self, user, address, client_map):

        if address == '/buildmap':
            print('\tbuildmap')
            print('Playthreads: ', PLAYTHREADS)
            self.user = user
            self.new_Thread(user, client_map)

            # self.addThread(user, track, client_map)

        elif address == '/controlmap':
            print('\tcontrolmap')
            #print('playdict: ', play_dict)
            self.update_controllers(client_map)


            print('new values', self.N_Obj.vel, self.P_Obj.wheel, self.P_Obj.ccnr,  self.P_Obj.ccval)

        elif address == '/melo_edit':
            pointy = play_dict[point]
            self.playmap.pop(pointy, None)
            self.replist = list(self.playmap.values())
            # print('self.playmap nach del', self.playmap)
            del play_dict[point]
            self.new_Thread(user, client_map)

        elif address == '/start':
            self.new_Thread(user, client_map)

    def update_controllers(self, cl_map):
        values = list(cl_map.values())
        print('206 values', values)
        velo = values[0][0]
        wheel = values[0][1]
        ccval = values[0][3]

        self.P_Obj = PLAYTHREADS['t1'].P_Obj
        print('edit. play obj: ', self.P_Obj)

        self.P_Obj.wheel = wheel
        self.P_Obj.ccval = ccval

    def new_Thread(self, user, cl_map):
        noteIds = list(cl_map.keys())
        values = list(cl_map.values())
        notes = [i[0] for i in values]
        vel = [i[1] for i in values]
        ccnr = [i[3] for i in values]
        ccval = [i[4] for i in values]
        #print('notes 157: ', notes)
        dummy = [0 for i in range(len(values))]
        tm = [i[2] for i in values]
        if user in self.userlist:
            print('User exists!! ')
            self.playmap = repeat_play([1, 1, 1, 1, 2, 2], [0, 1, 2, 3, 4, 5])
            t1 = PLAYTHREADS['t1']
            t1.play = False  # bisheriger Playthread wird angehalten
            t2 = Play_Thread(user, self.playmap, self.client, COND2)
            t2.start()
            t1.join()  # t1 wird beendet
            print('Playmap 153: ', t2.playmap)
            print('thread: {} t1.play {}, alive? {} '.format(t1.name, t1.play,
                                                             t1.is_alive()))  # Abfrage ob t1 auch wirklich tot ist
            del PLAYTHREADS['t1']
            PLAYTHREADS['t1'] = t2

        else:
            self.userlist.append(user)
            self.playmap = repeat_play([1,1,1,1,2,2],[0,1,2,3,4,5])
            t1 = PLAYTHREADS['t1']
            t1.play = False  # bisheriger Playthread wird angehalten
            t2 = Play_Thread(user, self.playmap, self.client, COND2)
            t2.start()
            t1.join()
            # print('thread: {} t1.play {}, alive? {} t2.play {} '.format(t1.name, t1.play,
            #                                                             t1.is_alive(), t2.play))
            PLAYTHREADS.pop('t1')
            PLAYTHREADS['t1'] = t2
            print('Playthreads 255: ', PLAYTHREADS)

    def setWheelmap(self, map, point):
        logging.debug('setWheelmap: ')
        self.pointer(point)  # welches Notenobjekt
        map = list(map.values())
        print('map setwheel: {}, point: {}'.format(map, self.Copy_Obj))
        self.Copy_Obj.pitchwheel = map

    def osc_cc(self, list):
        logging.debug('set_cc: ')
        self.change = list
        while len(self.change) < len(self.Copy_Obj.ccval):
            list.append(0)
        print('vorher: ', self.Copy_Obj.ccval)
        print('self.change: ', self.change)
        new_ccval = []
        for i  in zip(enumerate(self.Copy_Obj.ccval), self.change):
            print(i[0][1] + i[1])
            new_ccval.append(i[0][1] + i[1])

        self.Copy_Obj.ccval = new_ccval
        print('nachher: ', self.Copy_Obj.ccval)

    def pointer(self, point):
        #print('point: {} , noteobject_dict: {}'.format(point, noteobject_dict))
        obj = noteobject_dict[point]
        self.Copy_Obj = obj
        #print('pointer Obj: ',obj)

class To_Client_Thread(threading.Thread):
    '''
    To_Client Thread teilt dem client (mit COND2) bei jeder gespielten melo mit, welche melo gerade gespielt wird.
    '''
    def __init__(self, name, client, cond=COND2):
        threading.Thread.__init__(self)
        self.name = name
        self.client = client
        self.cond = cond
        self.P_Obj = None
        self.repeat = 0
        self.send = True

    def __repr__(self):
        return '(To_TextClient_Thread {})'.format(self.name)

    def run(self):
        logging.debug('run TextClient')
        while True: ## hilft das, bei der Aktualisierung der Melo?
            with self.cond:
                self.cond.wait()
                #print('Condition 292 ', self.cond)
                # print('P_Obj: {}, repeat  {}'.format(self.P_Obj, self.repeat))
                self.client.feedback_for_client(self.P_Obj, self.repeat)

# @ChangeMonitor
class Play_Thread(threading.Thread):
    ''' 
          der Playthread durchläuft die playzuteilung der Playmap - z.B. melo1:3x spielen etc
          jede melo beinhaltet die Listen für Notenwerte, Velocity etc und diese Werte werden in
          der Play Instanz (als osc_messages an port 5015) gesendet
          '''
    def __init__(self, name, playmap, client, cond=COND2):
        threading.Thread.__init__(self)
        self.name = name
        self.cond = cond
        self.client = client
        self.playmap = playmap
        self.P_Obj = play_init
        self.play = True
        self.slot = 0
        self.repeat = 1
        self.trigger = False

    def __repr__(self):
        return '(Play_Thread {})'.format(self.name)

    def cond_set(self, play, repeat):
        # print('315 cond2', COND2)
        with self.cond:
            del AKTUELL[0]
            AKTUELL.append(play)
            PLAYTHREADS['tcl'].repeat = repeat
            PLAYTHREADS['tcl'].P_Obj = play
            #print('397 cond2 {}  play  :{}'.format(self.cond, play))
            self.cond.notify()
    def playmap_check(self, repeat):
        print('repeat: ', repeat)
        self.repeat = repeat

    def run(self):
        logging.debug('run Play_Thread')

        playmap_keys = [i for i in self.playmap.keys()]
        del playmap_keys[0]
        print('keys 382: {}'.format(playmap_keys))
        while self.play == True:
            for play in playmap_keys:
                self.P_Obj = play
                #self.repeat = self.playmap[play][0]
                self.slot = self.playmap[play][1]
                print('318 key {} play slot {}, repeat {}'.format(play, self.slot, self.repeat))
                self.cond_set(play, self.repeat)
                self.client.trigger_address('/trig_master', self.slot)

                with self.cond:
                    self.cond.wait()
                    if self.trigger:
                        print('playmap 394: {}'.format(self.playmap))
                        for r in range(self.repeat):
                            print('393 r: {} melo: {} time: {}'.format(r, play, time.time()))
                            play.play_loop(self.client)
                    else:
                        print('self.trigger 426', self.trigger)
                        #break

class ClientIO(SimpleUDPClient):

    def __init__(self, ip, port, cond):
        super(ClientIO, self).__init__(ip, port)
        self.port = port
        self.ip =ip
        self.cond = cond
        self.trig = cycle([0.4, 0.6])

    def __repr__(self):
        return '(Client Port {})'.format(self.port)

    def feedback_for_client(self, P_Obj, repeat):
        N_Obj = P_Obj.notenObj
        dict_to_send = {N_Obj : repeat}
        uptodate = pickle.dumps(dict_to_send)
        self.send_message("/feedback01", uptodate)
        # with self.cond: # ist jetzt COND1, damit die listbox nur einen wert bekommt
        #     self.cond.wait()
        #     # print('AKTUELL name {} notes {} vel {}'.format(note_obj.name, note_obj.notes, note_obj.vel ))
        #     self.send_message("/feedback01", uptodate)


    def msg_send(self, note, velo, trig):
        self.send_message("/osc_notes", [note, velo, trig])

    def track_send(self, track, val):
        self.send_message("/arm{}".format(track), val)

    def akk_send(self, note, voice, vel, trig):
        list = [note, voice, vel, trig]
        # print('akk send values: {}'.format([type(list[n]) for n in range(len(list))]))
        # print('akk send values:', list)
        self.send_message("/chord", [note, voice, vel, trig])

    def control_send(self, channel, crtlnr, val):
        self.send_message("/ch{}_cc{}".format(channel, crtlnr), val)

    def wheel_send(self, wheel):
        self.send_message("/wheel", wheel)

    def trigger_send(self, trig):
        # trig = self.trig.__next__()
        self.send_message("/trigger", trig)

    def trigger_address(self, address, trig):
        print('message trigger address: {}, {} time: {}'.format(address, trig,time.time()))
        self.send_message("{}".format(address), [trig, 1.0])
        self.send_message("{}".format(address), [trig, 0.0])

    def solo_send(self, address, val):
    # print('solo address: {}'.format(address))
        self.send_message('{}'.format(address), val)

    def init_send(self, address, val):
        print('init send address  {}  msg {}'.format(address, val))
        self.send_message("{}".format(address), val)

class Live:
    def __init__(self, client, edit, message, cond):
        self.client = client
        self.cond = cond
        self.edit = edit
        self.message = message
        self.position = 108
        self.templist = [time.time()]
        self.tempo = 0.5
        self.pre = 0
        self.slot = ['/trig_master', 0]
        self.send2live(message)

    def connection(self, msg):
        print("Connection!!  ", msg)

    def melo_handler(self, address, map):
        cl_map = pickle.loads(map)
        print('Melo Handler: address: {}  cl_map {}'.format(address, cl_map))

        if address == '/melo_edit':
            user = cl_map['user']
            # point = '(Noten Object {})'.format(cl_map['point'])
            point = cl_map['point']
            del cl_map['user']
            del cl_map['point']
            with self.client.cond:
                self.client.cond.wait() # wartet auf den taktstart der eigenen COND1 ..?
                self.edit.function_dispatch(user, address, point, cl_map)
                print('\tmelo edit: taktstart: ', self.position)

        elif address == '/buildmap':
            user = cl_map['user']
            del cl_map['user']
            # print('\n\tclientmap: {}, user: {}, address: {}\n'.format(cl_map, username, address))
            self.edit.function_dispatch(user, address, 'akk_01', cl_map)
            # with self.client.cond:
            #     self.client.cond.wait()
            #     print('\tnew notes taktstart: ', self.beat)
            #     self.edit.function_dispatch(user, address, 'point', track, cl_map)

        elif address =='/controlmap':
            user = cl_map['user']
            repeat = cl_map['repeat']
            del cl_map['user']
            del cl_map['repeat']
            self.edit.function_dispatch(user, address, cl_map)
            PLAYTHREADS['t1'].playmap_check(repeat)

    def message_handler(self, address, msg):
        message = pickle.loads(msg)
        print('Message Handler: {} address: {}'.format(message, address))

        if address.startswith("/trig"):
            with self.client.cond:
                self.client.cond.wait()
                print('trig? :', message[1])
                #self.client.control_send(message[0], int(message[1])) # dynamische Adresse - im Moment zu viel
                self.send2live([message[0], message[1]])

        elif isinstance(message[1], float) and len(message) >= 3:
            live_value = LIVE_VALUES[message[0]]
            # print('live_value ', live_value)
            if message[1] < 0 and live_value >= 0:
                print('Werte subtrahiert: {} - {} = {}'.format(round(live_value, 3), round(message[1], 3),
                                                                (round(live_value, 3) + round(message[1], 3))))
                self.client.control_send(message[0], (round(live_value, 3) + round(message[1], 3)))
                LIVE_VALUES[message[0]] = round(live_value, 3) + round(message[1], 3)

            elif message[1] > 0 and live_value <= 1:
                print('Werte addiert: {} + {} = {}'.format(round(live_value, 3), round(message[1], 3),
                                                             (round(live_value, 3) + round(message[1], 3))))
                self.client.control_send(message[0], (round(live_value, 3) + round(message[1], 3)))
                LIVE_VALUES[message[0]] = round(live_value, 3) + round(message[1], 3)

        elif address == '/calibrate':
            self.client.control_send(message[0], message[1])

        elif message[0] == '/start':
            self.edit.function_dispatch(message[1], message[0],  {'dummy': 'dummy1'} )

        else:
            LIVE_VALUES[message[0]] = message[1]
            print('type message: ', type(message[1]))
            self.client.control_send(message[0], int(message[1]))

    def tiempo(self):
        if len(self.templist) == 2:
            self.tempo = self.templist[1] - self.templist[0]
        elif len(self.templist) >= 3:
            #self.tempo = sum((self.templist[i+1] - self.templist[i]) for i in range(len(self.templist) -1)) / (len(self.templist) -1))
            self.tempo = sum((self.templist[i+1] - self.templist[i]) for i in range(len(self.templist) -1) ) / (len(self.templist) -1)


    def osculator_handler(self, address, pos, value):
        # print('Handler: address: {} track: {} value1: {} '.format(address, pos, value))

        if address not in ['/pitch_beat', '/slot_change']:
            LIVE_VALUES['/midi/cc7/{}'.format(pos)][1] = value
            print('Live Values', LIVE_VALUES)

        elif address == '/pitch_beat' and value == 1:
            self.position = pos
            self.templist.append(time.time())
            #print('position: {}  tempo: {}'.format(self.position, self.tempo))
            self.tiempo()
            self.edit.P_Obj = PLAYTHREADS['t1'].P_Obj
            self.edit.P_Obj.set_tempo(self.tempo * 4)

            if self.position == 115:
                #self.pre += 1
                print('\t taktstart: ', self.position)
                #print('609 live.tempo: ', self.tempo)

            self.templist = [time.time()]

        elif address == '/slot_change':
            print('slot change at: ', time.time())
            with self.cond:
                PLAYTHREADS['t1'].trigger = True
                self.cond.notify_all()

    def send2live(self, msg):
        print('Message send2live: {}'.format(msg))
        self.client.init_send(msg[0], [msg[1], 1.0])
        time.sleep(0.1)
        self.client.init_send(msg[0], [msg[1], 0.0])

def repeat_play(replist, slots):
    # print('len keys {} len replist {}'.format(len(play_dict.keys()), len(replist)))
    if len(replist) < len(play_dict.keys()):
        rest = len(play_dict.keys()) - len(replist)
        append_rest = [1] * rest
        replist.extend(append_rest)

    play_items = list(play_dict.values())
    print('play_items: ', play_items)
    playmap = collections.OrderedDict((play_items[k],[replist[k], slots[k]]) for k in range(len(play_items)))
    #print('playmap 496: ', playmap)
    return playmap

def mainloop(server, osculator, playmap):
    print('\n \t !!!!!!!!\n')
    edit.set_playmap(playmap)
    t1 = Play_Thread('play_init', playmap, osculator, COND2)
    tcl = To_Client_Thread('for_interface', server_instance_client, COND2)
    PLAYTHREADS['t1'] = t1
    PLAYTHREADS['tcl'] = tcl
    print('playthreads mainloop', PLAYTHREADS)
    t1.start()
    tcl.start()
    print('server: ',server.server_address)
    #print('active count: ', threading.active_count(), threading.enumerate(), ' \n')
    server.serve_forever()

if __name__ == "__main__":

    dispatcher = dispatcher.Dispatcher()
    ips = {'gitsche' : "192.168.1.90", 'skali': '192.168.178.44', 'sv': '192.168.178.189', 'local': '127.0.0.1',
           'rasp': '192.168.1.91'}

    parser = argparse.ArgumentParser()
    parser.add_argument("--ip",
                       default="192.168.1.44", help="The ip to listen on")
    # parser.add_argument("--ip",
    #       default="127.0.0.1", help="The ip to listen on")
    parser.add_argument("--port",
                        type=int, default=5005, help="The port to listen on")
    args = parser.parse_args()
    server = osc_server.ThreadingOSCUDPServer((ips[args.ip], args.port), dispatcher)

    server_instance_client = ClientIO(ips['rasp'], 5010, COND1)
    '''
    Diese Instanz dient der Kommunkation zum Text-Client. Momentan nur für
    die Übermittlung der aktuell gespielten Melodie
    '''

    osculator_instance = ClientIO(ips[args.ip], 5015, COND1)
    '''
    Diese Instanz ist der UDP Server zu Osculator (und LIVE)
    COND1 wird für das messaging der Taktanfänge benutzt
    '''

    for i in range(1,6):
        #osculator_instance.control_send('16', i, 55)
        pass

    chords_0 = Chords('chords_0', [0],
                      [[64, 68]],
                      [80],
                      [14],
                      [0],
                      [[21, 12, 33, 34, 35]],
                      [[0.0, 0.7, 0.9, 0.0, 0.0]])

    noteobject_dict['chords_0'] = chords_0
    play_init = Play(chords_0)

    for i, j in zip(range(1, 6), [chords1, chords2, chords3, chords4, chords5]):
        obj = chord_objects(i, j)
        play = Play(obj)
        # print('obj: {}, obj.name {}'. format(obj, obj.name))
        noteobject_dict[i] = obj

    edit = Edit(chords_0, play_init, osculator_instance)
    live = Live(osculator_instance, edit, ["/trig_master", 0], COND2)

    '''muss ganz oben stehen, sonst versteht der server die dispatcher adressen nicht'''

    dispatcher.map("/buildmap", lambda address, map: live.melo_handler(address, map))
    dispatcher.map("/controlmap", lambda address, map: live.melo_handler(address, map))
    dispatcher.map("/melo_edit", lambda address, map: live.melo_handler(address, map))
    dispatcher.map("/message", lambda address, msg: live.connection(msg))
    dispatcher.map("/calibrate", lambda address, msg: live.message_handler(address, msg))
    dispatcher.map("/trigger", lambda address, msg: live.message_handler(msg))
    dispatcher.map("/start", lambda address, map: live.message_handler(map))

    dispatcher.map("/oscul_vol", lambda address, track, value: live.osculator_handler(address, track, value))
    dispatcher.map("/pitch_beat", lambda address, track, value: live.osculator_handler(address, track, value))
    dispatcher.map("/slot_change", lambda address, track, value: live.osculator_handler(address, track, value))

    def stop():
        print('STOP')
        time.sleep(0.5)
        live.client.trigger_address('/stop', 0)

    try:
        mainloop(server, osculator_instance, {play_dict['chords_0'] : [[1],[0]]})

    except KeyboardInterrupt:
        pass
        # stop()

