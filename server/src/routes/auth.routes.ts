import { Router, Request, Response } from "express";
import { toNodeHandler } from "better-auth/node";
import { auth, recentOtps } from "../auth.js";
import { db } from "../db/index.js";
import { user as userTable, session as sessionTable } from "../db/schema.js";
import { eq } from "drizzle-orm";

const router = Router();

// 1. Mount Better Auth native handlers for standard client libraries
router.all("/better/*", toNodeHandler(auth));

// 2. High-level mobile endpoints utilizing Better Auth under the hood

/**
 * POST /api/auth/signup
 * Registers user with email and password, then triggers an email verification OTP.
 */
router.post("/signup", async (req: Request, res: Response) => {
  try {
    const { email, password, fullName } = req.body;
    if (!email || !password || !fullName) {
      return res.status(400).json({ error: "Email, password, and full name are required." });
    }

    const normalizedEmail = String(email).trim().toLowerCase();

    // Check if user already exists
    const existing = await db
      .select()
      .from(userTable)
      .where(eq(userTable.email, normalizedEmail))
      .limit(1);

    if (existing.length > 0) {
      return res.status(409).json({ error: "An account with this email already exists." });
    }

    // Create user via Better Auth
    try {
      await auth.api.signUpEmail({
        body: {
          email: normalizedEmail,
          password: String(password),
          name: String(fullName).trim(),
        },
      });
    } catch (signUpErr: any) {
      console.warn("Better Auth signUp error:", signUpErr);
      // If error indicates email already exists or validation
      if (signUpErr?.message?.includes("already exists")) {
        return res.status(409).json({ error: "An account with this email already exists." });
      }
    }

    // Dispatch verification OTP via Better Auth emailOTP plugin
    try {
      await auth.api.sendVerificationOTP({
        body: {
          email: normalizedEmail,
          type: "email-verification",
        },
      });
    } catch (otpErr) {
      console.warn("Failed to dispatch verification OTP via plugin:", otpErr);
    }

    const cachedOtp = recentOtps.get(normalizedEmail)?.otp;

    return res.status(201).json({
      success: true,
      requiresOtp: true,
      email: normalizedEmail,
      type: "email-verification",
      message: `A 6-digit OTP has been sent to ${normalizedEmail}.`,
      // For local development convenience if external SMTP is not hooked up:
      devOtp: process.env.NODE_ENV !== "production" ? cachedOtp : undefined,
    });
  } catch (err: any) {
    console.error("Signup error:", err);
    return res.status(500).json({ error: err.message || "Signup failed." });
  }
});

/**
 * POST /api/auth/login
 * Validates email and password, then dispatches an OTP to the user's email.
 */
router.post("/login", async (req: Request, res: Response) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ error: "Email and password are required." });
    }

    const normalizedEmail = String(email).trim().toLowerCase();

    // Verify user exists in database
    const [userRecord] = await db
      .select()
      .from(userTable)
      .where(eq(userTable.email, normalizedEmail))
      .limit(1);

    if (!userRecord) {
      return res.status(401).json({ error: "Invalid email or password." });
    }

    // Validate credentials using Better Auth signInEmail
    let credentialCheckPassed = false;
    try {
      const resSignIn = await auth.api.signInEmail({
        body: {
          email: normalizedEmail,
          password: String(password),
        },
      });
      if (resSignIn) {
        credentialCheckPassed = true;
      }
    } catch (authErr: any) {
      // Better auth might return requireEmailVerification or invalid credentials
      const msg = authErr?.message || "";
      if (msg.toLowerCase().includes("verify") || msg.toLowerCase().includes("email_not_verified")) {
        credentialCheckPassed = true; // Credentials were valid, but email verification required
      } else {
        console.warn("Better Auth password verification failed:", authErr);
      }
    }

    if (!credentialCheckPassed) {
      return res.status(401).json({ error: "Invalid email or password." });
    }

    // Credentials verified! Now trigger OTP
    try {
      await auth.api.sendVerificationOTP({
        body: {
          email: normalizedEmail,
          type: "sign-in",
        },
      });
    } catch (otpErr) {
      console.warn("Better Auth sendVerificationOTP error:", otpErr);
    }

    const cachedOtp = recentOtps.get(normalizedEmail)?.otp;

    return res.json({
      success: true,
      requiresOtp: true,
      email: normalizedEmail,
      type: "sign-in",
      message: `A 6-digit login OTP has been sent to ${normalizedEmail}.`,
      devOtp: process.env.NODE_ENV !== "production" ? cachedOtp : undefined,
    });
  } catch (err: any) {
    console.error("Login error:", err);
    return res.status(500).json({ error: err.message || "Login failed." });
  }
});

/**
 * POST /api/auth/verify-otp
 * Verifies the 6-digit OTP and establishes an authenticated session.
 */
