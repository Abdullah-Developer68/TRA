import { betterAuth } from "better-auth";
import { drizzleAdapter } from "better-auth/adapters/drizzle";
import { emailOTP } from "better-auth/plugins";
import { db } from "./db/index.js";
import { user, session, account, verification } from "./db/schema.js";

// In-memory record of the most recent OTP for testing/development verification
export const recentOtps = new Map<string, { otp: string; type: string; expiresAt: number }>();

export const auth = betterAuth({
  baseURL: process.env.BETTER_AUTH_URL || "http://localhost:5000",
  database: drizzleAdapter(db, {
    provider: "pg",
    schema: { user, session, account, verification },
  }),
  emailAndPassword: {
    enabled: true,
    requireEmailVerification: true,
  },
  plugins: [
    emailOTP({
      otpLength: 6,
      expiresIn: 300, // 5 minutes
      async sendVerificationOTP({ email, otp, type }) {
        const normalized = email.toLowerCase().trim();
        recentOtps.set(normalized, {
          otp,
          type,
          expiresAt: Date.now() + 300 * 1000,
        });

        console.log("\n==============================================");
        console.log("✉️  [BETTER-AUTH EMAIL OTP]");
        console.log(`To:          ${email}`);
        console.log(`Purpose:     ${type}`);
        console.log(`OTP Code:    ${otp}`);
        console.log("Valid for:   5 minutes");
        console.log("==============================================\n");
      },
    }),
  ],
});
