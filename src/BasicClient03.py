
import argparse
import threading
import re
import os
import time
from datetime import datetime
from pythonosc import dispatcher
from pythonosc import osc_server


DATETIME = datetime(2018, 8, 18, 10, 31, 30, 11111)
START = time.mktime(DATETIME.timetuple()) + DATETIME.microsecond / 1E6
from Categories import CATEGORY_NAMES, CAT2VAL

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



