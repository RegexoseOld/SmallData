import re


class Noten:
  def __init__(self, name='?', noteId=[], notes=[], vel= [], tm=[], pitchwheel=[], controllernr=[], ccval=[]):
      self.tempo = 0.4
      self.name = name
      self.noteId = noteId
      self.notes = notes
      self.vel = vel
      self.tm = [(i * self.tempo) for i in tm]
      self.wheel = pitchwheel
      self.ccnr = controllernr
      self.ccval = ccval


  def __repr__(self):
      return "{}".format(self.name)

  def getId(self,id):
      return self.noteId[id]

  def getNote(self, id):
      return self.notes[id]

  def getWheel(self,id):
      return self.wheel[id]

  def getVEL(self,id):
      return self.vel[id]

  def getCtrlnr(self, id):
      return self.ccnr[id]

  def getCCval(self,id):
      return self.ccval[id]

  def getPause(self, id):
      return self.tm[id]


class Chords(Noten):
    def __init__(self, name='?', noteId=0, chords=0, vel=0, tm=[], pitchwheel=0, controllernr=0, ccval=0):
        Noten.__init__(self)
        self.tempo = 1.1
        self.name = name
        self.noteId = noteId
        self.notes = chords
        self.vel = vel
        self.matrix = tm
        self.pause = [(tm[i] * self.tempo) for i in range(len(tm))]
        self.wheel = pitchwheel
        self.ccnr = controllernr
        self.ccval = ccval
        self.slot = re.findall(r'\d+', self.name)[0]
        # print('noten.slot: ', self.slot)

    def getNote(self, id):
        return self.notes[id]

    def getPause(self, id):
        # print('pause: ', self.pause[id])
        return self.pause[id]

    def tempo_change(self, tempo):
        #print('self.matrix pre: ', self.matrix)
        # print('122 tempo von MusicServer: ', tempo)
        self.pause = [(self.matrix[i] * tempo) for i in range(len(self.matrix))]

class Tonarten:
    def __init__(self, anzahl):
        self.anzahl = anzahl
        self.pos_anz = [i for i in range(self.anzahl)]
        self.pos_map = {}
        self.pos_compile()
        self.pos_vals = list(self.pos_map.values())
        self.moll = ([-2, 2], [-2, 1], [-1, 2], [-2, 2], [-2, 1], [-1, 2], [-2, 2])
        self.dur = [[-1, 2], [-2, 2], [-2, 1], [-1, 2], [-2, 2], [-2, 2], [-2, 1]]
        # print('pos_map',self.pos_map)
        self.pos = 0
        self.fibo = 0

    def pos_compile(self):
        pos_map = {i: [] for i in range(7)}
        pos_shifted = []

        keys = list(pos_map.keys())

        for k,v in zip(keys, repeat(pos_shifted, len(keys))):
            pos_map = {k: [i + k for i in v] for k in keys}
            # print('{} : {}'.format(k,[i + k for i in v] ))

        values = list(pos_map.values())
        for i in range(6):
            values[i].append(i)
            values[i].sort()

        self.pos_map = pos_map

        # pos_shifted = [[sum(i)] for i in zip(keys,o_u, o_d)]
        # pos_shifted = [aaa + bbb + ccc for aaa in keys for bbb in o_d for ccc in o_u ]
        # pos_shifted = [[(keys[a] + b), (keys[a] +c)] for a in keys for b in o_d for c in o_u]
        # #pos_shifted = [[(keys[a] + b), (keys[a] +c)] for a in keys for b in o_d for c in o_u]

    def fib(self, m, n):
        m, n = n, n + m
        self.fibo = n
        return n

    def tonart_pointer(self, wunsch):
        if wunsch == 'moll':
            return self.moll

        elif wunsch == 'dur':
            return self.dur

        else:
            print('tonart nicht verfügbar, also moll')
            return self.moll

    def allowed_map(self, tonart):
        sex = self.tonart_pointer(tonart)
        plus = [sex[i][1] for i in range(len(sex))]
        minus = [sex[i][0] for i in range(len(sex))]

        for i, j in enumerate(plus):
            self.fibo = plus[i]
            # print('\n',i,j,'- '*8)
            for p in islice(cycle(plus),i+1,i+7):
                # print(self.fibo, p, self.fib(self.fibo, p))
                sex[i].append(self.fib(p, self.fibo))

        for i, j in enumerate(minus):
            self.fibo = minus[i]
            # print('\n',i,j,'- '*8)
            for p in islice(cycle(minus), i + 1, i + 7):
                # print(self.fibo, p, self.fib(self.fibo, p))
                sex[i].append(self.fib(p, self.fibo))

        for i in sex:
            i.append(0)
            i.sort()

        sex_map = {k: sex[k] for k in self.pos_map}

        # dieser code ist für weitere oktaven, lass ich erstmal weg
        # oct_vals = list(sex_map.values())
        # pos_vals = list(self.pos_map.values())
        #
        # for i, j in zip(pos_vals, range(len(pos_vals))):
        #     # print('i, j', i, j)
        #     for i in pos_vals[j]:
        #         if i < 0:
        #             # print('i < 0 : {} - {}'.format(i, -oct_vals[j][0]))
        #             oct_vals[j].append(i + oct_vals[j][0])
        #
        #         elif i == 0:
        #             oct_vals[j].append(0)
        #
        #         else:
        #             # print('i[j] > 0 : {} + {}'.format(i, oct_vals[j][1]))
        #             oct_vals[j].append(i + oct_vals[j][1])
        #
        # for i, j in zip(oct_vals, range(len(oct_vals))):
        #     oct_vals[j].sort()

        #print('oct_vals', oct_vals)

        # print('allowed_komplett : ', sex_map)
        return sex_map