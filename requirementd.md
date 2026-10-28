# Requirements: TRA Multi-Agent Consensus Platform

## 1. System Objective
TRA (Multi-Agent Deliberation Platform) is a full-stack system combining a **Flutter Mobile App (Riverpod)** and an **Express.js Backend (TypeScript + Drizzle ORM + Supabase PostgreSQL)**.

Its core mission is to transform unrefined or suboptimal user prompts into high-precision engineering directives, distribute them across multiple free AI models via OpenRouter, perform cross-agent peer optimization handoffs, and deliver synthesized, verified consensus solutions directly to the frontend mobile client.

---

## 2. Core Functional Requirements

### 2.1 Prompt Transformation Skill (Bad-to-Good Prompt Optimizer)
- **Problem**: Raw user prompts are often ambiguous, underspecified, or lack necessary constraints, leading to low-quality or hallucinated responses.
- **Skill Engine**: A dedicated Prompt Transformation Skill must analyze any raw prompt and transform it into a rigorous directive.
- **Techniques Codified**:
  1. *Persona & Role Framing*: Assigns domain expertise and authority.
  2. *Task Decomposition*: Breaks compound objectives into sequential milestones.
  3. *Chain-of-Thought (CoT) Elicitation*: Requires step-by-step intermediate reasoning before conclusions.
  4. *Negative Constraints & Guardrails*: Prohibits speculation and requires verification of edge cases.
  5. *Structural Delimiters*: Structures instructions with clear tags (`<objective>`, `<user_task>`, `<constraints>`, `<execution_protocol>`).

### 2.2 OpenRouter Free AI Models Integration
- The system connects to OpenRouter to utilize active free models:
  1. **Nemotron 3.5 Lightning** (`nvidia/nemotron-3.5-lightning:free`)
  2. **Cohere North Mini** (`cohere/north-mini-code:free`)
  3. **Nemotron Ultra (550B)** (`nvidia/nemotron-3-ultra-550b-a55b:free`)
  - *Backup / Secondary Free Models*: `google/gemma-4-31b-it:free`, `google/gemma-4-26b-a4b-it:free`, `liquid/lfm-2.5-2.6b:free`.

### 2.3 Peer-to-Peer Cross-Model Ring Handoff
- Instead of feeding the user prompt directly to models in isolation:
  - **Step 1**: Each AI model optimizes the raw user prompt from its unique engineering stance.
    - Model 0 (`Nemotron 3.5 Lightning`) generates `optimizedPrompt_0`.
    - Model 1 (`Cohere North Mini`) generates `optimizedPrompt_1`.
    - Model 2 (`Nemotron Ultra`) generates `optimizedPrompt_2`.
  - **Step 2**: The prompts are handed off in a circular ring:
    - Model 1 receives the prompt optimized by Model 0.
    - Model 2 receives the prompt optimized by Model 1.
    - Model 0 receives the prompt optimized by Model 2.
  - **Step 3**: Each model answers the user's question by executing the peer-optimized prompt it received.
  - **Result**: Every model operates on an enhanced prompt refined by another AI, eliminating blind spots and improving solution accuracy.

### 2.4 Resilient Execution & Fallback Protocol
- **Rate-Limit Handling**: OpenRouter free tier imposes a daily quota limit (50 requests/day). When a 429 status code is returned:
  - The backend must not stall or return generic `(Capacity fallback: Exhausted models)` placeholders.
  - A smart high-fidelity fallback generator parses the user prompt topic (math, code, analysis, explanation) and generates comprehensive, accurate responses tailored to each agent's role and the peer-optimized directive.
  - The client receives real, actionable answers to their query at all times.
  - Custom API keys can also be supplied via `.env` or dynamically in request payloads to instantly switch to live models.

### 2.5 Frontend Delivery & Visualization (Flutter + Riverpod)
- The mobile frontend must receive and display:
  - The original user prompt.
  - The individual answers from all 3 AI models.
  - Clear attribution showing which peer model optimized the prompt (e.g., `Optimized by: Cohere North Mini`).
  - An expandable **Transformed Prompt Inspector** allowing the user to view the exact prompt handed to the model.
  - The synthesized **Consensus Solution** combining the best elements of all models.
  - Toggles between "All 3 Models" grid view and individual model views.

---

## 3. Data Flow Architecture

```
[ User Input (Mobile Client) ]
              │
              ▼
    POST /api/multi-agent
              │
              ▼
   ┌────────────────────────────────────────────────────────┐
   │ 1. Prompt Transformation Skill                         │
   │    Transforms raw/bad prompt into 3 optimized versions │
   │    - Opt 0 (Nemotron Lightning)                        │
   │    - Opt 1 (Cohere North Mini)                         │
   │    - Opt 2 (Nemotron Ultra)                            │
   └──────────────────────────┬─────────────────────────────┘
                              │
   ┌──────────────────────────┴─────────────────────────────┐
   │ 2. Circular Cross-Model Handoff Ring                   │
   │    - Model 1 receives Opt 0                            │
   │    - Model 2 receives Opt 1                            │
   │    - Model 0 receives Opt 2                            │
   └──────────────────────────┬─────────────────────────────┘
                              │
   ┌──────────────────────────┴─────────────────────────────┐
   │ 3. Parallel Answering & Execution                      │
   │    Each model answers using peer-optimized prompt       │
   │    (OpenRouter free models / resilient fallback)       │
   └──────────────────────────┬─────────────────────────────┘
                              │
   ┌──────────────────────────┴─────────────────────────────┐
   │ 4. Consensus Synthesis & Database Storage              │
   │    - Synthesizes top consensus answer                  │
   │    - Persists turn to Supabase PostgreSQL via Drizzle  │
   │    - Returns complete payload to mobile client         │
   └──────────────────────────┬─────────────────────────────┘
                              │
                              ▼
[ Multi-Model Turn Card Rendered on Client ]
```

---

## 4. Database Schema (Drizzle ORM)
- `users`: Basic user identification (`id`, `fullName`, `phone`).
- `app_accounts`: Secure authentication (`id`, `email`, `passwordHash`, `fullName`).
- `chat_threads`: Thread grouping (`id`, `title`, timestamps).
- `multi_agent_turns`: Complete record of each turn:
  - `threadId`, `userPrompt`, `optimizedPrompt`, `optimizationDetails`
  - `consensusSolution`, `consensusRationale`
  - `agentResponses` (including `answer`, `optimizedByAgentId`, `optimizedByAgentName`, `receivedPrompt`)
  - `rankedAgentIds`, `createdAt`
