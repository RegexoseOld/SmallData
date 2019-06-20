"""Small example OSC server

This program listens to several addresses, and prints some information about
received packets.

NEU: threaded server und client kommunizieren miteinander.
point geht jetzt direkt über melonamen.

"""
import argparse
import re
import time
import threading
import random
import logging
import pickle

import copy
from itertools import *

from pythonosc import osc_message_builder # für client aufgaben?
from pythonosc import udp_client
from pythonosc.udp_client import SimpleUDPClient

from pythonosc import dispatcher
from pythonosc import osc_server
from arp import Arp

logging.basicConfig(level =logging.DEBUG, format = '(%(threadName)-10s) %(message)s',)
PLAYOBJECTS = []
NOTEOBJECTS = []
noteobject_dict = {}
init = []
AKTUELL =['irgendein Startwert muss hier rein']
PLAYTHREADS = []
CONDITION = threading.Condition()
COND2 = threading.Condition()
stat_cond = threading.Condition()
# OUTPORT = mido.open_output('IAC Bus1')

INTERVALLE = {'kl_sek': (-1, 1),
              'gr_sek': (-2, 2),
              'kl_terz': (-3, 3),
              'gr_terz': (-4, 4),
              'quarte': (-5, 5),
              'triton': (-6, 6),
              'quinte': (-7, 7),
              'kl_sexte': (-8, 8),
              'gr_sexte': (-9, 9),
              'kl_septime': (-10, 10),
              'gr_septime': (-11, 11),
              'oktave': (-12, 12)
              }

OKTAVEN = {'C,,,': [i for i in range(0,11)],
           'C,,': [i for i in range(12,23)],
           'C,': [i for i in range(24,25)],
           'C': [i for i in range(36,47)],
           "c": [i for i in range(48,59)],
           "c'": [i for i in range(60,71)],
           "c''": [i for i in range(72,83)],
           "c'''": [i for i in range(84,95)],
           "c''''": [i for i in range(96,107)],
           "c'''''": [i for i in range(108,119)],
           "c''''''": [i for i in range(120,127)]
           }



class MelDef:
    def __init__(self, anzahl, anfangsnote, wunsch, pause, wheel, ctrlnr, ccval):
        self.anzahl= anzahl
        self.tonart = Tonarten(self.anzahl)
        self.note = anfangsnote
        self.allowed = self.tonart.allowed_map(wunsch)
        self.pause = pause
        self.wheel = wheel
        self.ctrlnr = ctrlnr
        self.ccval = ccval
        self.folge(self.anzahl, self.pause, self.wheel, self.ctrlnr, self.ccval)

    def getWerte(self):
        return self.l_noteId, self.l_noten, self.l_pause, self.l_pw, self.l_ctrlnr, self.l_ccval

    def intervalls(self):
      i = 0
      while i <= self.anzahl:
          yield self.intervall
          u = random.randint(-10, 10)
          if self.intervall not in range(-8,8):
              self.intervall = 0
              self.intervall += u
          else:
              self.intervall += u
          i += 1

    def notenGenerator(self, allowed):
        i = 0
        keys = list(allowed.keys())
        values = list(allowed.values())
        pos = self.tonart.pos
        while i <= self.tonart.anzahl - 1:
            yield self.note
            # print('pos vor choice: ', pos)
            choice = random.choice(allowed[pos])
            # print('choice: {} pos_alt: {} '.format(choice, pos))
            self.note += choice
            for o, p in enumerate(values[pos], -7):
                # print('o, p ', o, p)
                if p == choice and p < 0:
                    #print('choice == ', o)
                    pos = (len(keys)) + o
                elif p == choice and p in range(0, 6):
                    #print('choice == ', o)
                    pos = o
            i += 1

            # print('choice: {} pos_neu: {} '.format(choice, pos))

    def folge(self, anzahl, pause=1, wheel=0, ctrlnr=1, ccval=0):
        noten = [i for i in self.notenGenerator(self.allowed)]
        Folge = {k: [noten[k], pause, wheel, ctrlnr, ccval] for k in range(anzahl)}
        melo1 = Folge
        self.l_noteId = [int(x+1) for x in melo1.keys()]
        dict_werte = melo1.values()
        werte = [[row[y] for row in dict_werte] for y in range(5)]
        self.l_noten = werte[0]
        self.l_pause = werte[1]
        self.l_pw = werte[2]
        self.l_ctrlnr = werte[3]
        self.l_ccval = werte[4]

