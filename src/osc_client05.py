"""
NEU: client.send_message soll jetzt ein dictionary übergeben, ähnlich den Moll/Dur Maps. funzt mit pickle.
Es werden nun auch die aktuelle melodie in eine listbox übertragen.
point (melodieauswahl) funzt nun mit der auswahl per maus der jeweiligen melodie

"""
import argparse
import pickle
import threading
import re

from pythonosc import osc_message_builder
from pythonosc.udp_client import SimpleUDPClient
from pythonosc import dispatcher
from pythonosc import osc_server

from Classifier import Classifier
from DiskAdapter2 import DiskAdapter
import tkinter as tk

meta_maps = {'Konsonant': 'dur, moll, ein akkord pad hinzufügen, arpeggii bauen sich auf',
             'destruktiv': 'tempo fuckup, noten verschieben, extreme pitchwheel level',
             'leicht dissonant': '',
             'leicht dissonant2': 'erkannte probs random auf auf notenIds verteilen ',
             'total dissonant': 'wheel -5000 - 8000',
             'Störung': 'die nächsten drei Noten dissonant',
             'an Störung gewöhnen': 'steigerung der Wheel Dissonanz',
             'nerviges Gefühl': '3 normal, 2dissonant, 4, leicht dissonant',
             'cat a, cat b, cat c, cat a': 'wheel-5000 jede 2. Note'}

CATEGORY_2_MAP = {
    'AngriffVerteidigung': 93,
    'Auseinandersetzung': 30,
    'Belehrung': 82,
    'Diagnose': 80,
    'FaktBasta': 85,
    'Urteil': 108,
    'Empoerung': 40,
    'Kolonialisierung': 50,
    'Positionierung': 60,
    'Selbstdarstellung': 70,
    'WollenBitte': 90,
    'ZuNachgeben': 100,
    'Zweifel': 75,
    'Schwadronier': 52,
    'Zustimmung': 48,
    'Fehler': 33,
    'AusfuehrungErklaerung': 55,
    'Frage': 59,
    'Unterstellung': 60,
    'Zweifel': 88
}

CATEGORY_NAMES = ['Diagnose', 'FaktBasta', 'Empoerung', 'Kolonialisierung', 'Zustimmung',
                  'Positionierung', 'Selbstdarstellung', 'WollenBitte', 'ZuNachgeben', 'Zweifel',
                  'Urteil', 'Schwadronier', 'AusfuehrungErklaerung', 'AngriffVerteidigung','Fehler','Frage',
                  'Unterstellung', 'Zweifel']

CATEGORY_2_WHEEL = {k: 8000 for k in CATEGORY_NAMES}

category_to_note = {
    'AngriffVerteidigung': 35,
    'Auseinandersetzung': 30,
    'Belehrung': 80,
    'Diagnose': 80,
    'FaktBasta': 85,
    'Urteil': 110,
    'Empoerung': 40,
    'Kolonialisierung': 50,
    'Positionierung': 60,
    'Selbstdarstellung': 70,
    'WollenBitte': 90,
    'ZuNachgeben': 100,
    'Zweifel': 75,
    'Schwadronier': 52,
    'Zustimmung': 48,
    'AusfuehrungErklaerung': 96
}

