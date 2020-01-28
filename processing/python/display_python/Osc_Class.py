class Listen(OscEventListener):
    def oscEvent(self,m):
        global col, addr
        col = m.arguments()[0]
        # col = int(m.arguments()[0])
        addr = m.addrPattern()
        print("Listen.oscEvent",m.addrPattern(), m.arguments())