class Play:
    def __init__(self, notenObj):
        self.notenObj = notenObj
        self.pos = self.notenObj.noteId[0]
        self.anzahl = len(self.notenObj.noteId)
        self.arp = Arp(len(self.notenObj.notes),1)
        playlist.append(self)

    def __repr__(self):
        return'(PlayObj {})'.format(self)

    def arp_edit(self, richtung):
        self.arp.richtung(richtung)
        print(self.arp.richt)

    # wird gerade nicht gebraucht
    def play_single(self):
        for i in self.arp:
            if i <= self.anzahl:
                self.pos = i
            self.msgplay()

    def play_loop(self, client):
        for pos in self.arp:
            self.pos = pos
            # print('i play melody',i)
            self.osc_play(client)

    def msgplay(self, client):

        with OUTPORT:
            note = self.notenObj.getNote(self.pos)
            # print('self.pos, note:',self.pos, note)
            wheel = self.notenObj.getPitchwheel(self.pos)
            ctrlnr= self.notenObj.getCtrlnr(self.pos)
            ccval = self.notenObj.getCCval(self.pos)
            t = self.notenObj.getPause(self.pos)
            # msg = mido.Message('note_on', note=note)
            # msg2 = mido.Message('pitchwheel', pitch=wheel)
            # msg3 = mido.Message('control_change', control=ctrlnr, value= ccval)
            client.msg_send(note)
            client.cc_send(ccval)
            client.trigger_send()
            # OUTPORT.send(msg)
            # OUTPORT.send(msg2)
            # OUTPORT.send(msg3)
            time.sleep(t)
            client.trigger_send()
            # msg = mido.Message('note_off', note=note)
            # OUTPORT.send(msg)
            # OUTPORT.panic()

    def osc_play(self, client):
        note = self.notenObj.getNote(self.pos)
        # print('self.pos, note:',self.pos, note)
        wheel = self.notenObj.getPitchwheel(self.pos)
        ctrlnr= self.notenObj.getCtrlnr(self.pos)
        ccval = self.notenObj.getCCval(self.pos)
        t = self.notenObj.getPause(self.pos)
        client.msg_send(note)
        client.cc_send(ccval)
        client.trigger_send()
        time.sleep(t)
        client.trigger_send()

class Edit:
    def __init__(self, Noten_objekt, cond):
        self.N_Obj = Noten_objekt
        self.Copy_Obj = copy.deepcopy(self.N_Obj)
        self.change = []
        self.cond = cond
        self.point = ""

    def __repr__(self):
        return '(edit {})'.format(self.Copy_Obj)

    def new_Object(self, name):
        '''
        neuer Tread wird addiert und überlagert den ersten LoopThread
        '''
        new_object = Noten(name, self.Copy_Obj.noteId, self.Copy_Obj.notes, self.Copy_Obj.ints, self.Copy_Obj.tm,
                           self.Copy_Obj.pitchwheel, self.Copy_Obj.controllernr, self.Copy_Obj.ccval)
        play = playlist[-1]
        print('das letzte element?', play)
        while play.pos != 0:
            pass
        del playlist[:]
        print('\n\t play.pos = 0, \tplaythreads', PLAYTHREADS)
        t1 = PLAYTHREADS[0]
        print(t1)
        t1.play = False
        print('t1.play? ',t1.play)
        logging.debug('t1 False')
        PLAYTHREADS.pop(0)
        Play(new_object)
        replist = [2]
        playmap = repeat_play(replist)
        t2 = LoopThread(name, playmap)
        PLAYTHREADS.append(t2)
        print('playlist mit t2', playlist)
        print('\n\t t2.start \n')
        t2.start()

        # for t in playthreads: # neue threads sollen immer erst auf der nächsten "eins" einsteigen quasi play.pos = 0
        #     print('joining...')
        #     if t is not threading.main_thread():
        #         t.join() #oder doch threading.Lock ?
        #         logging.debug('t.join: ')

    def setNote(self, address, id, pitch, point):
        # print('address: ', address)
        logging.debug('setNote: ')
        self.pointer(point) # welches Notenobjekt
        if id >= len(self.Copy_Obj.notes):
            id = id % len(self.Copy_Obj.notes) # wenn die noteId vom Client immer höher werden
        self.Copy_Obj.notes[id] = pitch
        counter.pitch_count(pitch)
        with self.cond:
            self.cond.notifyAll()
            print('active count: ', threading.active_count(), threading.enumerate(), ' \n')
            print('playlist setnote ', playlist)
            print('action count setnote: ', len(counter.actions))
        if counter.action_count() == 20:
            self.new_Object('melo =={}'.format(point))

    def setPause(self, id, pause, point = 1):
        self.Copy_Obj.tm[id] = pause
        self.new_Object('setPause')

    def setWheel(self, id, wheel, point):
        logging.debug('setWheel: ')
        self.pointer(point)  # welches Notenobjekt
        if id >= len(self.Copy_Obj.notes):
            id = id % len(self.Copy_Obj.notes)  # wenn die noteId vom Client immer höher werden
        self.Copy_Obj.pitchwheel[id] = wheel
        counter.wheel_count(wheel)

        with self.cond:
            self.cond.notifyAll()
        if counter.action_count() == 100:
            self.new_Object('melo =={}'.format(point))

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


    def setControl(self, id, control, ccval, point):
        self.Copy_Obj.controllernr[id] = control
        self.Copy_Obj.ccval[id] = ccval
        counter.wheel_count(1)
        self.new_Object('setControl')

    def insertNote(self, id, pitch, pause, point = 1):
        self.Copy_Obj.notes.insert(id, pitch)
        self.Copy_Obj.pitchwheel.insert(id, 0)
        self.Copy_Obj.controllernr.insert(id, 0)
        self.Copy_Obj.ccval.insert(id, 0)
        self.Copy_Obj.tm.insert(id, pause)
        self.Copy_Obj.noteId.append(len(self.Copy_Obj.notes))
        print(self.Copy_Obj.noteId, self.Copy_Obj.notes, self.Copy_Obj.tm, self.Copy_Obj.pitchwheel)
        self.new_Object('insertNote')

    def pointer(self, point):
        #print('point: {} , noteobject_dict: {}'.format(point, noteobject_dict))
        obj = noteobject_dict[point]
        self.Copy_Obj = obj
        #print('pointer Obj: ',obj)

    def new_notes(self, anzahl, note, intervall, pause, wheel, ctrlnr, ccval, playthreads):
        # aktuell.pop(0)
        meldef = MelDef(anzahl, note, intervall, pause, wheel, ctrlnr, ccval)
        werte = [i for i in meldef.getWerte()]
        self.Copy_Obj = Noten('newNotes',werte[0], werte[1], werte[2], werte[3], werte[4], werte[5], werte[6])
        self.new_Object()

    def reset(self, event, playthreads, point = 1):
        obj = NOTEOBJECTS[melo]
        self.Copy_Obj = obj
        self.new_Object('reset')