class Feedback:
    def __init__(self, counter, interpreter, client, interface):
        self.counter = counter
        self.interpreter = interpreter
        self.client = client
        self.interface = interface
        self.feedback = {}
        self.feedback_note_ids = []
        self.feedbackvals = []
        self.map = {}
        self.dynamicvals = []

    def dispatch(self, name, notes):
        self.interface.listbox_update(name)
        self.feedback[name] = notes
        self.feedback_note_ids = [i for i, j in enumerate(notes)]
        self.feedbackvals = [0 for i in range(len(self.feedback_note_ids))]
        # print('self.feedback {} note ids {}'.format(self.feedback, self.feedback_note_ids))

    def build_compile(self, id, text):
        pitch = self.interpreter.val2pitch(text)
        self.dynamicvals.append(pitch)
        self.counter.job_count('build', pitch)
        print('buildvals {} id {} '.format(self.dynamicvals, id))

    def buildmap_send(self, username):
        self.feedback_note_ids = [i for i, j in enumerate(self.dynamicvals)]
        self.buildmap = {k: int(self.dynamicvals[k]) for k in self.feedback_note_ids}
        self.buildmap['user'] = username
        self.client.send_message(self.buildmap)

    def wheelmap_compile(self, id, text):
        wheel = self.interpreter.val2wheel(text)
        self.feedbackvals[id] = wheel
        self.counter.job_count('wheel', wheel)
        print('wheelvals {} id {} '.format(self.feedbackvals, id))

    def wheelmap_send(self, point):
        self.map = {k: int(self.feedbackvals[k]) for k in self.feedback_note_ids}
        self.map['point'] = self.interface.get_point()
        wheel_dict = pickle.dumps(self.map)
        print('self.map  ', self.map)
        self.client.send_wheelmap(wheel_dict)

    def pitchmap_compile(self, id, text):
        pitch = self.interpreter.val2pitch(text)
        self.feedbackvals[id] = pitch
        self.counter.job_count('pitch', pitch)

    def pitchmap_send(self):
        self.feedback_note_ids = [i for i, j in enumerate(self.feedbackvals)]
        self.map = {k: int(self.feedbackvals[k]) for k in self.feedback_note_ids}
        self.map['point'] = self.interface.get_point()
        self.client.send_message(self.map)

    def cc_compile(self, text, len):
        cc = self.interpreter.prob2cc(text)
        self.dynamicvals.append(round(cc, 2))
        self.counter.job_count('cc', round(cc, 2))

    def cclist_send(self):
        # self.dynamicvals.append(self.interface.get_point())
        # print('dynamicvals: ',self.dynamicvals)
        self.client.send_cclist(self.dynamicvals)

class TextEdit:
    def __init__(self, feedback):
        self.feedback = feedback
        self.linenr = 0
        self.weight = 0
        self.saetze = ''

    def text_parts_build(self, tw, username):
        self.saetze = re.split('\s. |\n', tw)
        for satz in self.saetze:
            self.weight = len(satz)
            self.feedback.build_compile(self.linenr, satz)
            self.text_parts_save(satz, username)
            self.linenr += 1
            if self.linenr == len(self.saetze):
                print('jetzt schicken, weil: ', self.linenr, '=', len(self.saetze))
                self.feedback.buildmap_send(username)
                self.linenr = 0

    def text_parts_wheel(self, tw, username):
        '''IndexError: index 12 is out of bounds for axis 1 with size 12
            kommt unregelmmäßig, WARUM. Hat was mit classifier.predict_proba zu tun?
            '''
        self.weight = len(tw)
        self.saetze= re.split('\s. |\n', tw)# \s. = alle Whitespaces und alle Punkte \n alle newlines
        print('satzliste {}, weight: {} '.format(self.saetze, self.weight))

        for satz in self.saetze:
            point = re.findall('Sie', satz)
            print('point', len(point))
            # interface.wheel(self.linenr, satz, len(point))
            # interpreter.val2wheel(self.linenr, satz, len(point))
            self.feedback.wheelmap_compile(self.linenr, satz)
            self.text_parts_save(satz, username)
            self.linenr += 1
            if self.linenr == len(self.saetze):
                print('jetzt schicken, weil: ', self.linenr, '=', len(self.saetze))
                self.feedback.wheelmap_send(len(point))
                self.linenr = 0

    def text_parts_pitch(self, tw, username):
        self.weight = len(tw)
        self.saetze= re.split('\s. |\n', tw)# \s. = alle Whitespaces und alle Punkte \n alle newlines
        print('satzliste {}, weight: {} '.format(self.saetze, self.weight))

        for satz in self.saetze:
            point = re.findall('Sie', satz)
            print('point', len(point))
            # interface.wheel(self.linenr, satz, len(point))
            # interpreter.val2wheel(self.linenr, satz, len(point))
            self.feedback.wheelmap_compile(self.linenr, satz)
            self.text_parts_save(satz, username)
            self.linenr += 1
            if self.linenr == len(self.saetze):
                print('jetzt schicken, weil: ', self.linenr, '=', len(self.saetze))
                self.feedback.wheelmap_send(len(point))
                self.linenr = 0
                # interface.delete_text()

    def text_parts_cc(self, tw, username):
        self.saetze = re.split('\s. |\n', tw)
        for satz in self.saetze:
            self.weight = len(satz)
            self.feedback.cc_compile(self.linenr, satz)
            self.text_parts_save(satz, username)
            self.linenr += 1
            if self.linenr == len(self.saetze):
                print('jetzt schicken, weil: ', self.linenr, '=', len(self.saetze), 'username: ', username)
                self.feedback.ccmap_send(username)
                self.linenr = 0

    def text_parts_save(self, satz, user='icke'):
        with open('../UserEingaben/{}.txt'.format(user), 'a') as t:
            t.write(satz + '\n')

