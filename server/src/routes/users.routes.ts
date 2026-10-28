import { Router, Request, Response } from "express";
import { db } from "../db/index.js";
import { users } from "../db/schema.js";

const router = Router();

// GET all users
router.get("/", async (_req: Request, res: Response) => {
  try {
    const allUsers = await db.select().from(users);
    return res.json(allUsers);
  } catch (error: any) {
    console.error("Fetch users error:", error);
    return res.status(500).json({ error: error.message || "Failed to fetch users" });
  }
});

// POST new user
router.post("/", async (req: Request, res: Response) => {
  try {
    const { fullName, phone } = req.body;
    const [newUser] = await db.insert(users).values({
      fullName,
      phone,
    }).returning();
    return res.status(201).json(newUser);
  } catch (error: any) {
    console.error("Create user error:", error);
    return res.status(500).json({ error: error.message || "Failed to create user" });
  }
});

export default router;
