"""
perspektivisch: 1) pro kategorie ein Track/Synthsizer?
2) bei neuen Texten: a) in UserOrdner boris/Zustimmung.txt b) alle_user/Zustimmung.txt
vor allem die b) lösung wäre eine wachsende Datenbank, die zusätzlich zu meiner bisherigen TrainingData
(die ja letztlich eine Boris-Datenbank ist) hinzugezogen wird.

"""
import argparse
import pickle
import threading
import os
from collections import Mapping, namedtuple, Counter, defaultdict
from pathlib import Path
from copy import deepcopy
from pythonosc import osc_message_builder
from pythonosc.udp_client import SimpleUDPClient
from pythonosc import dispatcher
from pythonosc import osc_server
from itertools import *

from BasicClient03 import Interpreter, CATEGORY_NAMES, TextInput, TextOutput, Statistik1, TextEdit, ClientIO, CAT2VAL, START
from rules import RULES, INTENTS, INTENT_COUNT

from Classifier_max import Classifier
from DiskAdapter2 import DiskAdapter
import tkinter as tk
from PIL import Image, ImageTk

from statistics import median

ROOTDIR = '../'
STATSDIR = 'stats'
USER_NAMES = []
REF_LINES = []
INTENT2CC = {}

CAT_COUNT = namedtuple('CatCount', 'name, count')

def create_folder(song):
    path = os.path.join(ROOTDIR, STATSDIR, song)

    if not os.path.exists(path):
        os.makedirs(path)

    return path

def update_stats(song, user, cat, intent):
    folder = create_folder(song)
    path = os.path.join(folder, user + '.txt')
    with open(path, 'a') as f:
        f.write('{}|{}\n'.format(cat, intent))

def category_dict(name, channel, ccnr, ccval):
    cat_dict = {}
    sub_dicts = []

    for k in range(len(channel)):
        for v in range(len(ccnr[k])):
            #print('länge von ccnr: ', v)
            dict = {ccnr[k][v] : ccval[k][v]}
            sub_dicts.append(dict)

        cat_dict['channel_{}'.format(channel[k])] = sub_dicts
        sub_dicts = []
            #print('subdicts: ', sub_dicts)
    INTENT2CC[name] = cat_dict

    return cat_dict


class NoteObject:
    def __init__(self, noteobject):
        #print('32 noteobject.notes',noteobject.notes)
        return