router.post("/verify-otp", async (req: Request, res: Response) => {
  try {
    const { email, otp, type } = req.body;
    if (!email || !otp) {
      return res.status(400).json({ error: "Email and OTP code are required." });
    }

    const normalizedEmail = String(email).trim().toLowerCase();
    const cleanOtp = String(otp).trim();
    const otpType = (type as string) || "sign-in";

    let verified = false;

    // 1. Check with Better Auth emailOTP plugin
    try {
      if (otpType === "sign-in") {
        const result = await auth.api.signInEmailOTP({
          body: {
            email: normalizedEmail,
            otp: cleanOtp,
          },
        });
        if (result) verified = true;
      } else {
        const result = await auth.api.verifyEmailOTP({
          body: {
            email: normalizedEmail,
            otp: cleanOtp,
          },
        });
        if (result) verified = true;
      }
    } catch (pluginErr: any) {
      console.warn("Better Auth verifyEmailOTP attempt:", pluginErr?.message || pluginErr);
    }

    // 2. Check development cache fallback
    if (!verified) {
      const cached = recentOtps.get(normalizedEmail);
      if (cached && cached.otp === cleanOtp && Date.now() < cached.expiresAt) {
        verified = true;
        recentOtps.delete(normalizedEmail);
      }
    }

    if (!verified) {
      return res.status(400).json({ error: "Invalid or expired OTP code. Please try again." });
    }

    // Mark email as verified and retrieve user record
    const [userRecord] = await db
      .select()
      .from(userTable)
      .where(eq(userTable.email, normalizedEmail))
      .limit(1);

    if (!userRecord) {
      return res.status(404).json({ error: "User account not found." });
    }

    await db
      .update(userTable)
      .set({ emailVerified: true, updatedAt: new Date() })
      .where(eq(userTable.id, userRecord.id));

    // Create session token
    const sessionToken = `sess_${Date.now()}_${Math.random().toString(36).substring(2, 10)}`;
    const expiresAt = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000); // 30 days

    await db.insert(sessionTable).values({
      id: `sid_${Date.now()}_${Math.random().toString(36).substring(2, 8)}`,
      token: sessionToken,
      userId: userRecord.id,
      expiresAt,
      createdAt: new Date(),
      updatedAt: new Date(),
    });

    return res.json({
      success: true,
      token: sessionToken,
      user: {
        id: userRecord.id,
        email: userRecord.email,
        fullName: userRecord.name,
        emailVerified: true,
      },
      message: "Authentication successful.",
    });
  } catch (err: any) {
    console.error("Verify OTP error:", err);
    return res.status(500).json({ error: err.message || "Failed to verify OTP." });
  }
});

/**
 * POST /api/auth/resend-otp
 * Dispatches a new OTP to the specified email.
 */
router.post("/resend-otp", async (req: Request, res: Response) => {
  try {
    const { email, type } = req.body;
    if (!email) {
      return res.status(400).json({ error: "Email is required." });
    }

    const normalizedEmail = String(email).trim().toLowerCase();
    const otpType = (type as "sign-in" | "email-verification") || "sign-in";

    try {
      await auth.api.sendVerificationOTP({
        body: {
          email: normalizedEmail,
          type: otpType,
        },
      });
    } catch (e) {
      console.warn("Resend OTP error:", e);
    }

    const cachedOtp = recentOtps.get(normalizedEmail)?.otp;

    return res.json({
      success: true,
      message: `A fresh OTP code has been dispatched to ${normalizedEmail}.`,
      devOtp: process.env.NODE_ENV !== "production" ? cachedOtp : undefined,
    });
  } catch (err: any) {
    console.error("Resend OTP error:", err);
    return res.status(500).json({ error: err.message || "Failed to resend OTP." });
  }
});

/**
 * POST /api/auth/logout
 * Terminates the user's active session.
 */
router.post("/logout", async (req: Request, res: Response) => {
  try {
    const authHeader = req.headers.authorization;
    const token = authHeader?.startsWith("Bearer ")
      ? authHeader.slice(7).trim()
      : (req.body?.token as string | undefined);

    if (token) {
      await db.delete(sessionTable).where(eq(sessionTable.token, token));
    }

    try {
      await auth.api.signOut({ headers: req.headers as any });
    } catch {
      // Ignore if already signed out
    }

    return res.json({ success: true, message: "Logged out successfully." });
  } catch (err: any) {
    console.error("Logout error:", err);
    return res.status(500).json({ error: "Logout failed." });
  }
});

/**
 * GET /api/auth/me
 * Returns current authenticated user details.
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
      .from(sessionTable)
      .where(eq(sessionTable.token, token))
      .limit(1);

    if (!sessionRecord || sessionRecord.expiresAt < new Date()) {
      return res.status(401).json({ error: "Session expired or invalid." });
    }

    const [userRecord] = await db
      .select()
      .from(userTable)
      .where(eq(userTable.id, sessionRecord.userId))
      .limit(1);

    if (!userRecord) {
      return res.status(404).json({ error: "User not found." });
    }

    return res.json({
      user: {
        id: userRecord.id,
        email: userRecord.email,
        fullName: userRecord.name,
        emailVerified: userRecord.emailVerified,
      },
    });
  } catch (err: any) {
    console.error("Auth me error:", err);
    return res.status(500).json({ error: "Failed to retrieve user." });
  }
});

export default router;
