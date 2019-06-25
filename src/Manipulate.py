import copy

from rules import normal_values
from PlayObjects import PLAYTHREADS, generate_playmap, Play_Thread

RULES = {
    'half': 0.5,
    'default':37,
    '=': 0,
    '+1': 1,
    '+2': 2,
    '+3': 3,
    '+4': 4,
    '+6': 6,
    '+10': 10,
    '+11': 11,
    'double':2,
    '4x': 4,
    'viertel': 0.25,
    '-1': -1,
    '-2': -2,
    '-4':-4,
    '-5': -5,
    '-7': -7,
    'slower': -2,
    'faster': 2
}

class Manipulate:
    def __init__(self, Noten_objekt, Play_object, condition, client):
        self.N_Obj = Noten_objekt
        self.P_Obj = Play_object
        self.Copy_Obj = copy.deepcopy(self.N_Obj)
        self.playmap = {}
        self.user = self.N_Obj.name
        self.userlist = []
        self.replist = list(self.playmap.values())
        self.cond2 = condition
        self.client = client
        self.songposition = 0
        self.point = ""
        self.user_count = 1

    def __repr__(self):
        return '(edit {})'.format(self.Copy_Obj)

    def set_playmap(self, playmap):
        self.playmap = playmap

    def function_dispatch(self, user, address, client_map):

        if address == '/controlmap':
            print('\tcontrolmap')
            self.update_controllers(client_map)
            #print('new values', self.N_Obj.vel, self.P_Obj.wheel, self.P_Obj.ccnr,  self.P_Obj.ccval)

        elif address == '/start':
            self.new_Thread(user, client_map)

    def update_controllers(self, cl_map):
        print('cl_map ', cl_map)

        coarse = cl_map['coarse']
        trigger = cl_map['trigger']
        wheel = cl_map['wheel']
        cc_map = cl_map['cc_dict']
        threadPlay = PLAYTHREADS['t1'].P_Obj
        playthread = PLAYTHREADS['t1']
        playthread.play = True

        if cc_map == 'normal_values':
            # print('normvals: ', normal_values)
            PLAYTHREADS['t1'].send_ccvals(normal_values)
            threadPlay.cc_map = normal_values
        else:
            print('else: ', threadPlay.cc_map == normal_values)
            playthread.send_ccvals(cc_map)
            threadPlay.cc_map = cc_map

        threadPlay.wheel = wheel
        if coarse in ['half', 'double', 'viertel', '4x']:
            threadPlay.coarse *= RULES[coarse]
        elif coarse in ['slower', 'faster']:
            threadPlay.coarse += RULES[coarse]
        elif coarse == 'default':
            threadPlay.coarse = RULES[coarse]

        ruletrigger = RULES[trigger]
        position = playthread.slot
        self.songposition = copy.deepcopy(position)
        print('aktuelle position {} self.songposition: {} ruletrigger: {}'.format(position, self.songposition, ruletrigger))

        if (position + RULES[trigger]) >= 25:
            print('position  {} + RULES[trigger]: {} = {}'.format(position, RULES[trigger], (position + RULES[trigger])))
            playthread.slot = 25
            playthread.jump(25)
            playthread.send_ccvals(normal_values)

        elif trigger in [ "+1", "-1", "+2", "-2", '-5', '-7', '+3', '+4', '+6','+10', '+11']:
            slot = playthread.slot + RULES[trigger]
            playthread.play = False
            playthread.jump(slot)
            playthread.slot = slot
            playthread.send_ccvals(normal_values)
            playthread.cond_set(slot)
            print('genullt?: ', playthread.ccmap == normal_values)

        elif trigger == '=':
            playthread.slot += RULES[trigger]

        elif trigger in ["-1", "-2"] and position == 0:
            playthread.slot = 0

        self.P_Obj = threadPlay

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
            self.playmap = generate_playmap([1, 1, 1, 1, 2, 2], [0, 1, 2, 3, 4, 5])
            t1 = PLAYTHREADS['t1']
            t1.play = False  # bisheriger Playthread wird angehalten
            t2 = Play_Thread(user, self.playmap, self.client, self.cond2)
            t2.start()
            t1.join()  # t1 wird beendet
            print('Playmap 153: ', t2.playmap)
            print('thread: {} t1.play {}, alive? {} '.format(t1.name, t1.play,
                                                             t1.is_alive()))  # Abfrage ob t1 auch wirklich tot ist
            del PLAYTHREADS['t1']
            PLAYTHREADS['t1'] = t2

        else:
            self.userlist.append(user)
            self.playmap = generate_playmap([1, 1, 1, 1, 2, 2], [0, 1, 2, 3, 4, 5])
            t1 = PLAYTHREADS['t1']
            t1.play = False  # bisheriger Playthread wird angehalten
            t2 = Play_Thread(user, self.playmap, self.client, self.cond2)
            t2.start()
            t1.join()
            # print('thread: {} t1.play {}, alive? {} t2.play {} '.format(t1.name, t1.play,
            #                                                             t1.is_alive(), t2.play))
            PLAYTHREADS.pop('t1')
            PLAYTHREADS['t1'] = t2
            print('Playthreads 255: ', PLAYTHREADS)