class EinwegThread(threading.Thread):
    def __init__(self, name, target, cond):
        threading.Thread.__init__(self)
        self.name = name
        self.target = target
        self.cond = cond
        self.play = True

    def __repr__(self):
        return '(EinwegThread {})'.format(self.name)

    def run(self):
        logging.debug('run Einweg {}'.format(self.name))
        with self.cond:
            self.cond.wait
            self.target.feedback_for_client()

class LoopThread(threading.Thread):
    def __init__(self, name, playmap, client, cond):
        threading.Thread.__init__(self)
        self.name = name
        self.cond = cond
        self.client = client
        self.playmap = playmap
        self.now_playing = playlist[0]
        self.play = True
        self.call = 0

    def __repr__(self):
        return '(LoopThread {})'.format(self.name)

    def run(self):
        logging.debug('run Loopthread ...')
        while self.play == True:
            for i in self.playmap.keys():
                AKTUELL.pop(0)
                v = self.playmap.get(i)
                with self.cond:
                    play_index = playlist.index(i)
                    self.now_playing = playlist[play_index]
                    aktual_note_object = self.now_playing.notenObj
                    AKTUELL.append(aktual_note_object)
                    self.cond.notifyAll()
                for _ in range(v):
                    target = i
                    self.call += 1
                    if self.play == True:
                        target.play_loop(self.client)
                    else:
                        break

class Counter:
    def __init__(self):
        self.actions = []
        self.pitch = []
        self.wheel = []

    def __repr__(self):
        return '(count {})'.format(self.actions)

    def action_count(self):
        return len(self.actions)

    def pitch_count(self, pitch):
        self.pitch.append(pitch)
        self.action_count()

    def wheel_count(self, wheel):
        self.wheel.append(wheel)
        self.action_count()

class ClientIO(SimpleUDPClient):

    def __init__(self, ip, port, cond):
        super(ClientIO, self).__init__(ip, port)
        self.port = port
        self.cond = cond
        self.trig = cycle([0.4, 0.6])

    def __repr__(self):
        return '(Client Port {})'.format(self.port)

    def feedback_for_client(self):
        while True:
            with self.cond:
                self.cond.wait()
                print('notified !!')
                print('Aktuell', AKTUELL)
                dict_to_send = {AKTUELL[0].name: AKTUELL[0].notes}
                uptodate = pickle.dumps(dict_to_send)
                self.send_message("/feedback01", uptodate)

    def msg_send(self, msg):
        self.send_message("/osc_notes", msg)

    def trigger_send(self):
        trig = self.trig.__next__()
        self.send_message("/trigger", trig)

    def cc_send(self, val):
        self.send_message("/cc", val)

