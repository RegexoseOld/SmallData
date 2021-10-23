from channels.generic.websocket import WebsocketConsumer, AsyncWebsocketConsumer


class UtteranceConsumer(AsyncWebsocketConsumer):
    group_name = "show"
    n = 0

    async def connect(self):
        print("connecting")
        self.n = 0

        await self.channel_layer.group_add(
            self.group_name, self.channel_name
        )

        await self.accept()
        await self.send(text_data='connected')

    async def receive(self, text_data):
        self.n += 1
        print(text_data)
        await self.send(text_data="echo: " + str(self.n) + " " + text_data)

    async def disconnect(self, close_code):
        print("disconect")
