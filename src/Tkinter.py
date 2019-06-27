import tkinter as tk

import os
from itertools import cycle
from Categories import CATEGORY_NAMES
import matplotlib
matplotlib.use("TkAgg")
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
from matplotlib.figure import Figure
from collections import defaultdict

CATCOLORS = ['#d9ff05', 'magenta', '#4b62b7', '#51bc56', 'cyan', '#bfff60', '#eab9d7', '#c4ace5', '#a08975']
CAT2COLOR = {CATEGORY_NAMES[k]:CATCOLORS[k] for k in range(len(CATEGORY_NAMES))}

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

class TextInput(tk.Frame):

    LARGE_FONT = ("Verdana", 30)
    SMALL_FONT = ("Verdana", 20)
    BGC = '#CDCDC1'
    FG = ['#000000', '#f44242']

    def __init__(self, parent, controller):
        #parent = tk.Frame
        #print('parent: {} controller: {} self: {}'.format(type(parent), type(controller), type(self)))
        tk.Frame.__init__(self, parent)
        self.parent = parent
        self.controller = controller # tk.Tk

        self.textedit = None
        self.statistic = None
        self.mycanv = None
        self.intent = ''
        self.reference = []
        self.eingabe = "anfangen"
        self.widgets = []
        self.reftext = ''
        self.init_polygon = [20, 20, 600, 20, 600, 620, 20, 620]
        self.createCanvas()
        self.createText()
        self.createButtons()
        self.category = ''
        self.user = 'icke'
        self.createLabels()

    def set_reference(self, ref):
        self.reference = ref
        self.read_ref(self.reference[:])

    def set_mycanv(self, canvas):
        self.mycanv = canvas
        self.mycanv.pack()
        # self.mycanv.grid(column=3, row=1, columnspan=4, rowspan=4, sticky="NSEW")
        # print('mycanv =', self.mycanv)

    def createText(self):
        self.ref_canvas = tk.Text(self, width=60, font=TextInput.SMALL_FONT)
        self.ref_canvas.config(background=TextInput.BGC)
        self.scroll1 = tk.Scrollbar(self)
        self.scroll1.config(command=self.ref_canvas.yview)
        self.ref_canvas.config(yscrollcommand=self.scroll1.set)
        # self.ref_text.grid(column=0, row=1, columnspan=3, rowspan=4,  padx=5, sticky='NSWE')
        self.widgets.append(self.ref_canvas)


        self.user_text = tk.Text(self, width=40, height= 5, wrap=tk.WORD, font=TextInput.SMALL_FONT, bg=TextInput.BGC)
        self.scroll2 = tk.Scrollbar(self)
        self.scroll2.config(command=self.user_text.yview)
        self.user_text.config(yscrollcommand=self.scroll2.set)
        self.user_text.grid(column=3, columnspan=4, row=1, rowspan=5,  padx=5, sticky='NSWE')
        self.user_text.insert('end', self.eingabe)
        self.user_text.columnconfigure(2, weight=1)
        self.widgets.append(self.user_text)

    def canvas_form(self):
        self.init_polygon = (20, 234, 80, 40, 380, 20, 440, 280, 380, 430, 152, 415)

    def createCanvas(self):
        self.ref_can = tk.Canvas(self, width=300, height=420, borderwidth= 2)
        self.ref_can.grid(column=0, row=1, columnspan=3, rowspan=4, padx=5, sticky="W")
        self.widgets.append(self.ref_can)
        self.ref_can.create_polygon(*self.init_polygon, fill='white',
                                    outline='grey', width=2)

        self.user_can = tk.Canvas(self, width= 100, height=200)
        # self.user_can.grid(column=3, row=1, columnspan=4, rowspan=4, sticky="NSEW")
        self.widgets.append(self.user_can)
        # self.user_can.create_polygon(*self.init_polygon, fill=TextInput.BGC,
        #                             outline='grey', width=10)

    def read_ref(self, lines):
        line = lines.pop(0)
        time = len(line) * 180
        self.ref_can.delete('furb')
        self.ref_can.create_text(180, 200, text=line, justify='left', width=200, tag='furb', font=TextInput.SMALL_FONT)

        if lines:
            self.after(time, self.read_ref, lines)
            self.reftext = line
        else:
            self.after(time, self.read_ref, self.reference[:])

    def delete_text(self, widget):
        print('deleting  ')
        widget.delete('1.0', 'end')

    def createLabels(self):

        self.label01 = tk.Label(self, text="1. Gib Deinen Namen ein", font=TextInput.SMALL_FONT)
        self.label01.grid(column=7, row=0, padx=10, pady=2, sticky='W')
        self.entry01 = tk.Entry(self, width=12)
        #self.label01.grid_columnconfigure(2, weight=1)
        self.widgets.append(self.label01)

        self.label02 = tk.Label(self, text="2. Gib hier unten Deine Meinung ein", font=TextInput.SMALL_FONT)
        self.label02.grid(column=3, row=0, columnspan= 4, padx=2, pady=10, sticky='W')

        self.entry01 = tk.Entry(self, width= 12, font=TextInput.SMALL_FONT, bd=1)
        self.username = tk.StringVar()
        self.entry01['textvariable'] = self.username
        self.entry01.insert('end', self.user)
        self.entry01.grid(column=7, row=1, sticky='NW')
        self.widgets.append(self.entry01)

        self.label03 = tk.Label(self, text="3. Wähle eine Kategorie aus", font=TextInput.SMALL_FONT)
        self.label03.grid(column=7, row=2, sticky='NW')
        self.widgets.append(self.label01)

        self.lb_cat = tk.Listbox(self, height=8, font=TextInput.SMALL_FONT)
        self.lb_cat.grid(column=7, row=3, pady=1, padx=3, sticky="N")
        self.lb_cat.rowconfigure(1, weight=1)
        self.widgets.append(self.lb_cat)

        for c in range(len(CATEGORY_NAMES)):
            self.lb_cat.insert('end', CATEGORY_NAMES[c])

        self.label04 = tk.Label(self, text="4. Oder gib ein neue Kategorie an", font=TextInput.SMALL_FONT)
        self.label04.grid(column=7, row=4, sticky='WS')

        self.label05 = tk.Label(self, text="5. Schick die Meinung ab", font=TextInput.SMALL_FONT)
        self.label05.grid(column=7, row=6, sticky='WS')
        self.widgets.append(self.label03)

        self.entry03 = tk.Entry(self, width=12, font=TextInput.SMALL_FONT, bd=1)
        self.eigen_cat = tk.StringVar()
        self.entry03['textvariable'] = self.eigen_cat
        self.entry03.grid(column=7, row=5, sticky="WN")
        self.widgets.append(self.entry03)

    def createButtons(self):
        self.button01 = tk.Button(self, text='neutral', font=TextInput.SMALL_FONT, highlightbackground=TextInput.BGC, command=lambda: self.button01_command('neutral'))
        self.button01.grid(column=3, row=6, padx=1, pady=5, sticky="W")
        # self.button01.config(highlightbackground='black', bd=0.4)
        # print('button01 info: ', self.button01.grid_info())
        self.widgets.append(self.button01)

        self.button02 = tk.Button(self, text='puzzle', font=TextInput.SMALL_FONT, highlightbackground=TextInput.BGC, command=lambda: self.button01_command('puzzle'))
        self.button02.grid(column=4, row=6, padx=1, pady=5, sticky="W")
        self.widgets.append(self.button02)

        self.button03 = tk.Button(self, text='irritate', font=TextInput.SMALL_FONT, highlightbackground=TextInput.BGC, command=lambda: self.button01_command('irritate'))
        self.button03.grid(column=5, row=6, padx=1, pady=5, sticky="W")
        self.widgets.append(self.button03)

        self.button04 = tk.Button(self, text='wobble', font=TextInput.SMALL_FONT, highlightbackground=TextInput.BGC, command=lambda: self.button01_command('wobble'))
        self.button04.grid(column=6, row=6, padx=1, pady=5, sticky="W")
        self.widgets.append(self.button04)

        self.button05 = tk.Button(self, text='dream', font=TextInput.SMALL_FONT, highlightbackground=TextInput.BGC,  command=lambda: self.button01_command('dream'))
        self.button05.grid(column=3, row=7, padx=1, pady=5, sticky="NW")
        self.widgets.append(self.button05)

        self.button06 = tk.Button(self, text='blurry', font=TextInput.SMALL_FONT, highlightbackground=TextInput.BGC, command=lambda: self.button01_command('blurry'))
        self.button06.grid(column=4, row=7, padx=1, pady=5, sticky="NW")
        self.widgets.append(self.button06)

        self.button07 = tk.Button(self, text='messy', font=TextInput.SMALL_FONT, highlightbackground=TextInput.BGC, command=lambda: self.button01_command('messy'))
        self.button07.grid(column=5, row=7, padx=1, pady=5, sticky="NW")
        self.widgets.append(self.button07)

        self.button08 = tk.Button(self, text='toxic', font=TextInput.SMALL_FONT, highlightbackground=TextInput.BGC, command=lambda: self.button01_command('toxic'))
        self.button08.grid(column=6, row=7, padx=1, pady=5, sticky="NW")
        self.widgets.append(self.button08)

        self.button09 = tk.Button(self, text='quit', command=quit)
        # self.button09.grid(column=0, row=6, padx=1, sticky="NW")
        self.widgets.append(self.button09)

        self.button10 = tk.Button(self, text='LIVE Kalibrier', command=self.button10_command)
        # self.button10.grid(column=1, row=6, padx=1, sticky="NW")
        self.widgets.append(self.button10)

    def button01_command(self, intent):
        self.intent = intent
        user = self.username.get()
        meinung = self.user_text.get('1.0', 'end-1c')
        cat = self.lb_cat.curselection()
        if len(cat) > 0:
            self.category = self.lb_cat.get(cat)
        elif len(cat) == 0 and len(self.eigen_cat.get()) == 0:
            self.category = 'no_cat'
        else:
            self.category = self.eigen_cat.get()
        print(' 472 self.cat: {} \t '.format(self.category)) # wie kann man wieder deselektieren?
        self.textedit.new_beitrag(self.username.get(), self.intent, self.reftext, meinung, self.category)
        if self.category == 'no_cat' or user == 'icke:':
            self.user_text.tag_config('name', foreground=TextInput.FG[1])
            self.user_text.insert('end', '\nBitte gib einen Namen ein und wähle eine Kategorie\n', 'name')
        self.after(2000, self.delete_text, self.user_text)
        self.lb_cat.selection_clear(0, 'end')
        self.entry03.delete(0, 'end')

    def button09_command(self):
        self.textedit.direct_input(self.user_text.get('1.0', 'end-1c'), self.username.get())

    def button10_command(self):
        print('Calibrate button!')

        self.textedit.calibrate(self.username.get(), self.user_text.get('1.0', 'end-1c') )

    def set_textedit(self, textedit):
        self.textedit = textedit

    def set_statistic(self, statistic):
        self.statistic = statistic
        # print('set statistik, ', self.statistic.songparts)

