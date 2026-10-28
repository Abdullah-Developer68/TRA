# TRA (Multi-Agent Consensus Mobile Platform) — Implementation Plan & TODO

## 📋 Project Overview
TRA is a multi-agent AI deliberation platform built with Flutter (mobile client using Riverpod) and an Express.js TypeScript backend backed by Drizzle ORM and Supabase PostgreSQL. Every user prompt is optimized through an advanced **Prompt Engineering Skill**, evaluated simultaneously across **4 free OpenRouter AI models**, cross-examined through an **inter-agent debate**, and synthesized into the **Rank 1 (Most Accurate Consensus) Solution**.

---

## 🎯 Phase Checklist

### Phase 1: Repository Setup & Git Genesis
- [x] Initialize Git repository with `main` branch
- [x] Configure `.gitignore` (Node, Flutter, environment variables)
- [ ] Create public GitHub repository using `gh repo create`
- [ ] Establish initial commit & push to remote

### Phase 2: Express.js Backend with TypeScript & Drizzle ORM
- [ ] Set up `server/` directory with `package.json`, `tsconfig.json`, and dependencies:
  - `express`, `cors`, `dotenv`, `postgres`, `drizzle-orm`, `ai`, `@openrouter/ai-sdk-provider`
  - Dev: `typescript`, `tsx`, `@types/node`, `@types/express`, `@types/cors`, `drizzle-kit`
- [ ] Configure `server/.env` with Supabase pooler credentials & OpenRouter API key
- [ ] Implement Drizzle ORM schema:
  - `users` (as requested: `id`, `fullName`, `phone`)
  - `chat_threads` (id, title, timestamps)
  - `multi_agent_turns` (turnId, threadId, userPrompt, optimizedPrompt, optimizationDetails, consensusSolution, agentResponses, discussionRounds, rankedAgentIds)
- [ ] Run migration / sync schema to Supabase PostgreSQL pooler
- [ ] Implement Prompt Engineering Skill engine (`src/skills/prompt-engineering.ts`):
  - Persona & Role Framing
  - Task Decomposition
  - Chain-of-Thought (CoT) Elicitation
  - Negative Constraints & Guardrails
  - Structural Delimiters (`<task>`, `<constraints>`, `<guidelines>`)
- [ ] Implement 4-Agent Council & Orchestrator (`src/ai/agents.ts` & `src/ai/orchestrator.ts`):
  - Agent Alpha: `nvidia/nemotron-3-ultra-550b-a55b:free` (Frontier Reasoner)
  - Agent Beta: `cohere/north-mini-code:free` (Code & Algorithmic Specialist)
  - Agent Gamma: `nvidia/nemotron-3.5-lightning:free` (Auditor & Fact Checker)
  - Agent Delta: `liquid/lfm-2.5-2.6b:free` (Lateral Explorer & Nuance)
  - Inter-agent debate arbitration & consensus scoring
- [ ] Create REST routes:
  - `POST /api/multi-agent` (Full prompt optimization + 4 AI deliberation + debate + consensus)
  - `GET /api/threads` & `POST /api/threads` (Thread management)
  - `GET /api/threads/:threadId/messages` (Thread turns history)
  - `GET /api/users` & `POST /api/users` (Users table ORM verification)
  - `GET /api/health`
- [ ] Build & test backend endpoints via automated smoke test

### Phase 3: Flutter Mobile Client with Riverpod
- [ ] Initialize Flutter app in `mobile/` (`flutter create --project-name tra_mobile .`)
- [ ] Configure `pubspec.yaml`:
  - `flutter_riverpod` (State management)
  - `http` (API client)
  - `flutter_markdown` (Rich markdown with syntax tags)
  - `lucide_icons` (Matching web UI icon set)
  - `google_fonts` (Geist / Inter styling)
- [ ] Build Models (`lib/models/`):
  - `MultiAgentTurn`, `AgentResponseItem`, `PromptOptimizationDetails`, `DiscussionTurn`
- [ ] Build API Service (`lib/services/api_service.dart`)
- [ ] Build Riverpod Notifiers (`lib/providers/`):
  - `chat_provider.dart` (turns, activeStage, currentThreadId, selectedAgentId, sendPrompt, loadThreads)
  - `theme_provider.dart` (Obsidian dark theme tokens: `#0B0B0D`, `#111114`, `#2E6BFF`)
- [ ] Build UI Widgets (`lib/widgets/`):
  - `multi_agent_turn_card.dart` (Rank 1 Consensus view, Rank 2-4 Toggles, Debate Drawer)
  - `prompt_skill_inspector.dart` (Prompt engineering breakdown accordion)
  - `pipeline_stepper.dart` (4-phase visual progress: Prompt Skill -> 4 AI Consultation -> Debate -> Consensus)
  - `chat_input_bar.dart` (Clean obsidian input bar with mode pills & send trigger)
  - `history_drawer.dart` (Session history & New Chat trigger)
- [ ] Assemble `HomeScreen` in `lib/screens/home_screen.dart`
- [ ] Test Flutter compilation on Linux/Dart test suite to ensure zero compiler errors

### Phase 4: Verification, Git Checkpoint & Final Delivery
- [ ] Run full end-to-end integration test (Flutter client models <-> Express API <-> Supabase DB <-> OpenRouter models)
- [ ] Git commit all completed deliverables & push to public GitHub repository
- [ ] Provide PR link and comprehensive summary to the user
