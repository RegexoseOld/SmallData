import json
from decouple import config
from klein import Klein
from pythonosc.udp_client import SimpleUDPClient

collider_client = SimpleUDPClient(config('COLLIDER_IP'), int(config('COLLIDER_PORT')))
visuals_client = SimpleUDPClient(config('VISUALS_IP'), int(config('VISUALS_PORT')))


class Proxy(object):
    app = Klein()

    @app.route(config('PROXY_ADDRESS'), methods=['POST'])
    def forward(self, request, name='NONE'):
        request.setHeader('Content-Type', 'application/json')
        body = json.loads(request.content.read())
        print('forwarding: ', body)
        collider_client.send_message(config('COLLIDER_ROUTE'), body)
        visuals_client.send_message(config('VISUALS_ROUTE'), body)
        return json.dumps({'success': True})


if __name__ == '__main__':
    proxy = Proxy()
    proxy.app.run(config('HOSTNAME'), config('PORT'))
