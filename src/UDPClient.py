from pythonosc.udp_client import SimpleUDPClient

class ClientIO(SimpleUDPClient):

    def __init__(self, ip, port):
        super(ClientIO, self).__init__(ip, port)
        self.send_msg('ClientIO Connection!! ip {}  port {}'.format(ip, port))
        print('Client Connection: {} port {}'.format(ip, port))

    def send_msg(self, msg):
        self.send_message("/message", msg)

    def send_trigger(self, msg):
        self.send_message("/trigger", msg)

    def calibrate(self, msg):
        self.send_message("/calibrate", msg)

    def send_buildmap(self, map):
        self.send_message("/buildmap", map)

    def melo_edit(self, map):
        self.send_message("/melo_edit", map)

    def send_controlmap(self, map):
        self.send_message("/controlmap", map)

    def send_start(self, msg):
        self.send_message("/start", msg)