class TextOutput(tk.Frame):

    HEADLINE = ("Verdana", 40)
    LARGE_FONT = ("Verdana", 25)
    SMALL_FONT = ("Verdana", 20)
    BGC = '#444444'
    BG = ['#428cf4', '#b841f4', '#f44149', '#41f46a']
    FG = ['#000000', '#f44242','#FFFFFF']
    SONGCOLORS = ['#ffae00', '#0953e8']

    def __init__(self, parent, controller):
        tk.Frame.__init__(self, parent)
        # print('415 TextInput instance: ', type(self))
        self.parent = parent
        self.controller = controller
        self.textedit = None
        self.widgets = []
        self.part = None
        self.createButtons()
        self.user = 'icke'
        self.clastext_coords = [20, 20]
        self.createLabels()
        self.createCanvas()
        self.image = None
        self.song = tk.Canvas(self, width=400, height=20)
        self.song.grid(column=2, row=4, columnspan=4, pady=10, sticky=tk.W + tk.S)
        self.songparts = {}
        self.songpos = 'slot1'
        self.slotcolors = [y for x, y in zip(range(26), cycle(TextOutput.SONGCOLORS))]
        self.form = self.clas_can.create_image(200, 200, image=self.image, tag='form')
        self.classified = self.clas_can.create_text(*self.clastext_coords,
                                                    text='kommentare ...\n',
                                                    fill='black', tag='clas', font=TextOutput.LARGE_FONT,
                                                    width=600, anchor=tk.NW)
        self.after_id = None
        self.song_position()

    # def image_var(self, cat):
    #     file = CAT2VAL[cat]['image']
    #     self.image = ImageTk.PhotoImage(file, master=self)
    #     # print('545 type image: ', type(self.image))
    #     # self.clas_can.itemconfigure('form', image=self.image, background=CAT2COLOR[cat])
    #     self.clas_can.configure(background=CAT2COLOR[cat])

    def createCanvas(self):
        self.clas_can = tk.Canvas(self, width=300, height=300, borderwidth=5)
        self.scroll = tk.Scrollbar(self, orient='vertical', command=self.clas_can.yview)
        self.clas_can.grid(column=0, row=1, padx=5, sticky="NSWE")
        self.scroll.grid(column=1, row=1, sticky='NS')
        self.clas_can.configure(yscrollcommand=self.scroll.set)
        self.clas_can['yscrollcommand'] = self.scroll.set
        self.widgets.append(self.clas_can)

    def clastext_update(self, user, cat, prob, text):
        insert = "User: {}, Kategorie: {} Proba:{}\n{}\n".format(user, cat, prob, text)
        self.clas_can.insert('clas', tk.END, insert)
        self.clas_can.yview_moveto(1.0)
        self.clas_can.configure(scrollregion = self.clas_can.bbox('all'))

    def createLabels(self):

        self.label04 = tk.Label(self, text="Abgebene Meinungen", font=TextOutput.SMALL_FONT)
        self.label04.grid(column=0, row=0, padx=5, pady=15, sticky='W')

    def createButtons(self):

        self.button09 = tk.Button(self, text='quit', command=quit)
        # self.button09.grid(column=0, row=4, padx=1, sticky="NW")

        self.button10 = tk.Button(self, text='LIVE Kalibrier', command=self.button10_command)
        #self.button10.grid(column=1, row=4, padx=1, sticky="NW")

    def button10_command(self):
        print('Button10 command!')

    def set_textedit(self, textedit):
        self.textedit = textedit

    @staticmethod
    def get_abs_values_for_piechart(pct, allvals):
        absolute = int(pct / 100. * sum(allvals))
        return "{:d}".format(absolute)

    def category_stats(self, fig, stats):

        cats, counts, catcolors = [], [], []

        for cat, intents in stats.items():
            cats.append(cat)
            counts.append(len(intents))
        for label in cats:
            catcolors.append(CAT2COLOR[label])

        a = fig.add_subplot(211)
        a.pie(x=counts, labels=cats, colors=catcolors, autopct=lambda pct: self.get_abs_values_for_piechart(pct, counts))
        a.legend(bbox_to_anchor=(1, 0, 0.5, 1))

        return fig

    def intent_stats(self, fig, stats):
        intent_counter = defaultdict(int)

        for intents in stats.values():
            for intent in intents:
                intent_counter[intent] += 1

        counts = list(intent_counter.values())
        labels = list(intent_counter.keys())

        a = fig.add_subplot(212)
        a.pie(x=counts, labels=labels, autopct=lambda pct: self.get_abs_values_for_piechart(pct, counts))
        # a.legend()

        return fig

    def plot_stats(self, stats):

        fig = Figure(figsize=(5, 6), dpi=100, tight_layout=True)
        fig = self.category_stats(fig, stats)
        fig = self.intent_stats(fig, stats)

        canvas = FigureCanvasTkAgg(fig, self)  # self = tkinter frame
        canvas.draw()
        canvas.get_tk_widget().grid(column=2, row=1, columnspan=3, padx=10, sticky="NSEW")
        canvas._tkcanvas.grid(column=2, row=1, columnspan=3, padx=10, sticky="NSEW")

    def part_select(self, event, part):
        print('Got object click', event.x, event.y, part)
        # do stuff ?

    def change_color(self, color):
        current_color = self.song.itemcget(globVal, 'fill')
        next_color = 'white' if current_color != 'white' else color
        # print('546 part {},  nextcolor: {},  current_color  {}, color: {}'\
        #       .format(globVal, next_color, current_color, color))
        self.song.itemconfig(globVal, fill=next_color)
        self.after(1000, self.change_color, color)
        # self.after_id = self.after(1000, self.change_color, color)
        # print('657 id: ', self.after_id)

    def update_pos(self, pos):
        print('update pos: {}, self.part: {}'.format(pos, self.part))
        name = 'slot{}'.format(pos)
        global globVal
        globVal = pos
        global old_color
        old_color = self.songparts[name][1]
        self.color = self.song.itemcget(globVal, 'fill')
        valueChanged = globVal != self.part
        print('558 changed?:  {}'.format(valueChanged))
        if valueChanged:
            self.change_color(self.color)
        self.part = globVal
        self.song.itemconfig(globVal, fill=old_color)

        print('670 old_color: {}, globVal: {}, globVAl.color: {}'.format(old_color, globVal, \
                                                                          self.song.itemcget(globVal, 'fill')))

    def song_position(self):
        self.label_song = tk.Label(self, text="song position", font=TextOutput.LARGE_FONT)
        self.label_song.grid(column=1, row=4, padx=4, pady=20, sticky=tk.E + tk.S)
        names = []
        parts = []
        x_start = 5
        for r, s in zip(range(1, 26), self.slotcolors):
            x1, y1 = x_start, 5
            x2, y2 = (x1 + 20), 50
            part = self.song.create_rectangle(x1, y1, x2, y2, fill=s, tag='slot{}'.format(s))
            name = 'slot{}'.format(r)
            parts.append(part)
            names.append(name)
            x_start += 20
            self.songparts[name] = [part]
            self.songparts[name].append(s)

