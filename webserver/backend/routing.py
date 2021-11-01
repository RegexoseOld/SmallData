from channels.auth import AuthMiddlewareStack
from channels.routing import ProtocolTypeRouter, URLRouter
import webserver.smalldata.routing


application = ProtocolTypeRouter({
    'websocket': AuthMiddlewareStack(
        URLRouter(
            webserver.smalldata.routing.routing.websocket_urlpatterns
        )
    ),
})