def repeat_play(replist):
    if len(replist) < len(playlist): # falls mal nicht genügend angaben zur replist gemacht werden, werden
                                     # die restlichen werte auf 1 gesetzt
        rest = len(playlist) - len(replist)
        append_rest = [1] * rest
        replist.extend(append_rest)
        print('replist nach extend. ', replist)
    playmap = {playlist[k]:replist[k] for k in range(len(replist))}
    print('playmap: ', playmap)
    return playmap

def feedback_list(liste):
    list = pickle.loads(liste)
    print('list: {}'.format(list))
    edit.osc_cc(list)

def feedback_map(map):
    client_map = pickle.loads(map)
    print('map vom client', client_map)
    point = client_map['point']
    del client_map['point']
    edit.setWheelmap(client_map, point)

def mainloop(server, client):
    print('\n \t !!!!!!!!\n')
    p1 = Play(_melody1)
    p2 = Play(_melody2)
    p3 = Play(_melody3)
    replist = [2, 1, 2]
    playmap = repeat_play(replist)
    t1 = LoopThread('loop_init', playmap, client, CONDITION)
    t2 = EinwegThread('for_interface', client_instance_client, CONDITION)
    PLAYTHREADS.append(t1)
    PLAYTHREADS.append(t2)
    print('playthreads mainloop', PLAYTHREADS)
    t1.start()
    t2.start()
    print('active count: ', threading.active_count(), threading.enumerate(), ' \n')
    server.serve_forever()


if __name__ == "__main__":

    dispatcher = dispatcher.Dispatcher()

    parser = argparse.ArgumentParser()
    parser.add_argument("--ip",
                        default="127.0.0.1", help="The ip to listen on")
    # parser.add_argument("--ip",
    #      default="192.168.1.238", help="The ip to listen on")
    parser.add_argument("--port",
                        type=int, default=5005, help="The port to listen on")
    args = parser.parse_args()
    server = osc_server.ThreadingOSCUDPServer(
        (args.ip, args.port), dispatcher)


    parser2 = argparse.ArgumentParser()
    parser2.add_argument("--ip", default="127.0.0.1",
                         help="The ip of the OSC server")
    # parser2.add_argument("--ip", default="192.168.1.80",
    #                    help="The ip of the OSC server")
    parser2.add_argument("--port", type=int, default=5010,
                         help="The port the OSC server is listening on")
    args2 = parser2.parse_args()

    client_instance_client = ClientIO(args2.ip, args2.port, CONDITION)
    client_instance_osc = ClientIO(args2.ip, 5015, CONDITION)

    meldef1 = MelDef(8, 48, 'dur', 0.5, 0, 1, 0.2)
    meldef2 = MelDef(8, 60, 'moll', 0.3, 0, 1, 0.3)
    meldef3 = MelDef(8, 57, 'dur', 0.4, 0, 1, 0.4)
    werte1 = [i for i in meldef1.getWerte()]
    werte2 = [i for i in meldef2.getWerte()]
    werte3 = [i for i in meldef3.getWerte()]
    _melody1 = Noten('_melo1', werte1[0], werte1[1], werte1[2], werte1[3], werte1[4], werte1[5])
    _melody2 = Noten('_melo2', werte2[0], werte2[1], werte2[2], werte2[3], werte2[4], werte2[5])
    _melody3 = Noten('_melo3', werte3[0], werte3[1], werte3[2], werte3[3], werte3[4], werte3[5])

    edit = Edit(NOTEOBJECTS[0], CONDITION)
    counter = Counter()

    '''muss ganz oben stehen, sonst versteht der server die dispatcher adressen nicht'''

    dispatcher.map("/change_pitch1", lambda address, id, pitch, point: edit.setNote(address, id, pitch, point))
    dispatcher.map("/change_wheel", lambda address, id, wheel, point: edit.setWheel(id, wheel, point))
    dispatcher.map("/wheelmap", lambda address, map: feedback_map(map))
    dispatcher.map("/pitchmap", lambda address, map: feedback_map(map))
    dispatcher.map("/cclist", lambda address, list: feedback_list(list))
    dispatcher.map("/point", lambda address, point: edit.pointer(point))

    dispatcher.map("/reset", lambda address, event: edit.reset(event, PLAYTHREADS))
    dispatcher.map("/insert", lambda address, id, pitch, pause: edit.insertNote(id, pitch, pause))
    dispatcher.map("/pause", lambda address, id, pause: edit.setPause(id, pause))
    dispatcher.map("/richtung", lambda address, richt: playlist[0].arp_edit(richt))
    dispatcher.map("/newNotes", lambda address, anzahl, note, intervall, pause, wheel,
                                       ctrlnr, ccval: edit.new_notes(anzahl, note, intervall, pause, wheel, ctrlnr,
                                                                     ccval,
                                                                     PLAYTHREADS))




    try:
        mainloop(server, client_instance_osc)

    except KeyboardInterrupt:
        OUTPORT.panic()
        print('outport.panic')