class Feedback:
    def __init__(self, interpreter, client, interface, song):
        self.song = song
        self.interpreter = interpreter
        self.client = client
        self.textoutput = interface
        self.statistic = None
        self.textinput = None
        self.feedback = {} # ein dict mit den melos, die der server an self.dispatch sendet
        self.feedback_note_ids = []
        self.feedbackvals = []
        self.map = {}
        self.pitchvals = []
        self.pitchwheels = []
        self.tempo = 100
        self.timevals = []
        self.category = ''
        self.prob = 0
        self.actions = {k:[] for k in CATEGORY_NAMES}
        self.user = None
        self.stats = {}
        self.user2val = {}
        self.melo = ''
        self.repeat = 0

    def get_current_stats(self):
        '''
        computes stats for plots by reading stats files from stats directory
        :return: stats dict {category: [intent1, intent2, ....}
        '''

        folder = create_folder(self.song)
        stats = defaultdict(list)

        for item in Path(folder).iterdir():
            if item.is_file:
                user_action_dict = self.get_user_actions_from_file(item)
                for cat, intent_list in user_action_dict.items():
                    stats[cat].extend(intent_list)

        return stats


    def get_user_actions_from_file(self, filepath):
        action_dict = defaultdict(list)
        for line in Path(filepath).read_text().split('\n'):
            line = line.strip()
            if line and line != '':
                cat, intent = line.split('|')
                action_dict[cat].append(intent)
        return action_dict


    def job_count(self, user, intent, cat):
        if user != self.user:
            self.actions = {k:[] for k in CATEGORY_NAMES}
        elif cat == "Gaga":
            pass
        self.user = user
        self.actions[cat].append(intent)
        update_stats(self.song, user, cat, intent)
        # print('actions: ', self.actions)

        stats = self.get_current_stats()
        self.textoutput.plot_stats(stats)

    def bar_count(self, category, prob):
        if category in self.stats.keys():
            self.stats[category] += 1
        else:
            self.stats[category] = 1
        statistik_instance.window.bar_update(self.stats)

    def usertext_save(self, user, intent, text, reftext, cat, eigencat):
        with open('../UserEingaben/{}.txt'.format(user), 'a') as t:
            t.write('Ref: {} | Meinung: {} | intent: {} | Kat: {} | eigene Kat: {}\n'.format(reftext, text, intent, cat, eigencat))

    def adv_update(self, orig_dict, new_dict):
        for key, val in new_dict.items():
            # print('key {} val {}'.format(key, val))
            if isinstance(val, Mapping):
                print('update if1 - {} is Mapping!'.format(val))
                tmp = self.adv_update(orig_dict.get(key, {}), val)
                orig_dict[key] = tmp
            elif isinstance(val, list):
                print('update elif - {} is list!'.format(val))
                orig_dict[key] = (orig_dict.get(key, []) + val)
            else:
                print('update else')
                orig_dict[key] = new_dict[key]
        return orig_dict

    def val_update(self, cat, param, val):
        #print('{}!!!'.format(param))

        if len(self.user2val.keys()) == 0:
            # print('pickle exists? ', os.path.exists('../UserEingaben/USER2VAL.pkl'))
            try:
                with open('../UserEingaben/USER2VAL.pkl', 'rb') as f:
                    self.user2val = pickle.load(f)
                # print('User2VAL nach pickle load: ', self.user2val)

                if cat in self.user2val.keys() and param in self.user2val[cat].keys():
                    self.user2val[cat][param].append(val)

                elif cat in self.user2val.keys() and param not in self.user2val[cat].keys():
                    self.adv_update(self.user2val[cat], {param: [val]})
                else:
                    #print('else')
                    self.user2val[cat] = {param: [val]}

            except FileNotFoundError:
                self.user2val[cat] = {param: [val]}

        elif cat in self.user2val.keys() and param in self.user2val[cat].keys():
            # print('if1 USER2VAL.items', self.user2val.items())
            self.user2val[cat][param].append(val)
            #CAT2VAL[cat][param] = int(median(USER2VAL[cat][param]))
        elif cat in self.user2val.keys() and param not in self.user2val[cat].keys():
            # print('elif2 USER2VAL.items', self.user2val.items())
            self.adv_update(self.user2val[cat], {param: [val]})
        else:
            print('else')
            self.user2val[cat] =  {param: [val]}

        self.user2val[cat]['actions'] = self.actions[cat]

        # print('User2VAL vor pickle dump: ', self.user2val)

        self.check_user2val(cat, self.user2val)

        with open('../UserEingaben/USER2VAL.pkl', 'wb') as file:
            pickle.dump(self.user2val, file, pickle.HIGHEST_PROTOCOL)

    def check_user2val(self, user, dict):

        for param in dict[user]:
            # print('param', dict[cat][param])
            if (len(dict[user][param]) % 5) == 0:
                # print('\t UPDATE CAT2VAL {}, weil {} = {}\n'.format(user, dict[user][param], (len(dict[user][param]))))
                CAT2VAL[user] = deepcopy(self.user2val[user])
                del CAT2VAL[user]['actions']
                for param in CAT2VAL[user].keys():
                    value = CAT2VAL[user][param][0]
                    if isinstance(value, int):
                        CAT2VAL[user][param] = int(median(CAT2VAL[user][param]))
                    if isinstance(value, float):
                        CAT2VAL[user][param] = median(CAT2VAL[user][param])
                # self.update_classifier(user)
                for i in CAT2VAL.keys():
                    if i in self.user2val.keys():
                        print('{} : {} \n'.format(i, CAT2VAL[i]))

    def update_classifier(self, userfile):

        src = '../UserEingaben'
        dst = '../TrainingData'
        # shutil.copy2('{}/{}.txt'.format(src, userfile), '{}/{}.txt'.format(dst, userfile))

        texts, categories, names = DiskAdapter().get_training_data(CATEGORY_NAMES)
        classifier_instance = Classifier('../model_data')
        interpreter_instance = Interpreter(classifier_instance)
        feedback_instance = Feedback(interpreter_instance, client_instance, textinput_instance.window)
        textedit_instance = TextEdit(feedback_instance)
        textinput_instance.frames['TextInput'].set_textedit(textedit_instance)
        statistik_instance.frames['Statistik1'].set_feedback(feedback_instance)

        # print('feedback.interpreter.classifier: ', feedback_instance.interpreter.classifier)

    def reset(self):
        self.feedback = {}  # ein dict mit den melos, die der server an self.dispatch sendet
        self.feedback_note_ids = []
        self.feedbackvals = []
        self.map = {}
        self.dynamicvals = []
        self.pitchvals = []
        self.velovals = []
        self.pitchwheels = []
        self.ccnr = []

    def set_statistik(self, statistik):
        self.statistic = statistik
        # print('updated: ', id(self.textinput))

    def set_textinput(self,textinput):
        self.textinput = textinput

    def dispatch(self, slot):
        self.textoutput.update_pos(slot)

    def cat_rules(self, cat):
        count_user = len(self.actions[cat])
        print('count_user = {}  cat = {}'.format(count_user, cat))
        actual = CAT_COUNT(cat, count_user)
        fields = []
        for i in list(RULES.keys()):
            if i[0]== cat:
                fields.append(i)
        maxi = max([n.count for n in fields])
        # print('max: ', maxi)
        for i in fields:
            if actual == i:
                print('SAME! cat: {}  i.name: {}   i.count: {}\n'.format(cat, i.name, i.count))
                return RULES[i]
            elif count_user > maxi:
                rulecounts = [i.count for i in fields]
                divs = []
                while rulecounts:
                    # print('rulecounts:', rulecounts)
                    if (count_user % rulecounts[0]) == 0 and int(count_user / rulecounts[0]) in rulecounts:
                        divs.append(rulecounts[0])
                        # print('divs: {},  count/max: {}'.format(divs, int(count_user / max(divs))))
                        return RULES[CAT_COUNT(cat, int(count_user / max(divs)))]
                    rulecounts.pop(0)

                    if not rulecounts:
                        print('no match:')
                        return ['default', '=']

        else:
            print('else: keine Rule')
            return ['default', '=']

    def intent_rules(self, intent):
        int_count = Counter()
        intent_rules = [i.count for i in INTENTS.keys() if i.intent == intent]
        maxi = max(intent_rules)
        for vals in self.actions.values():
            int_count.update(vals)
        print(' int_count: {}  count: {}, maxi: {}'.format(int_count, int_count[intent], maxi))
        if int_count[intent] > maxi:
            new_count = (int_count[intent] % maxi)
            if new_count == 0:
                new_count = 4
            return INTENTS[INTENT_COUNT(intent, new_count)]
        return INTENTS[INTENT_COUNT(intent, int_count[intent])]

    def dict_comp(self, user, intent, text, reftext, eigencat):
        wheel, cat, prob = self.interpreter.text2wheel(text) # interpreter GAGA problem...
        self.job_count(user, intent, cat)
        if intent == 'neutral':
            cc_dict = 'normal_values'
        else:
            cc_dict = self.intent_rules(intent)

        if cat == 'Gaga':
            with open('../TrainingDataNew/Gaga.txt', 'a') as t:
                t.write(text +'\n')
            coarse, trigger = ['default', '=']
        else:
            coarse, trigger = self.cat_rules(cat)

        self.map = {'user': user, 'cc_dict': cc_dict, 'wheel': wheel, 'coarse': coarse,
                    'trigger': trigger}
        self.usertext_save(user, intent, text, reftext, cat, eigencat)
        self.textoutput.clastext_update(user, cat, prob, text)


    def controller_send(self):
        # for k in range(len(self.feedback_note_ids)):
        #     self.map[k] =  [self.velovals[k], self.pitchwheels[k], self.ccnr[k], self.ccvals[k]]

        print('299 buildmap vor pickle: ', self.map)
        # self.text_tracks_save(username, self.map)
        dict_to_send = pickle.dumps(self.map)
        self.client.send_controlmap(dict_to_send)



    def init_send(self, user):
        #print('simple msg: ', msg)
        map = pickle.dumps(['/start', user])
        self.client.send_start(map)

    def trig_send(self, msg):
        # address, cat, trig, prob, pitch = self.interpreter.text2trig(text, None)
        # # address2, cat2, trig2, prob2, pitch2 = self.interpreter.text2trig(text)
        # self.prob = prob
        # self.category = cat
        # self.interface.clastext_update(user, address, self.category, prob, text)
        # self.job_count(user, 'trig', cat)
        # self.val_update(user, 'trig', trig)
        message = pickle.dumps(["/trig_master", msg])
        self.client.send_trigger(message)

    def direct_send(self, ccnr, ccval):
        message = pickle.dumps([ccnr, ccval])
        self.client.calibrate(message)

