from channels.generic.websocket import AsyncWebsocketConsumer


class UtteranceConsumer(AsyncWebsocketConsumer):
    group_name = "show"

    async def connect(self):
        print("connecting")

        await self.channel_layer.group_add(
            self.group_name, self.channel_name
        )

        await self.accept()
        await self.channel_layer.group_send(
            self.group_name, {
                "type": "confirmation",
                "text": "connected voll geil"
            })

    async def disconnect(self, close_code):
        print("disconect")

    async def confirmation(self, event):
        await self.send(text_data=event["text"])
        print('In confirmation callback:', event["text"])
