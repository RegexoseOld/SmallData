
import argparse
import time
import threading
import logging
import pickle
import collections

from pythonosc import dispatcher
from pythonosc import osc_server

from MusicObjects import Noten, Chords
from PlayObjects import Play, To_Client_Thread, Play_Thread, play_dict, slotlist, playmap, PLAYTHREADS
from Manipulate import Manipulate
from UDPClient import Client_MusicServer, START


logging.basicConfig(level = logging.DEBUG, format = '(%(threadName)-10s) %(message)s',)
COND1 = threading.Condition()
COND2 = threading.Condition()
COND3 = threading.Condition()

TRACKS = ['synth01', 'synth02', 'synth03', 'synth04', 'synth05', 'synth06', 'synth07', 'synth08', 'master']
FADER = ['vol', 'send1', 'send2', 'plug1', 'plug2', 'plug3' ]
DEFAULT = [0.1, 0.5]
TRIGGERMAP = {
    'songstart' : 0,
    'intro': [i for i in range(1,9)],
    'main': [i for i in range(9,17)],
    'special': [i for i in range(17,23)],
    'end': [i for i in range(23,26)]

}


def dict_values(tracks, fader):
    addresses = []
    LIVE_VALUES2 = collections.OrderedDict()
    for i in range(len(tracks)):
        for j in range(len(fader)):
            addresses.append('/{}/{}'.format(tracks[i], fader[j]))
    LIVE_VALUES2 = {addresses[k] : 0.5 for k in range(len(addresses))}
    return LIVE_VALUES2

LIVE_VALUES = dict_values(TRACKS, FADER)

class Live:
    def __init__(self, client, manipulate, message, cond):
        self.client = client
        self.cond = cond
        self.manipulate = manipulate
        self.message = message
        self.position = 108
        self.templist = [time.time()]
        self.beatlist = []
        self.subbeatlist = []
        self.tempo = 0.5
        self.pre = 0
        self.slot = ['/trig_master', 0]
        #self.send2live(message)

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
                self.manipulate.function_dispatch(user, address, point, cl_map)
                print('\tmelo edit: taktstart: ', self.position)

        elif address == '/buildmap':
            user = cl_map['user']
            del cl_map['user']
            # print('\n\tclientmap: {}, user: {}, address: {}\n'.format(cl_map, username, address))
            self.manipulate.function_dispatch(user, address, 'akk_01', cl_map)
            # with self.client.cond:
            #     self.client.cond.wait()
            #     print('\tnew notes taktstart: ', self.beat)
            #     self.edit.function_dispatch(user, address, 'point', track, cl_map)

        elif address =='/controlmap':
            user = cl_map['user']
            repeat = cl_map['repeat']
            del cl_map['user']
            del cl_map['repeat']
            self.manipulate.function_dispatch(user, address, cl_map)
            PLAYTHREADS['t1'].playmap_check(repeat)

    def message_handler(self, address, msg):
        cl_map = pickle.loads(msg) # das dict vom client
        print('Message Handler: {} address: {}'.format(cl_map, address))

        if address.startswith("/trig"):
            with self.client.cond:
                self.client.cond.wait()
                print('trig? :', cl_map['trigger'])
                #self.client.control_send(message[0], int(message[1])) # dynamische Adresse - im Moment zu viel
                self.send2live([cl_map[0], cl_map[1]])

        elif address == '/controlmap':
                user = cl_map['user']
                del cl_map['user']
                self.manipulate.function_dispatch(user, address, cl_map)
        #
        # elif isinstance(cl_map[''], float) and len(cl_map) >= 3:
        #     live_value = LIVE_VALUES[cl_map[0]]
        #     # print('live_value ', live_value)
        #     if cl_map[1] < 0 and live_value >= 0:
        #         print('Werte subtrahiert: {} - {} = {}'.format(round(live_value, 3), round(cl_map[1], 3),
        #                                                         (round(live_value, 3) + round(cl_map[1], 3))))
        #         self.client.control_send(cl_map[0], (round(live_value, 3) + round(cl_map[1], 3)))
        #         LIVE_VALUES[cl_map[0]] = round(live_value, 3) + round(cl_map[1], 3)
        #
        #     elif cl_map[1] > 0 and live_value <= 1:
        #         print('Werte addiert: {} + {} = {}'.format(round(live_value, 3), round(cl_map[1], 3),
        #                                                      (round(live_value, 3) + round(cl_map[1], 3))))
        #         self.client.control_send(cl_map[0], (round(live_value, 3) + round(cl_map[1], 3)))
        #         LIVE_VALUES[cl_map[0]] = round(live_value, 3) + round(cl_map[1], 3)

        elif cl_map[0] == '/start':
            self.manipulate.function_dispatch(cl_map[1], cl_map[0], {'dummy': 'dummy1'})

        else:
            LIVE_VALUES[cl_map[0]] = cl_map[1]
            print('type message: ', type(cl_map[1]))
            self.client.control_send(cl_map[0], int(cl_map[1]))

    def tiempo(self, list):
        if len(list) == 2:
            return list[1] - list[0]
        elif len(self.templist) >= 3:
            return sum((list[i+1] - list[i]) for i in range(len(list) -1) ) / (len(list) -1)

    def gaps(self, list):
        if len(list) < 2:
            return 'waiting for beats..'
        else:
            return (list[1] - list[0])

    def calibrate(self, msg):
        message = pickle.loads(msg)

        self.client.calibrate(message[0], message[1])


    def osculator_handler(self, address, pos, value):
        #print('Handler: address: {} pos: {} value: {} '.format(address, pos, value))

        if address not in ['/pitch_beat', '/slot_end', '/slot_start', '/oscul_beat', '/oscul_subbeat']:
            LIVE_VALUES['/midi/cc7/{}'.format(pos)][1] = value
            print('Live Values', LIVE_VALUES)

        elif address == '/pitch_beat' and value == 1:
            self.position = pos
            self.templist.append(time.time())
            #print('position: {}  tempo: {}'.format(self.position, self.tempo))
            self.tempo = self.tiempo(self.templist)
            self.manipulate.P_Obj = PLAYTHREADS['t1'].P_Obj
            self.manipulate.P_Obj.set_tempo(self.tempo * 4)

            if self.position == 115:
                #self.pre += 1
                print('\t taktstart: ', self.position)
                #print('609 live.tempo: ', self.tempo)

            self.templist = [time.time()]

        elif address == '/slot_start' and value == 1:
            pass
            #print('slot start at: ', time.time())
            # with self.cond:
            #     PLAYTHREADS['t1'].trigger = False
            #     self.cond.notify_all()

        elif address == '/slot_end' and value == 1:
            print('slot end at: ', (time.time() - START))
            with self.cond:
                PLAYTHREADS['t1'].trigger = True
                self.cond.notify_all()

        elif address == "/oscul_beat":
            self.beatlist.append((time.time() - START))
            if len(self.beatlist) > 2:
                self.beatlist.pop(0)
            #print('beat value: {} time: {}\n'.format(value, self.gaps(self.beatlist)))

        elif address == "/oscul_subbeat":
            if len(self.subbeatlist) > 2:
                self.subbeatlist.pop(0)

            self.subbeatlist.append((time.time() - START))
            #print('subbeat value: {} time: {}\n'.format(value,  self.gaps(self.subbeatlist)))

    def send2live(self, msg):
        print('Message send2live: {}'.format(msg))
        self.client.init_send(msg[0], [msg[1], 1.0])
        time.sleep(0.1)
        self.client.init_send(msg[0], [msg[1], 0.0])


