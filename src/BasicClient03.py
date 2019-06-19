
import argparse
import pickle
import threading
import re
import os
import time
from datetime import datetime



from pythonosc.udp_client import SimpleUDPClient
from pythonosc import dispatcher
from pythonosc import osc_server

from Classifier_max import Classifier
from DiskAdapter2 import DiskAdapter

import collections

import matplotlib
matplotlib.use("TkAgg")
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
from matplotlib.figure import Figure

from PIL import Image, ImageTk
DATETIME = datetime(2018, 8, 18, 10, 31, 30, 11111)
START = time.mktime(DATETIME.timetuple()) + DATETIME.microsecond / 1E6
NORMAL_CHANNEL= [0.0 for i in range(29)]
NORMAL_CHANNEL.insert(6, 1.0)

CATEGORY_NAMES = []
CAT2VAL = {}

def p_dict(dict):
    for i in dict.keys():
        print('"{}" : {},\n'.format(i, dict[i]))

for file in os.listdir('../TrainingDataNew'):
    # print('Training Cats: ', os.path.splitext(file)[0])
    if not file.startswith('.') and not file.endswith('pkl'):
        CATEGORY_NAMES.append(os.path.splitext(file)[0])
        CATEGORY_NAMES.sort()

# del CATEGORY_NAMES[3]

CHANNEL = [[i for i in range(16)] for o in range(len(CATEGORY_NAMES))]


def category_dict(channel, ccnr, ccval):
    cat_dict = collections.OrderedDict()
    sub_dicts = []

    for k in range(len(channel)):
        for v in range(len(ccnr[k])):
            #print('länge von ccnr: ', v)
            dict = {ccnr[k][v] : ccval[k][v]}
            sub_dicts.append(dict)

        cat_dict['channel_{}'.format(channel[k])] = sub_dicts
        sub_dicts = []
            #print('subdicts: ', sub_dicts)


    return cat_dict

normal_values = category_dict(
    [i for i in range(16)],
    [[i for i in range(30)] for x in range(16)],
    [NORMAL_CHANNEL for v in range(30)]
)


WHEEL = [-2000, -250 , 10, 8000, 15, -1100, 0, 850]

CCNR = [[i for i in range(19)] for i in range(len(CATEGORY_NAMES))]
CCVAL = [normal_values for i in range(len(CATEGORY_NAMES))]
COARSE = [90, 92, 80, 2, 10, 40, 70, 89]
FINE = [1, 2, 102, 77, 55, 80, 100, 62]
REPEAT = [6, 4, 4, 5, 1, 2, 3, 1]


def dict_values(keys1, wheel, cc_dict, coarse, fine, repeat):
    val_dict = collections.OrderedDict()
    #cc_dict = {channel[k]: {ccnr[l] : ccval[l] for l in range(len(ccnr))} for k in range(len(channel))}
    #print('addresses: ', address)
    # print('ccvals: ', ccvals)
    for i in range(len(keys1)):
        val_dict[keys1[i]] = {'wheel': wheel[i],
                              'cc_dict': cc_dict[i],
                              'coarse': coarse[i],
                              'fine': fine[i],
                              'repeat': repeat[i],
                          }
    # print('val_dict: ', val_dict)
    return val_dict

category_values = 'nochmal nachschauen'

if os.path.exists('../model_data/CAT2VAL.pkl'):
    print('pickle exists? ', os.path.exists('../model_data/CAT2VAL.pkl'))

    with open('../model_data/CAT2VAL.pkl', 'rb') as f:
        CAT2VAL = pickle.load(f)
    CAT2VAL['Loesung'] = {'wheel': 2000, 'repeat': 2, 'cc_dict': normal_values, 'coarse': 37, 'fine': 0}
    CAT2VAL['Gaga'] = {'wheel': 8000, 'repeat': 2, 'cc_dict': normal_values, 'coarse': 37, 'fine': 0}

    #print('CAT2VAL nach pickle load: ', p_dict(CAT2VAL) )

else:
    CAT2VAL = dict_values(CATEGORY_NAMES, WHEEL, category_values, COARSE, FINE, REPEAT, )
    #p_dict(CAT2VAL)
    with open('../model_data/CAT2VAL.pkl', 'wb') as f:
        pickle.dump(CAT2VAL, f, pickle.HIGHEST_PROTOCOL)


class Feedback:
    def __init__(self, interpreter, client, interface):
        self.interpreter = interpreter
        self.client = client
        self.interface = interface
        self.feedback = {}
        self.feedback_note_ids = []
        self.feedbackvals = []
        self.map = {}
        self.dynamicvals = []
        self.actions = {}

