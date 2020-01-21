# tested with oscP5 0.9.9 and 2.0.4
add_library('oscP5') 
 
addr = "?"
 
class Listen(OscEventListener):
    def oscEvent(self,m):
        global col, addr
        col = m.arguments()[0]
        # col = int(m.arguments()[0])
        addr = m.addrPattern()
        print("Listen.oscEvent",m.addrPattern(), m.arguments())
 
def setup():
    global osc, loc, col
    size(600, 600, P3D)
    osc = OscP5(this, 5040)
    loc = NetAddress('127.0.0.1', 5040) # send to self
    osc.addListener(Listen()) # assigning a listener to class Listen
    col = 100
 
def draw():
    global col,addr
    background(col)
    # print(addr)
 
def keyPressed():
    global osc,loc
    msg = OscMessage("/test")
    msg.add(random(255))
    osc.send(msg,loc)
    print("sending message",msg.addrPattern())
 
def stop():
    global osc
    osc.dispose()
