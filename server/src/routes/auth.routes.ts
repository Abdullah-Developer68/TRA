import { Router, Request, Response } from "express";
import crypto from "crypto";
import { db } from "../db/index.js";
import { appAccounts } from "../db/schema.js";
import { eq } from "drizzle-orm";

const router = Router();

function hashPassword(password: string): string {
  return crypto.createHash("sha256").update(password).digest("hex");
}

// POST /api/auth/signup
router.post("/signup", async (req: Request, res: Response) => {
  try {
    const { email, password, fullName } = req.body;
    if (!email || !password || !fullName) {
      return res.status(400).json({ error: "Email, password, and full name are required." });
    }

    const normalizedEmail = String(email).trim().toLowerCase();
    const existing = await db
      .select()
      .from(appAccounts)
      .where(eq(appAccounts.email, normalizedEmail))
      .limit(1);

    if (existing.length > 0) {
      return res.status(409).json({ error: "An account with this email already exists." });
    }

    const passwordHash = hashPassword(String(password));
    const [created] = await db
      .insert(appAccounts)
      .values({
        email: normalizedEmail,
        passwordHash,
        fullName: String(fullName).trim(),
      })
      .returning();

    return res.status(201).json({
      id: created.id,
      email: created.email,
      fullName: created.fullName,
      createdAt: created.createdAt,
    });
  } catch (err: any) {
    console.error("Signup error:", err);
    return res.status(500).json({ error: err.message || "Signup failed." });
  }
});

// POST /api/auth/login
router.post("/login", async (req: Request, res: Response) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ error: "Email and password are required." });
    }

    const normalizedEmail = String(email).trim().toLowerCase();
    const [account] = await db
      .select()
      .from(appAccounts)
      .where(eq(appAccounts.email, normalizedEmail))
      .limit(1);

    if (!account) {
      return res.status(401).json({ error: "Invalid email or password." });
    }

    const hash = hashPassword(String(password));
    if (account.passwordHash !== hash) {
      return res.status(401).json({ error: "Invalid email or password." });
    }

    return res.json({
      id: account.id,
      email: account.email,
      fullName: account.fullName,
      createdAt: account.createdAt,
    });
  } catch (err: any) {
    console.error("Login error:", err);
    return res.status(500).json({ error: err.message || "Login failed." });
  }
});

export default router;
