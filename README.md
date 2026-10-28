# TRA — Multi-Agent Consensus Platform

A full-stack, multi-agent AI deliberation system combining **Flutter (Mobile Client with Riverpod)** and an **Express.js (TypeScript Backend with Drizzle ORM and Supabase)**.

Every user prompt is optimized through a dedicated **Prompt Engineering Skill**, concurrently queried across **4 free OpenRouter AI models**, cross-examined through an **inter-agent debate**, and synthesized into the **Rank 1 (Most Accurate Consensus) Solution**.

---

## 🏛️ System Architecture

```
[ Flutter Mobile App (Riverpod) ]
              │
              │  HTTP (REST API)
              ▼
   [ Express.js Backend ]
              │
   ┌──────────┴─────────────────────────┐
   │ 1. Prompt Engineering Skill Engine │
   │    - Persona & System Framing      │
   │    - Task Decomposition            │
   │    - Chain-of-Thought (CoT)        │
   │    - Boundary Guardrails           │
   │    - Structural Delimiters         │
   └──────────┬─────────────────────────┘
              │
   ┌──────────┴───────────────────────────────────────────────────────┐
   │ 2. Parallel Council of 4 Free OpenRouter AI Models               │
   │    - Agent Alpha: nvidia/nemotron-3-ultra-550b-a55b:free         │
   │    - Agent Beta:  cohere/north-mini-code:free                    │
   │    - Agent Gamma: nvidia/nemotron-3.5-lightning:free             │
   │    - Agent Delta: liquid/lfm-2.5-2.6b:free                       │
   └──────────┬───────────────────────────────────────────────────────┘
              │
   ┌──────────┴─────────────────────────┐
   │ 3. Inter-Agent Debate & Scoring    │
   │    - Cross-examination & Critiques │
   │    - Accuracy Scoring (0 - 100)    │
   │    - Rank 1 to 4 Classification    │
   └──────────┬─────────────────────────┘
              │
   ┌──────────┴─────────────────────────┐
   │ 4. Consensus & Supabase Storage    │
   │    - Synthesize Most Accurate Ans  │
   │    - Drizzle ORM + Supabase Pooler │
   │    - Persist Users, Threads, Turns │
   └────────────────────────────────────┘
```

---

## 📱 Mobile UI Features (Flutter + Riverpod)

- **Rank 1 Displayed First**: The verified consensus solution is highlighted and rendered first by default.
- **Interactive Toggles**: Tap between Rank 1, Rank 2, Rank 3, Rank 4, and Inter-Agent Debate.
- **Prompt Engineering Inspector**: Expandable drawer showing techniques enforced, guardrails added, and the full optimized prompt dispatched to the council.
- **Pipeline Progress Stepper**: 4-phase visual indicators showing live progress: `Prompt Skill` ➔ `4 AI Consultation` ➔ `Debate` ➔ `Consensus`.
- **Dark Obsidian Theme**: `#0B0B0D` background, `#111114` cards, and `#2E6BFF` electric blue accents.
- **No Prop Drilling**: Powered by modern `NotifierProvider` from `flutter_riverpod`.

---

## 🚀 Running the Project

### 1. Express Backend (`server/`)
```bash
cd server
npm install
npm run build
npm start
# Server listens on port 5000
```

### 2. Flutter Mobile App (`mobile/`)
```bash
cd mobile
flutter pub get
flutter run
```

---

## 📦 Database & ORM
- **Provider**: Supabase PostgreSQL (IPv4 shared transaction pooler on port 6543)
- **ORM**: Drizzle ORM
- **Tables**: `users`, `chat_threads`, `multi_agent_turns`