class Interpreter:
    def __init__(self, classifier):
        self.classifier = classifier

    def val2pitch(self, text):
        cat, prob = self.classifier.predict_proba(text)
        print('input {}, cat {}, prob {}: '.format(text, CATEGORY_NAMES[cat], prob))
        classified_category_name = CATEGORY_NAMES[cat]
        pitch = CATEGORY_2_MAP[classified_category_name]
        #counter.cat_count(category_names[cat], prob)
        return pitch

    def prob2cc(self, text):
        cat, prob = self.classifier.predict_proba(text)
        print('prob2 cc: input {}, cat {}, prob {}: '.format(text, CATEGORY_NAMES[cat], prob))
        classified_category_name = CATEGORY_NAMES[cat]
        return prob[0]

    def val2time(self, text):
        cat, prob = self.classifier.predict_proba(text)
        print('05: input {}, cat {}, prob {}: '.format(text, CATEGORY_NAMES[cat], prob))
        classified_category_name = CATEGORY_NAMES[cat]
        tm = prob
        return tm

    def val2wheel(self, text):
        cat, prob = self.classifier.predict_proba(text)
        print('input {}, cat {}, prob {}: '.format(text, CATEGORY_NAMES[cat], prob))
        classified_category_name = CATEGORY_NAMES[cat]
        wheel = CATEGORY_2_WHEEL[classified_category_name] * float(prob)
        return wheel

class Counter:
    def __init__(self):
        self.actions = ['pitch', 'wheel', 'tm', 'ccval', 'newnotes']
        self.vals = []
        self.jobs = {k : self.vals for k in self.actions}
        # print('jobs', self.jobs)

    # def cat_count(self, cat, prob):
    #     # if cat not in self.categs:
    #     #     self.categs.append(cat)
    #     self.probs = self.jobs[cat]
    #     self.probs.append(round(float(prob),5))

    def job_count(self, job, val):
        self.jobs[job] = val

