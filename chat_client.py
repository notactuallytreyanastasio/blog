import asyncio
import json
import websockets
import time
import threading
from asyncio import Queue

class PhoenixClient:
    def __init__(self, uri="wss://thoughts-and-tidbits.fly.dev/socket/websocket"):
        self.uri = uri
        self.ref = 0
        self.running = False
        self.receive_lock = asyncio.Lock()
        self.message_queue = Queue()
        self.response_queues = {}

    def _get_ref(self):
        self.ref += 1
        ref = str(self.ref)
        self.response_queues[ref] = Queue()
        return ref

    def _create_message(self, event_type, topic, payload=None):
        return json.dumps({
            "topic": topic,
            "event": event_type,
            "payload": payload or {},
            "ref": self._get_ref()
        })

    async def connect(self):
        print(f"Connecting to {self.uri}...")
        try:
            self.websocket = await websockets.connect(
                self.uri,
                ssl=True,
                ping_interval=30,
                ping_timeout=10
            )

            # Start the message processor
            self.running = True
            asyncio.create_task(self._process_messages())

            # Join the skeet channel
            join_message = self._create_message("phx_join", "skeet:lobby")
            await self.websocket.send(join_message)
            response = await self.response_queues[join_message["ref"]].get()
            print(f"Join response: {response}")
            return True
        except Exception as e:
            print(f"Connection error: {e}")
            return False

    async def _process_messages(self):
        try:
            while self.running:
                try:
                    message = await self.websocket.recv()
                    data = json.loads(message)

                    if "ref" in data:
                        # This is a response to a sent message
                        queue = self.response_queues.get(data["ref"])
                        if queue:
                            await queue.put(data)
                            if data["event"] != "phx_reply":  # Keep queue for ongoing subscriptions
                                del self.response_queues[data["ref"]]

                    # Handle broadcasts
                    if data.get("event") == "new_message" and "ref" not in data:
                        payload = data.get("payload", {})
                        print(f"\n📨 New message from {payload.get('user')}:")
                        print(f"   {payload.get('body')}")
                        if payload.get('reply_to'):
                            print(f"   ↳ Reply to: {payload.get('reply_to')}")
                        print("\nEnter message (or 'quit' to exit): ", end='', flush=True)
                except websockets.exceptions.ConnectionClosed:
                    break
                except Exception as e:
                    print(f"Error processing message: {e}")
        finally:
            self.running = False

    async def send_message(self, body, user, reply_to=None):
        message = self._create_message(
            "new_message",
            "skeet:lobby",
            {
                "body": body,
                "user": user,
                "reply_to": reply_to
            }
        )
        ref = json.loads(message)["ref"]
        await self.websocket.send(message)
        response = await self.response_queues[ref].get()
        return response

    async def close(self):
        self.running = False
        await self.websocket.close()

async def main():
    client = PhoenixClient()
    if await client.connect():
        try:
            # Get user's name first
            username = input("Enter your username (max 16 chars): ").strip()
            while not username or len(username) > 16:
                username = input("Please enter a valid username (1-16 chars): ").strip()

            print("\nConnected! You can now send messages.")
            print("To reply to a message, start your message with 'r:message_id:'")
            print("Example: r:abc123: This is a reply")
            print("Enter 'quit' to exit")

            # Start message listener in background
            listener = asyncio.create_task(client.listen_for_messages())

            while True:
                try:
                    message = input("\nEnter message (or 'quit' to exit): ").strip()
                    if message.lower() == 'quit':
                        break

                    reply_to = None
                    if message.startswith('r:'):
                        try:
                            _, reply_id, message = message.split(':', 2)
                            reply_to = reply_id.strip()
                            message = message.strip()
                        except ValueError:
                            print("Invalid reply format. Use: r:message_id: your message")
                            continue

                    if not message:
                        continue

                    if len(message) > 250:
                        print("Message too long (max 250 chars)")
                        continue

                    response = await client.send_message(
                        body=message,
                        user=username,
                        reply_to=reply_to
                    )

                    print(f"✓ Message sent (ID: {response['payload']['id']})")

                except Exception as e:
                    print(f"Error sending message: {e}")

        except Exception as e:
            print(f"Error in main loop: {e}")
        finally:
            await client.close()
            if 'listener' in locals():
                await listener
    else:
        print("Failed to connect")

if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("\nGoodbye!")
