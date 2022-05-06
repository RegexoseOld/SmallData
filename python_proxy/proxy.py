import json
from decouple import config
from klein import Klein
from pythonosc.udp_client import SimpleUDPClient

client = SimpleUDPClient(config('OSC_IP'), int(config('OSC_PORT')))


class Proxy(object):
    app = Klein()

    @app.route(config('PROXY_ADDRESS'), methods=['POST'])
    def forward(self, request, name='NONE'):
        request.setHeader('Content-Type', 'application/json')
        body = json.loads(request.content.read())
        print('forwarding: ', body)
        client.send_message(config('OSC_ROUTE'), body)
        return json.dumps({'success': True})


if __name__ == '__main__':
    proxy = Proxy()
    proxy.app.run(config('HOSTNAME'), config('PORT'))
