import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import chatRoutes from "./routes/chat.routes.js";
import usersRoutes from "./routes/users.routes.js";
import { db } from "./db/index.js";
import { users } from "./db/schema.js";

dotenv.config();

const app = express();
const port = process.env.PORT || 5000;

app.use(cors({ origin: "*" }));
app.use(express.json({ limit: "10mb" }));

// Health Check
app.get("/api/health", async (_req, res) => {
  try {
    const userCount = await db.select().from(users).limit(1);
    res.json({
      status: "ok",
      service: "TRA Multi-Agent Backend",
      timestamp: new Date().toISOString(),
      database: "connected",
    });
  } catch (error: any) {
    res.json({
      status: "degraded",
      service: "TRA Multi-Agent Backend",
      databaseError: error.message,
    });
  }
});

// Mount Routes
app.use("/api", chatRoutes);
app.use("/api/users", usersRoutes);

app.listen(port, () => {
  console.log(`🚀 TRA Multi-Agent Server running on port ${port}`);
  console.log(`📡 Endpoints available:`);
  console.log(`   - POST /api/multi-agent`);
  console.log(`   - GET  /api/threads`);
  console.log(`   - GET  /api/threads/:id/messages`);
  console.log(`   - GET  /api/users`);
  console.log(`   - GET  /api/health`);
});

export default app;
