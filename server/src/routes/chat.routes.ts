import { Router, Request, Response } from "express";
import { runMultiAgentPipeline } from "../ai/orchestrator.js";
import { db } from "../db/index.js";
import { chatThreads, multiAgentTurns } from "../db/schema.js";
import { desc, eq, asc } from "drizzle-orm";

const router = Router();

// Multi-agent execution route
router.post("/multi-agent", async (req: Request, res: Response) => {
  try {
    const { prompt, threadId } = req.body;
    if (!prompt || typeof prompt !== "string" || prompt.trim().length === 0) {
      return res.status(400).json({ error: "Prompt must be a non-empty string." });
    }

    const result = await runMultiAgentPipeline(prompt.trim(), threadId);
    return res.json(result);
  } catch (error: any) {
    console.error("Multi-agent route error:", error);
    return res.status(500).json({ error: error.message || "Failed to process multi-agent reasoning" });
  }
});

// Get all threads
router.get("/threads", async (_req: Request, res: Response) => {
  try {
    const threads = await db
      .select()
      .from(chatThreads)
      .orderBy(desc(chatThreads.updatedAt))
      .limit(50);
    return res.json(threads);
  } catch (error: any) {
    console.error("Fetch threads error:", error);
    return res.status(500).json({ error: "Failed to fetch threads" });
  }
});

// Create thread
router.post("/threads", async (req: Request, res: Response) => {
  try {
    const title = req.body?.title || "New Multi-Agent Session";
    const id = `thread_${Date.now()}_${Math.random().toString(36).substring(2, 7)}`;
    await db.insert(chatThreads).values({
      id,
      title,
      createdAt: new Date(),
      updatedAt: new Date(),
    });
    return res.json({ id, title });
  } catch (error: any) {
    console.error("Create thread error:", error);
    return res.status(500).json({ error: "Failed to create thread" });
  }
});

// Get messages for a thread
router.get("/threads/:threadId/messages", async (req: Request, res: Response) => {
  try {
    const threadId = String(req.params.threadId);
    const turns = await db
      .select()
      .from(multiAgentTurns)
      .where(eq(multiAgentTurns.threadId, threadId))
      .orderBy(asc(multiAgentTurns.createdAt));
    return res.json(turns);
  } catch (error: any) {
    console.error("Fetch messages error:", error);
    return res.status(500).json({ error: "Failed to fetch messages" });
  }
});

export default router;