class TextEdit:
    def __init__(self, feedback):
        self.feedback = feedback
        self.linenr = 0

    def one_satz(self, user, intent, reftext, satz, eigencat):
        self.text_cat_save(user, intent, satz, eigencat, reftext)
        self.feedback.dict_comp(user, intent, satz, reftext, eigencat)
        self.feedback.controller_send()

    def multi_satz(self, user, intent, reftext, saetze, eigencat):
        print('sätze :', saetze)
        for satz in saetze:
            self.text_cat_save(user, satz, intent, eigencat, reftext)
            self.feedback.dict_comp(user, intent, satz, reftext, eigencat)
            self.linenr += 1
            if self.linenr == len(self.saetze):
                # print('jetzt schicken, weil: ', self.linenr, '=', len(self.saetze))
                self.feedback.controller_send()
                self.linenr = 0

    def new_beitrag(self, user, intent, ref_text, user_text, eigencat):
        self.saetze = re.split(r'[\r\n]+', user_text)  # jede Zeile = Satz
        # self.feedback.init_send(user)  # falls ich per button den Song starten will

        if len(self.saetze) <= 1:
            self.one_satz(user, intent, ref_text, self.saetze[0], eigencat)

        else:
            self.multi_satz(user, intent, ref_text, self.saetze, eigencat)
        self.feedback.reset()

    def calibrate(self, user, text):
        self.feedback.direct_send(user, text)

    def direct_input(self, tw, username):
        self.saetze = re.split('\s. |\n', tw)
        if len(self.saetze) > 1:
            for satz in self.saetze:
                self.feedback.fader_compile(satz)
                self.linenr += 1
                if self.linenr == len(self.saetze):
                    self.feedback.fader_select(username)
                    self.linenr = 0
        else:
            self.feedback.direct_send(int(tw), username)

    def text_cat_save(self, user, intent, text, eigencat, reftext):
        path1 = '../UserEingaben/{}'.format(user)
        path2 = '../TrainingData'
        # print('eigen_cat: ', eigencat)
        if not os.path.exists(path1) :
            os.mkdir(path1)

        with open('{}/{}.txt'.format(path1, eigencat), 'a') as t:
            t.write('Ref: {} | Meinung: {} | EigenCat: {} \n'.format(reftext, text, eigencat))


class Interpreter:
    def __init__(self, classifier):
        self.classifier = classifier
        print('Classifier', self.classifier)

    def text2pitch(self, text):
        cat, prob = self.classifier.predict_proba(text, verbose=True)
        print('input {}, cat {}, prob {}: '.format(text, cat, prob))
        velo = CAT2VAL[cat]['velo']
        pitch = CAT2VAL[cat]['pitch']
        return [pitch, velo, cat, prob[0]]

    def text2wheel(self, text):
        cat, prob = self.classifier.predict_proba(text, filter_stop_words=False, verbose=True)
        print('input {}, cat {}, prob {}: '.format(text, cat, prob))
        # pitch = category_to_note[classified_category_name]
        wheel = CAT2VAL[cat]['wheel']
        return [wheel, cat, prob]

    def text2repeat(self, text):
        cat, prob = self.classifier.predict_proba(text, verbose=True)
        #print('input {}, cat {}, prob {}: '.format(text, CATEGORY_NAMES[cat], prob))
        repeat = CAT2VAL[cat]['repeat']
        return repeat

    def text2ccval(self, text):
        cat, prob = self.classifier.predict_proba(text, verbose=True)
        print('input {}, cat {}, prob {}: '.format(text, cat, prob))
        cc_dict = CAT2VAL[cat]['cc_dict']
        return cc_dict

    def text2coarse(self, text):
        cat, prob = self.classifier.predict_proba(text, verbose=True)
        #print('input {}, cat {}, prob {}: '.format(text, CATEGORY_NAMES[cat], prob))
        coarse = CAT2VAL[cat]['coarse']
        return coarse

    def text2fine(self, text):
        cat, prob = self.classifier.predict_proba(text, verbose=True)
        fine = CAT2VAL[cat]['fine']
        return fine







if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    # parser.add_argument("--ip", default="127.0.0.1",
    parser.add_argument("--ip", default="127.0.0.1",
                        help="The ip of the OSC server")
    parser.add_argument("--port", type=int, default=5005,
                        help="The port the OSC server is listening on")

    args = parser.parse_args()
    client_instance = ClientIO(args.ip, args.port)


    def server():
        parser2 = argparse.ArgumentParser()
        parser2.add_argument("--ip",
                             default="127.0.0.1", help="The ip to listen on")
        parser2.add_argument("--port",
                             type=int, default=5010, help="The port to listen on")
        args = parser2.parse_args()
        server = osc_server.ThreadingOSCUDPServer((args.ip, args.port), dispatcher)
        print("Serving on {}".format(server.server_address))
        server.serve_forever()

    serv = threading.Thread(name='server', target=server, daemon=True)
    #serv.start()



