# C:\FlutterFinal\remote_pc_control\pc-agent\agent.py
import asyncio
import websockets
import mss
import io
from PIL import Image
import pyautogui
import json
import logging

# -----------------------------
# Logging
# -----------------------------
logging.basicConfig(
    filename="C:\\FlutterFinal\\remote_pc_control\\pc-agent\\agent.log",
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s"
)

# -----------------------------
# Config
# -----------------------------
SERVER = "ws://39.63.55.119:8000"  # Cloud relay server
PC_ID = "pc1"  # unique pairing code / PC ID

# -----------------------------
# Agent functions
# -----------------------------
async def send_screen(ws):
    sct = mss.mss()
    monitor = sct.monitors[1]

    while True:
        img = sct.grab(monitor)
        im = Image.frombytes("RGB", img.size, img.rgb)
        buf = io.BytesIO()
        im.save(buf, format="JPEG", quality=50)
        await ws.send(buf.getvalue())
        await asyncio.sleep(0.1)  # ~10 FPS

async def recv_input(ws):
    async for message in ws:
        try:
            msg = json.loads(message)
            if msg["type"] == "mouse_move":
                x, y = msg["x"], msg["y"]
                screen_w, screen_h = pyautogui.size()
                pyautogui.moveTo(x * screen_w, y * screen_h)
            elif msg["type"] == "mouse_click":
                pyautogui.click()
        except Exception as e:
            logging.error(f"Input error: {e}")

# -----------------------------
# Main agent entry
# -----------------------------
async def agent_main():
    async with websockets.connect(f"{SERVER}/ws/pc/{PC_ID}", max_size=None) as ws:
        logging.info(f"Connected to server: {SERVER} with ID {PC_ID}")
        await asyncio.gather(send_screen(ws), recv_input(ws))

if __name__ == "__main__":
    asyncio.run(agent_main())
