import { pgTable, serial, text, varchar, timestamp, jsonb } from "drizzle-orm/pg-core";

// 1. Required users table as requested by the user
export const users = pgTable("users", {
  id: serial("id").primaryKey(),
  fullName: text("full_name"),
  phone: varchar("phone", { length: 256 }),
});

// 2. Chat threads for conversation grouping
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

// 3. Multi-agent discussion and consensus records
export const multiAgentTurns = pgTable("multi_agent_turns", {
  id: text("id").primaryKey(),
  threadId: text("thread_id").notNull().references(() => chatThreads.id, { onDelete: "cascade" }),
  userPrompt: text("user_prompt").notNull(),
  optimizedPrompt: text("optimized_prompt").notNull(),
  optimizationDetails: jsonb("optimization_details").$type<PromptOptimizationDetails>(),
  consensusSolution: text("consensus_solution").notNull(), // Rank 1: Most Accurate Solution
  consensusRationale: text("consensus_rationale"),
  agentResponses: jsonb("agent_responses").$type<AgentResponseItem[]>().notNull(),
  discussionRounds: jsonb("discussion_rounds").$type<DiscussionRoundItem[]>(),
  rankedAgentIds: jsonb("ranked_agent_ids").$type<string[]>(),
  createdAt: timestamp("created_at").defaultNow().notNull(),
});
