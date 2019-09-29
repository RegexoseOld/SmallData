import time
from pythonosc.udp_client import SimpleUDPClient
from itertools import *
import time
from datetime import datetime

DATETIME = datetime(2019, 6, 20, 20, 15, 30, 11111)
START = time.mktime(DATETIME.timetuple()) + DATETIME.microsecond / 1E6

class ClientIO(SimpleUDPClient):
    def __init__(self, ip, port):
        super(ClientIO, self).__init__(ip, port)
        self.send_msg('\tClientIO Connection!! ip {}  port {}'.format(ip, port))
        print('Client Connection: {} port {}'.format(ip, port))

    def send_msg(self, msg):
        self.send_message("/message", msg)

    def send_trigger(self, msg):
        self.send_message("/trigger", msg)

    def calibrate(self, msg):
        self.send_message("/calibrate", msg)

    def send_buildmap(self, map):
        self.send_message("/buildmap", map)

    def melo_edit(self, map):
        self.send_message("/melo_edit", map)

    def send_controlmap(self, map):
        self.send_message("/controlmap", map)

    def send_start(self, msg):
        self.send_message("/start", msg)


class Client_MusicServer(SimpleUDPClient):
    def __init__(self, ip, port, cond):
        super(Client_MusicServer, self).__init__(ip, port)
        self.port = port
        self.ip =ip
        self.cond = cond
        self.trig = cycle([0.0, 1.0])

    def __repr__(self):
        return '(Client Port {})'.format(self.port)

    def feedback_for_client(self, slot):
        self.send_message("/feedback01", slot)

    def msg_send(self, note, velo, trig):
        self.send_message("/osc_notes", [note, velo, trig])

    def track_send(self, track, val):
        self.send_message("/arm{}".format(track), val)

    def akk_send(self, note, voice, vel, trig):
        list = [note, voice, vel, trig]
        # print('akk send values: {}'.format([type(list[n]) for n in range(len(list))]))
        # print('akk send values:', list)
        self.send_message("/chord", list)

    def control_send(self, channel, crtlnr, val):
        # print('control_send  chan: {}, ccnr: {} val: {}, \ntime: {}'.format(channel, crtlnr, val,  (time.time() - START)))
        self.send_message("/{}_cc{}".format(channel, crtlnr), val)

    def wheel_send(self, wheel):
        self.send_message("/wheel", wheel)

    def trigger_send(self, trig):
        # trig = self.trig.__next__()
        self.send_message("/trigger", trig)

    def trigger_address(self, address, trig):
        print('message trigger address: {}, {} time: {}'.format(address, trig, (time.time() - START)))
        # self.send_message("{}".format(address), trig)
        self.send_message("{}".format(address), [trig, 1.0])
        self.send_message("{}".format(address), [trig, 0.0])

    def calibrate(self, address, val):
        print('client calibrate: {}, {}'.format(address, type(int(val))))
        self.send_message("{}".format(address), [int(val), 1.0])
        self.send_message("{}".format(address), [int(val), 0.0])

    def tempo_coarse(self, coarse):
        print('coarse: {}'.format(int(coarse)))
        self.send_message("/tempo_coarse", int(coarse))

    def mute_send(self, channel, ccnr, val):
        print('mute send: {}'.format(ccnr))
        if val == 0:
            self.send_message('{}_cc{}'.format(channel, ccnr), 0)
            self.send_message('{}_{}'.format(channel, ccnr), 0)
        else:
            self.send_message('{}_cc{}'.format(channel, ccnr), 127)

    def solo_send(self, channel, ccnr, val):
        print('solo send: {}'.format(ccnr))
        self.send_message('{}_{}'.format(channel, ccnr), val)
        self.send_message('{}_{}'.format(channel, ccnr), val)

    def init_send(self, address, val):
        print('init send address  {}  msg {}'.format(address, val))
        self.send_message("{}".format(address), val)