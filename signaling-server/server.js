const http = require("http");
const { Server } = require("socket.io");

const server = http.createServer();
const io = new Server(server, {
  cors: { origin: "*", methods: ["GET", "POST"] },
});

io.on("connection", (socket) => {
  console.log("✅ Client connected:", socket.id);

  socket.on("offer", (data) => socket.broadcast.emit("offer", data));
  socket.on("answer", (data) => socket.broadcast.emit("answer", data));
  socket.on("candidate", (data) => socket.broadcast.emit("candidate", data));

  socket.on("disconnect", () => console.log("❌ Client disconnected:", socket.id));
});

server.listen(3000, "0.0.0.0", () => console.log("✅ Signaling server listening on port 3000"));
