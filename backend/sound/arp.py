import time

class Arp:
    def __init__(self, anzahl, richt):
        self.anzahl = anzahl
        self.richt = richt
        self.N = 0 # der Wert zur Überprüfung, ob man schon am Ende der Anzahl ist
        self.A = -1 # dieser Wert ist der aktuelle Wert des Zählers und wird zurückgegeben
        self.B = 0 # um diesen Wert erhöht sich  der aktuelle Wert bei jeder Änderung von self.N

    def __iter__(self):
        self.N = 0
        self.A = -1
        self.B = 1
        return self

    def richtung(self, richt):
        self.richt = richt
        print('self.richt: ', self.richt)
        return self.richt

    def __next__(self):
        # print('self.N', self.N)
        if self.N <= self.anzahl-1 and int(self.richt) > 0: # wichtig für den loop
            self.N += 1
            self.A = self.B + self.A
            return self.A

        elif int(self.richt) < 0 and self.N in range(-self.anzahl +1, self.anzahl -1):
            self.N -= 1
            self.A = self.A - self.B
            return self.A

        else:
            raise StopIteration

# arp = Arp(5,1)
#
# for i in arp:
#
#     print('arp.A: ',arp.A)
#     time.sleep(0.7)