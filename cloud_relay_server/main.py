# C:\FlutterFinal\remote_pc_control\cloud_relay_server\main.py
from fastapi import FastAPI, WebSocket, WebSocketDisconnect
import uvicorn
from typing import Dict

app = FastAPI()

# -----------------------------
# Connected PCs
# -----------------------------
connected_pcs: Dict[str, WebSocket] = {}

@app.websocket("/ws/pc/{pc_id}")
async def pc_ws(websocket: WebSocket, pc_id: str):
    await websocket.accept()
    connected_pcs[pc_id] = websocket
    try:
        while True:
            data = await websocket.receive_bytes()
            # Relay to mobile if connected
            if pc_id in connected_pcs:
                pass  # for now, PC only
    except WebSocketDisconnect:
        connected_pcs.pop(pc_id, None)

@app.websocket("/ws/mobile/{pc_id}")
async def mobile_ws(websocket: WebSocket, pc_id: str):
    await websocket.accept()
    pc_ws_conn = connected_pcs.get(pc_id)
    if not pc_ws_conn:
        await websocket.close()
        return

    try:
        async def forward_to_pc():
            async for msg in websocket.iter_text():
                await pc_ws_conn.send_text(msg)

        async def forward_to_mobile():
            async for msg in pc_ws_conn.iter_bytes():
                await websocket.send_bytes(msg)

        await asyncio.gather(forward_to_pc(), forward_to_mobile())
    except WebSocketDisconnect:
        pass
    finally:
        if pc_id in connected_pcs:
            await connected_pcs[pc_id].close()
            connected_pcs.pop(pc_id, None)

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