class Interface(tk.Tk):
    def __init__(self, name, page,  *kwargs):
        tk.Tk.__init__(self, name, *kwargs)
        container = tk.Frame(self)
        # print('353 self: {}, container: {}'.format(type(self), type(container)))
        container.pack(side="top", fill="both", expand=True)

        container.grid_rowconfigure(0, weight=1)
        container.grid_columnconfigure(0, weight=1)
        container.master.title(name)

        self.frames = {}
        self.windows = {} # auf diese Weise die Elemente (Buttons, Labels) auf einer Seite organisieren
        self.windows[name] = page

        self.window = page(container, self) # repräsentiert ein "window" Hauptfenster (Input, Output, Statistik1)
        self.frames[name] = self.window
        self.window.pack()

        self.show_window(name)

    def show_window(self, cont):
        # print('291 self.frames: ', self.frames)
        window = self.frames[cont]
        # print('294 window: ', window)
        window.tkraise()

    def update_windows(self, name, window):
        self.frames[name] = window
        # print('297 update frames: ', self.frames)

if __name__ == "__main__":
    ips = {'local': '127.0.0.1', 'gitsche': "192.168.1.90", 'sv': '192.168.178.189', 'skali': '192.168.178.44',
           'rasp': '192.168.1.91'}

    songs = {'lemon': "unruhig.txt", 'casion': "professionell.txt", 'primar': "totem.txt",
             'dub': "Natuerliche_Argumentation.txt", 'track3': 'technologie.txt'}
    parser = argparse.ArgumentParser()
    parser.add_argument("--ip", default="192.168.1.44",
                        help="The ip of the osc_server06")
    # parser.add_argument("--ip", default="127.0.0.1",
    #                     help="The ip of the osc_server06")
    parser.add_argument("--port", type=int, default=5005,
                        help="The port the OSC server is listening on")
    parser.add_argument("--reset", default=False,
                        help="reset stats")
    parser.add_argument("--song",
                        default='lemon', help="songname")
    args = parser.parse_args()

    client_instance = ClientIO(ips[args.ip], args.port)

    texts, categories, names = DiskAdapter().get_training_data(CATEGORY_NAMES)# trainingsdaten holen

    for file in os.listdir('../UserEingaben'):
        # print('user eingaben: ', os.path.splitext(file)[0])
        USER_NAMES.append(os.path.splitext(file)[0])

    article = "../TestDaten/{}".format(songs[args.song])
    # print('article: ', article)

    with open(article, 'r') as ref:
        for line in ref.readlines():
            REF_LINES.append(line)


    classifier_instance = Classifier('../model_data')  # training
    interpreter_instance = Interpreter(classifier_instance)
    #mycanvas = MyCanvas(tk.Tk())

    textinput_instance = Interface('TextInput', TextInput)

    textoutput_instance = Interface('TextOutput', TextOutput)
    # print('textinput instance 320', type(textinput_instance.window))
    statistik_instance = Interface('Statistik1', Statistik1)

    # textinput_instance.update_windows('Statistik1', statistik_instance.window)
    # statistik_instance.update_windows('TextInput', textinput_instance.window)

    action_dict = {}

    feedback_instance = Feedback(interpreter_instance, client_instance, textoutput_instance.window, args.song)
    #print('id textinput: ', id(textinput_instance.window))

    feedback_instance.set_textinput(textinput_instance.window)
    textedit_instance = TextEdit(feedback_instance)
    textinput_instance.frames['TextInput'].set_textedit(textedit_instance)
    textinput_instance.frames['TextInput'].set_statistic(statistik_instance.window)
    #textinput_instance.frames['TextInput'].set_mycanv(mycanvas)
    textinput_instance.frames['TextInput'].set_reference(REF_LINES)

    for line in REF_LINES:
        #feedback_instance.dict_comp('user1', 'neutral', text, reftext, eigencat)
        pass


    def feedback_obj(uptodate):
        feedback_instance.dispatch(uptodate)

    dispatcher = dispatcher.Dispatcher()
    dispatcher.map("/feedback01", lambda address, uptodate: feedback_obj(uptodate))

    def server():
        server = osc_server.ThreadingOSCUDPServer((ips[args.ip], 5010), dispatcher)
        print("Serving on {}".format(server.server_address))
        server.serve_forever()

    serv = threading.Thread(name='server', target=server, daemon=True)
    serv.start()

    # textinput_instance.mainloop()
    textoutput_instance.mainloop()