class Statistik1(tk.Frame):

    LARGE_FONT = ("Avenir", 15)
    SMALL_FONT = ("Avenir", 13)
    BGC = '#CDCDC1'

    def __init__(self, parent, controller):
        tk.Frame.__init__(self, parent)
        # print('Statistik self: ', self)
        self.controller = controller
        self.feedback = None
        self.song = tk.Canvas(self, width=600, height=50)
        self.song.grid(column=3, row=0)
        self.part = None
        self.color = 'yellow'
        self.songparts= {}
        self.category_count = {}
        self.buttons()

        self.songpos = 'slot0'
        self.after_id = None


    def set_feedback(self, feedback):
        self.feedback = feedback
        # print('self.feedback: ', self.feedback)

    def part_select(self, event, part):
        print('Got object click', event.x, event.y, part)
        # do stuff ?



    def buttons(self):
        self.button01 = tk.Button(self, text='quit', font=TextInput.SMALL_FONT, command=quit)
        self.button01.grid(column=0, row=1, padx=1, sticky="NW")

    def category_stats(self, fig, stats):
        cats, counts = [], []

        for cat, intents in stats.items():
            cats.append(cat)
            counts.append(len(intents))

        a = fig.add_subplot(111)
        a.pie(x=counts, labels=cats)

        return fig


    def intent_stats(self, fig, stats):
        intent_counter = defaultdict(int)

        for intents in stats.values():
            for intent in intents:
                intent_counter[intent] += 1

        a = fig.add_subplot(211)
        a.pie(x=intent_counter.values(), labels=intent_counter.keys())

        return fig

    def plot_stats(self, stats):

        fig = Figure(figsize=(3, 3), dpi=100)
        fig = self.category_stats(fig, stats)
        fig = self.intent_stats(fig, stats)

        canvas = FigureCanvasTkAgg(fig, self) # self = tkinter frame
        canvas.show()
        canvas.get_tk_widget().grid(column=0, row=4)