class Interface(tk.Frame):
    LARGE_FONT = ("Futura", 15)
    SMALL_FONT = ("Arial", 13)
    BGC = '#CDCDC1'
    TEXT = ''
    TL = []

    textedit = None

    def __init__(self, master=None):
        tk.Frame.__init__(self, master)
        self.master.title('Eingabe')
        self.pack()
        self.createLabels()
        self.createButtons()
        self.listbox()
        self.eingabe = 'Textwidget Eingabe'
        self.createText()
        self.user = 'icke'

    def return_text(self):
        return self.tw01.get('1.0', 'end')

    def delete_text(self):
        self.tw01.delete('1.0', 'end')

    def createText(self):
        self.tw01 = tk.Text(self, height=5, width=80, font=Interface.SMALL_FONT)
        self.scroll = tk.Scrollbar(self)
        self.scroll.config(command=self.tw01.yview)
        self.tw01.config(yscrollcommand=self.scroll.set, background=Interface.BGC)
        self.tw01.grid(column=1, row=1)
        self.tw01.insert('end', self.eingabe)
        self.eingabe = self.tw01.get('1.0', 'end')

    def createLabels(self):

        self.label01 = tk.Label(self, text="Name", font=Interface.LARGE_FONT)
        self.label01.grid(column =0, row=0, pady=10)
        self.value01 = tk.Entry(self)

        self.entry01 = tk.Entry(self)
        self.username = tk.StringVar()
        self.entry01['textvariable'] = self.username
        self.entry01.grid(column=1, row=0)

        self.label02 = tk.Label(self, text="CLASSIFY: Meinung bitte", font=Interface.LARGE_FONT)
        self.label02.grid(column =0, row=1, pady=10)
        self.value02 = tk.Entry(self)

    def createButtons(self):
        self.button01 = tk.Button(self, text='note classifier', command=self.button01_command)
        self.button01.grid(column=2, row=0, padx=10)

        self.button02 = tk.Button(self, text='wheel', command=self.button02_command)
        self.button02.grid(column=2, row=1, padx=10)

        self.button03 = tk.Button(self, text='cc', command=self.button03_command)
        self.button03.grid(column=2, row=2, padx=10)

        self.button04 = tk.Button(self, text='build', command=self.button04_command)
        self.button04.grid(column=2, row=3, padx=10)

        self.button07 = tk.Button(self, text='quit', command=quit)
        self.button07.grid(column=2, row=4, padx=10, pady=10)

    def listbox(self):
        self.lb01 = tk.Listbox(height=5)
        self.lb01.pack(padx=10, pady=20)

    def listbox_update(self,now):
        # self.lb01.delete(0, 'end')
        self.lb01.insert('end', now)
        if self.lb01.size() > 5:
            self.lb01.delete(0, 'end')
        items = self.lb01.get(0, 'end')
        # print('items: ', items)

    def get_point(self):
        sel = self.lb01.curselection()
        # print(20*'-', sel)
        point = self.lb01.get(sel)
        return point

    def button01_command(self):
        self.textedit.text_parts_wheel(self.tw01.get('1.0', 'end-1c'), self.username)

    def button02_command(self):
        self.textedit.text_parts_wheel(self.tw01.get('1.0', 'end-1c'), self.username)

    def button03_command(self):
        self.textedit.text_parts_cc(self.tw01.get('1.0', 'end-1c'), self.username)

    def button04_command(self):
        self.textedit.text_parts_build(self.tw01.get('1.0', 'end-1c'), self.username.get())

    def set_textedit(self, textedit):
        self.textedit = textedit

class ClientIO(SimpleUDPClient):

    def __init__(self, ip, port):
        super(ClientIO, self).__init__(ip, port)

    def send_buildmap(self, map):
        self.send_message("/buildmap", map)

    def send_wheelmap(self, map):
        self.send_message("/wheelmap", map)

    def send_pitchmap(self, map):
        self.send_message("/pitchmap", map)

    def send_cclist(self, list):
        print('list to send: ', list)
        liste = pickle.dumps(list)
        self.send_message("/cclist", liste)
        # self.send_point()

    def send_point(self):
        point = interface_instance.get_point()
        print('point vor send: ',point)
        self.send_message("/point", point)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    # parser.add_argument("--ip", default="127.0.0.1",
    parser.add_argument("--ip", default="127.0.0.1",
                        help="The ip of the OSC server")
    parser.add_argument("--port", type=int, default=5005,
                        help="The port the OSC server is listening on")
    args = parser.parse_args()
    client_instance = ClientIO(args.ip, args.port)
    print('clients id', id(client_instance))

    texts, categories, _ = DiskAdapter().get_training_data(CATEGORY_NAMES)  # trainingsdaten holen
    classifier_instance = Classifier(texts, categories)  # training

    counter_instance = Counter()
    interpreter_instance = Interpreter(classifier_instance)
    interface_instance = Interface()

    feedback_instance = Feedback(counter_instance, interpreter_instance, client_instance, interface_instance)
    textedit_instance = TextEdit(feedback_instance)
    interface_instance.set_textedit(textedit_instance)

    def feedback_obj(uptodate):
        feed_server = pickle.loads(uptodate)
        for i, j in feed_server.items():
            name = i
            notes = j
        feedback_instance.dispatch(name, notes)

    dispatcher = dispatcher.Dispatcher()
    dispatcher.map("/feedback01", lambda address, uptodate: feedback_obj(uptodate))

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
    serv.start()
    # print(threading.enumerate())
    interface_instance.mainloop()


