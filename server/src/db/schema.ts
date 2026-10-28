import { pgTable, serial, text, varchar, timestamp, jsonb } from "drizzle-orm/pg-core";

// 1. Required users table as requested by the user
export const users = pgTable("users", {
  id: serial("id").primaryKey(),
  fullName: text("full_name"),
  phone: varchar("phone", { length: 256 }),
});

// 2. Authentication accounts table for mobile Signup / Login
export const appAccounts = pgTable("app_accounts", {
  id: serial("id").primaryKey(),
  email: text("email").notNull().unique(),
  passwordHash: text("password_hash").notNull(),
  fullName: text("full_name").notNull(),
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow(),
});

// 3. Chat threads for conversation grouping
export const chatThreads = pgTable("chat_threads", {
  id: text("id").primaryKey(),
  title: text("title").notNull().default("Multi-Agent Deliberation"),
  createdAt: timestamp("created_at").defaultNow().notNull(),
  updatedAt: timestamp("updated_at").defaultNow().notNull(),
});

export interface AgentOptimizationRecord {
  optimizerAgentId: string;
  optimizerAgentName: string;
  optimizedPrompt: string;
  summary: string;
}

export interface AgentOptimizationRecord {
  optimizerAgentId: string;
  optimizerAgentName: string;
  optimizedPrompt: string;
  summary: string;
}

export interface AgentResponseItem {
  agentId: string;
  agentName: string;
  model: string;
  role: string;
  avatarIcon: string;
  answer: string;
  accuracyScore: number;
  confidence: number;
  reasoningSteps: string[];
  critiqueOfOthers?: string;
  rank: number;
  optimizedByAgentId?: string;
  optimizedByAgentName?: string;
  receivedPrompt?: string;
}

export interface PromptOptimizationDetails {
  appliedTechniques: string[];
  intentSummary: string;
  constraintsAdded: string[];
  reasoningFramework: string;
}

export interface DiscussionRoundItem {
  speaker: string;
  targetAgent?: string;
  statement: string;
  type: "critique" | "endorsement" | "rebuttal" | "synthesis";
}

// 4. Multi-agent turns records
export const multiAgentTurns = pgTable("multi_agent_turns", {
  id: text("id").primaryKey(),
  threadId: text("thread_id").notNull().references(() => chatThreads.id, { onDelete: "cascade" }),
  userPrompt: text("user_prompt").notNull(),
  optimizedPrompt: text("optimized_prompt").notNull(),
  optimizationDetails: jsonb("optimization_details").$type<PromptOptimizationDetails>(),
  consensusSolution: text("consensus_solution").notNull(),
  consensusRationale: text("consensus_rationale"),
  agentResponses: jsonb("agent_responses").$type<AgentResponseItem[]>().notNull(),
  discussionRounds: jsonb("discussion_rounds").$type<DiscussionRoundItem[]>(),
  rankedAgentIds: jsonb("ranked_agent_ids").$type<string[]>(),
  createdAt: timestamp("created_at").defaultNow().notNull(),
});
