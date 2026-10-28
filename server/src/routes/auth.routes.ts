import { Router, Request, Response } from "express";
import crypto from "crypto";
import { db } from "../db/index.js";
import { appAccounts, appSessions } from "../db/schema.js";
import { eq } from "drizzle-orm";

const router = Router();

function hashPassword(password: string): string {
  return crypto.createHash("sha256").update(password).digest("hex");
}

function generateSessionToken(): string {
  return "sess_" + crypto.randomBytes(24).toString("hex");
}

/**
 * POST /api/auth/signup
 * Registers user with email and password, creates session, and logs in immediately.
 */
router.post("/signup", async (req: Request, res: Response) => {
  try {
    const { email, password, fullName } = req.body;
    if (!email || !password || !fullName) {
      return res.status(400).json({ error: "Email, password, and full name are required." });
    }

    const normalizedEmail = String(email).trim().toLowerCase();
    const cleanPassword = String(password).trim();
    const cleanName = String(fullName).trim();

    if (cleanPassword.length < 6) {
      return res.status(400).json({ error: "Password must be at least 6 characters long." });
    }

    // Check if account already exists
    const existing = await db
      .select()
      .from(appAccounts)
      .where(eq(appAccounts.email, normalizedEmail))
      .limit(1);

    if (existing.length > 0) {
      return res.status(409).json({ error: "An account with this email already exists." });
    }

    const passwordHash = hashPassword(cleanPassword);
    const [created] = await db
      .insert(appAccounts)
      .values({
        email: normalizedEmail,
        passwordHash,
        fullName: cleanName,
      })
      .returning();

    // Create session token (valid for 30 days)
    const token = generateSessionToken();
    const expiresAt = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000);

    await db.insert(appSessions).values({
      token,
      accountId: created.id,
      expiresAt,
    });

    return res.status(201).json({
      success: true,
      token,
      user: {
        id: created.id,
        email: created.email,
        fullName: created.fullName,
      },
      message: "Account created successfully.",
    });
  } catch (err: any) {
    console.error("Signup error:", err);
    return res.status(500).json({ error: err.message || "Signup failed." });
  }
});

/**
 * POST /api/auth/login
 * Validates email and password, creates session token, and returns user profile.
 */
router.post("/login", async (req: Request, res: Response) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ error: "Email and password are required." });
    }

    const normalizedEmail = String(email).trim().toLowerCase();
    const cleanPassword = String(password).trim();

    const [account] = await db
      .select()
      .from(appAccounts)
      .where(eq(appAccounts.email, normalizedEmail))
      .limit(1);

    if (!account) {
      return res.status(401).json({ error: "Invalid email or password." });
    }

    const hash = hashPassword(cleanPassword);
    if (account.passwordHash !== hash) {
      return res.status(401).json({ error: "Invalid email or password." });
    }

    // Generate fresh session token
    const token = generateSessionToken();
    const expiresAt = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000);

    await db.insert(appSessions).values({
      token,
      accountId: account.id,
      expiresAt,
    });

    return res.json({
      success: true,
      token,
      user: {
        id: account.id,
        email: account.email,
        fullName: account.fullName,
      },
      message: "Logged in successfully.",
    });
  } catch (err: any) {
    console.error("Login error:", err);
    return res.status(500).json({ error: err.message || "Login failed." });
  }
});

/**
 * POST /api/auth/logout
 * Terminates user's session token.
 */
router.post("/logout", async (req: Request, res: Response) => {
  try {
    const authHeader = req.headers.authorization;
    const token = authHeader?.startsWith("Bearer ")
      ? authHeader.slice(7).trim()
      : (req.body?.token as string | undefined);

    if (token) {
      await db.delete(appSessions).where(eq(appSessions.token, token));
    }

    return res.json({ success: true, message: "Logged out successfully." });
  } catch (err: any) {
    console.error("Logout error:", err);
    return res.status(500).json({ error: "Logout failed." });
  }
});

/**
 * GET /api/auth/me
 * Retrieves user profile based on bearer token.
 */
router.get("/me", async (req: Request, res: Response) => {
  try {
    const authHeader = req.headers.authorization;
    const token = authHeader?.startsWith("Bearer ") ? authHeader.slice(7).trim() : undefined;

    if (!token) {
      return res.status(401).json({ error: "Unauthorized. No token provided." });
    }

    const [sessionRecord] = await db
      .select()
      .from(appSessions)
      .where(eq(appSessions.token, token))
      .limit(1);

    if (!sessionRecord || (sessionRecord.expiresAt && sessionRecord.expiresAt < new Date())) {
      return res.status(401).json({ error: "Session expired or invalid." });
    }

    const [account] = await db
      .select()
      .from(appAccounts)
      .where(eq(appAccounts.id, sessionRecord.accountId))
      .limit(1);

    if (!account) {
      return res.status(404).json({ error: "User account not found." });
    }

    return res.json({
      user: {
        id: account.id,
        email: account.email,
        fullName: account.fullName,
      },
    });
  } catch (err: any) {
    console.error("Auth me error:", err);
    return res.status(500).json({ error: "Failed to retrieve user profile." });
  }
});

export default router;