def mainloop(server, osculator, playmap):
    print('\n \t !!!!!!!!\n')
    manipulate.set_playmap(playmap)
    t1 = Play_Thread('play_init', playmap, play_init, osculator, COND2, COND3)
    tcl = To_Client_Thread('for_interface', server_instance_client, COND3)
    PLAYTHREADS['t1'] = t1
    PLAYTHREADS['tcl'] = tcl
    #print('playthreads mainloop', PLAYTHREADS)
    tcl.start()
    t1.start()
    print('server: ',server.server_address)
    #print('active count: ', threading.active_count(), threading.enumerate(), ' \n')
    server.serve_forever()

if __name__ == "__main__":

    dispatcher = dispatcher.Dispatcher()
    ips = {'gitsche' : "192.168.1.123", 'skali': '192.168.178.44', 'sv': '192.168.178.189', 'local': '127.0.0.1',
           'rasp': '192.168.1.91'}

    parser = argparse.ArgumentParser()
    parser.add_argument("--ip",
                       default=ips['local'], help="The ip to listen on")

    parser.add_argument("--port",
                        type=int, default=5000, help="The port to listen on")
    args = parser.parse_args()
    print('ip: {}  port: {}'.format(ips[args.ip], args.port))
    server = osc_server.ThreadingOSCUDPServer((ips[args.ip], args.port), dispatcher)
    # print('server: ', server.server_address)

    server_instance_client = Client_MusicServer(ips[args.ip], 5010, COND1)
    '''
    Diese Instanz dient der Kommunkation zum Text-Client. Momentan nur für
    die Übermittlung der aktuell gespielten Melodie
    '''

    osculator_instance = Client_MusicServer(ips[args.ip], 5015, COND1)
    oscu_tempo = Client_MusicServer(ips[args.ip], 5020, COND1)

    '''
    Diese Instanz ist der UDP Server zu Osculator (und LIVE)
    COND1 wird für das messaging der Taktanfänge benutzt
    '''

    chords_0 = Chords('chords_0', [0],[[64, 68]], [80], [14], [0], [[21]], [[0.0]])

    play_init = play_dict['slot1']

    manipulate = Manipulate(chords_0, play_init, COND2, osculator_instance)
    live = Live(osculator_instance, manipulate, ["/trig_master", 1], COND2)

    '''muss ganz oben stehen, sonst versteht der server die dispatcher adressen nicht'''

    dispatcher.map("/buildmap", lambda address, map: live.melo_handler(address, map))
    dispatcher.map("/controlmap", lambda address, map: live.message_handler(address, map))
    dispatcher.map("/melo_edit", lambda address, map: live.melo_handler(address, map))
    dispatcher.map("/message", lambda address, msg: live.connection(msg))
    dispatcher.map("/calibrate", lambda address, msg: live.calibrate(msg))
    dispatcher.map("/trigger", lambda address, msg: live.message_handler(address, msg))
    dispatcher.map("/start", lambda address, map: live.message_handler(address, map))

    dispatcher.map("/oscul_beat", lambda address, track, value: live.osculator_handler(address, track, value))
    dispatcher.map("/oscul_subbeat", lambda address, track, value: live.osculator_handler(address, track, value))
    dispatcher.map("/oscul_vol", lambda address, track, value: live.osculator_handler(address, track, value))
    dispatcher.map("/pitch_beat", lambda address, track, value: live.osculator_handler(address, track, value))
    dispatcher.map("/slot_start", lambda address, track, value: live.osculator_handler(address, track, value))
    dispatcher.map("/slot_end", lambda address, track, value: live.osculator_handler(address, track, value))

    def stop():
        print('STOP')
        time.sleep(0.5)
        live.client.trigger_address('/stop', 0)


    try:
        mainloop(server, osculator_instance, playmap)

    except KeyboardInterrupt:
        stop()

