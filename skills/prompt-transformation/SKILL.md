---
name: prompt-transformation
description: Transforms suboptimal or raw user prompts into high-precision, engineered directives using multi-agent persona framing, task decomposition, Chain-of-Thought (CoT), explicit negative constraints, and structured delimiter tagging.
---

# Prompt Transformation Skill

## Overview
The Prompt Transformation Skill converts raw, ambiguous, or poorly specified prompts into clear, structured, and high-fidelity directives before execution.

## Core Transformation Principles
1. **Persona & Domain Framing**: Assigns explicit domain authority, context, and expected perspective to the executing model.
2. **Task Decomposition**: Breaks complex or compound queries into discrete, logically ordered steps.
3. **Chain-of-Thought (CoT) Elicitation**: Requires the model to reason through intermediate deductions and state assumptions before stating final conclusions.
4. **Explicit Negative Constraints & Guardrails**: Defines clear boundaries, prohibits hallucination, and enforces edge-case validation.
5. **Structural Delimiters**: Formats the prompt using unambiguous XML/Markdown tags (`<objective>`, `<user_task>`, `<constraints>`, `<execution_protocol>`).

## Circular Cross-Model Ring Integration
When operating within the TRA Multi-Agent Council:
1. Each active AI model generates its own optimized variant of the user prompt.
2. Prompts are handed off cyclically ($Agent_i \to Agent_{i+1}$, $Agent_n \to Agent_0$).
3. Each model answers using the prompt engineered by its peer, ensuring diverse perspectives and eliminating individual model blind spots.
