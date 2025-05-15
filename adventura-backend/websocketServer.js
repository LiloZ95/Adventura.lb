const WebSocket = require("ws");
const http = require("http");
const { connection: redis } = require("./utils/redis");

const server = http.createServer();
const wss = new WebSocket.Server({ server });

const clients = {}; // userId => WebSocket

wss.on("connection", (ws, req) => {
	console.log("🔌 Client connected.");

	ws.on("message", async (msg) => {
		try {
			const data = JSON.parse(msg);
			console.log("📡 Received WebSocket message:", data);
			if (data.type === "auth" && data.userId) {
				const userId = data.userId;
				clients[userId] = ws;
				ws.userId = userId;
				console.log(`✅ Authenticated user ${userId}`);
			} else {
				console.log("❌ Missing or invalid userId in auth message");
			}

			// Check if Redis has offline messages
			const userId = data.userId;
			const offlineKey = `offline_msgs:${userId}`;
			const stored = await redis.lrange(offlineKey, 0, -1);

			for (const raw of stored) {
				const notif = JSON.parse(raw);
				ws.send(JSON.stringify(notif));
			}

			await redis.del(offlineKey); // Clear after sending
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

async function pushToUser(userId, title, body) {
	const payload = { type: "push", title, body };
	const ws = clients[userId];

	if (ws && ws.readyState === WebSocket.OPEN) {
		ws.send(JSON.stringify(payload));
		console.log(`📬 Pushed to ${userId}: ${title}`);
	} else {
		console.log(`💤 Storing offline push for ${userId}`);
		await redis.rpush(`offline_msgs:${userId}`, JSON.stringify(payload));
	}
}

function startWebSocketServer(port = 4000) {
	server.listen(port, () => {
		console.log(`🧠 WebSocket server running on port ${port}`);
	});
}

module.exports = { pushToUser, startWebSocketServer };
