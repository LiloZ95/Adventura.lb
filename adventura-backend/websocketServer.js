const WebSocket = require("ws");
const http = require("http");
const redis = require("./redis");

const server = http.createServer();
const wss = new WebSocket.Server({ server });

const clients = {}; // userId => WebSocket

wss.on("connection", (ws, req) => {
  console.log("🔌 Client connected.");

  ws.on("message", async (msg) => {
    try {
      const data = JSON.parse(msg);
      if (data.type === "auth") {
        const userId = data.userId;
        clients[userId] = ws;
        ws.userId = userId;

        console.log(`✅ Authenticated user ${userId}`);

        // Check if Redis has offline messages
        const offlineKey = `offline_msgs:${userId}`;
        const stored = await redis.lrange(offlineKey, 0, -1);

        for (const raw of stored) {
          const notif = JSON.parse(raw);
          ws.send(JSON.stringify(notif));
        }

        await redis.del(offlineKey); // Clear after sending
      }
    } catch (err) {
      console.error("❌ Invalid message:", err);
    }
  });

  ws.on("close", () => {
    if (ws.userId && clients[ws.userId]) {
      delete clients[ws.userId];
      console.log(`🔌 Disconnected: ${ws.userId}`);
    }
  });
});

function pushToUser(userId, title, body) {
  const payload = { type: "push", title, body };
  const ws = clients[userId];

  if (ws && ws.readyState === WebSocket.OPEN) {
    ws.send(JSON.stringify(payload));
  } else {
    console.log(`💤 Storing offline push for ${userId}`);
    redis.rpush(`offline_msgs:${userId}`, JSON.stringify(payload));
  }
}

server.listen(4000, () => console.log("🧠 WebSocket server running on port 4000"));

module.exports = { pushToUser };
