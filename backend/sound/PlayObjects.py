import threading
import time
import logging
import collections

from .arp import Arp
from .MusicObjects import make_note_objects, noteobject_dict
from .rules import normal_values

logging.basicConfig(level = logging.DEBUG, format = '(%(threadName)-10s) %(message)s',)

play_dict = collections.OrderedDict()
PLAYTHREADS = collections.OrderedDict()
COND1 = threading.Condition()
COND2 = threading.Condition()
COND3 = threading.Condition()


class Play(object):
    def __init__(self, notenObj):
        self.notenObj = notenObj
        self.pos = self.notenObj.noteId[0]
        self.tempo = self.notenObj.tempo
        self.arp = Arp(len(self.notenObj.notes),1)
        self.chord = 1
        self.track = 1
        self.wheel = 0
        self.coarse = 37
        self.cc_map = {}
        #print('id play self: ', id(self))
        # play_dict['{}'.format(self.notenObj.name)] = self

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
        # print('playdict.notObj: ', id(play_dict['akk_01']))
        # print('self.tempo {}  change to  {} '.format(self.tempo, tempo))
        self.tempo = tempo

        #print('114 notenobjekt.pause: ', self.notenObj.pause)

    def play_loop(self, Oscu_client):
        # print('Chord? {}, self.N_Obj {}'.format(self.chord, self.notenObj))
        if self.chord == 0:
            for pos in self.arp:
                self.pos = pos
                # print('self.pos = ', self.pos)
                self.msgplay(Oscu_client)
        else:
            for pos in self.arp:
                self.pos = pos
                self.akkord_play(Oscu_client)
        # self.track_change(Oscu_client, track)

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
        # print('notenobjekt.pause: ', self.notenObj.pause)
        # print('self.tempo: ', self.tempo)
        # print('chord: {}, time: {}'.format(chord, time.time()))
        # print('ccnr {}, ccval: {}, wheel: {}'.format(self.ccnr, self.ccval, self.wheel))
        for n in range(len(chord)):
            oscul_client.akk_send(chord[n], n, vel, 1.0)
            oscul_client.wheel_send(self.wheel)
        for c, v in zip(self.ccnr, self.ccval):
            oscul_client.control_send(c, v)
        time.sleep(tm)
        for n in range(len(chord)):
            oscul_client.akk_send(chord[n], n, vel, 0.0)


class To_Client_Thread(threading.Thread):
    """
    To_Client Thread teilt dem client (mit COND2) bei jeder gespielten melo mit, welche melo gerade gespielt wird.
    """
    def __init__(self, name, client, cond):
        threading.Thread.__init__(self)
        self.name = name
        self.client = client
        self.cond = cond
        self.P_Obj = None
        self.slot = 1
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
                self.client.feedback_for_client(self.slot)


class Play_Thread(threading.Thread):
    """
    der Playthread durchläuft die playzuteilung der Playmap - z.B. melo1:3x spielen etc
    jede melo beinhaltet die Listen für Notenwerte, Velocity etc und diese Werte werden in
    der Play Instanz (als osc_messages an port 5015) gesendet
    """
    def __init__(self, name, playmap, pObj, client, cond2, cond3):
        threading.Thread.__init__(self)
        self.name = name
        self.cond2 = cond2
        self.cond3 = cond3
        self.client = client
        self.playmap = playmap
        self.P_Obj = pObj
        self.ccmap = self.P_Obj.cc_map
        self.play = True
        self.slot = 1
        self.repeat = 1
        self.trig = 0
        self.part_end = True

    def __repr__(self):
        return '(Play_Thread {})'.format(self.name)

    def cond_set(self, slot):
        # print('315 cond2', COND2)
        with self.cond3:
            PLAYTHREADS['tcl'].slot = slot
            # print('397 cond2 {}  play  :{}'.format(self.cond, play))
            self.cond3.notify()

    def send_ccvals(self, cc_map):
        channels = [c for c in cc_map.keys()]
        # self.client.control_send('channel_8', 9, 0.6)
        for c in channels:
            dict_list = cc_map[c]
            ccnrs = [list(d.keys()) for d in dict_list]
            ccvals = [list(d.values()) for d in dict_list]

            # print('channels: {}\n ccnrs: {}\n ccvals: {}'.format(channels, ccnrs, ccvals))
            for nr, val in zip(ccnrs, ccvals):
                # print('chan: {}, ccnr: {}, ccval: {}'.format(c, nr, val))
                if nr[0] == 7:
                    # self.client.solo_send(c, nr[0], 1.0)
                    pass

                else:
                    self.client.control_send(c, nr[0], val[0])

    def playmap_check(self, repeat):
        print('repeat: ', repeat)
        self.repeat = repeat

    def jump(self, slot):
        self.client.trigger_address('/trig_master', slot)

    def run(self):
        logging.debug('run Play_Thread')
        triggerlist = list(play_dict.values())
        self.send_ccvals(self.ccmap)

        while self.play == True:

            play = triggerlist[self.trig]
            self.P_Obj = play
            cc_map = play.cc_map
            # self.slot = self.playmap[play][1]
            print('run slot: ', self.slot)

            self.client.trigger_address('/trig_master', self.slot)
            self.client.tempo_coarse(play.coarse)

            self.cond_set(self.slot)

            with self.cond2:
                self.cond2.wait()
                print('nächste Runde')

            if self.slot == 25:
                self.client.trigger_address('/trig_master', 25)
                self.play = False
                print('self.play? {} alive?: {}'.format(self.play, self.is_alive()))
                return


        print('alive?: ', self.is_alive())


def make_slots(slotlist):
    for slot in range(len(slotlist)):
        note_obj = make_note_objects(slot, [1])
        play = Play(note_obj)
        play.cc_map = normal_values
        name = 'slot{}'.format(slot)
        play_dict[name] = play


slotlist = [x for x in range(1, 26)]
make_slots(slotlist)


def generate_playmap(playitems, replist, slots):
    if len(replist) < len(playitems):
        rest = len(playitems) - len(replist)
        append_rest = [1] * rest
        replist.extend(append_rest)
    playmap = collections.OrderedDict((playitems[k],[replist[k], slots[k]]) for k in range(len(playitems)))
    return playmap


playmap = generate_playmap(list(play_dict.values()),[1 for i in range(len(slotlist))],slotlist)
