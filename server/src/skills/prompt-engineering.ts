/**
 * Prompt Engineering Skill Engine
 * 
 * Codifies proven prompt engineering techniques:
 * 1. Persona & Role Framing
 * 2. Task Decomposition
 * 3. Chain-of-Thought (CoT) Elicitation
 * 4. Explicit Guardrails & Negative Constraints
 * 5. Structural Delimiters (<task>, <constraints>, <guidelines>)
 */

export interface PromptOptimizationResult {
  originalPrompt: string;
  optimizedPrompt: string;
  appliedTechniques: string[];
  intentSummary: string;
  constraintsAdded: string[];
  reasoningFramework: string;
}

const PROMPT_OPTIMIZER_SYSTEM_INSTRUCTION = `You are a Principal Prompt Engineer and Cognitive Systems Architect.
Your task is to take a raw user prompt and optimize it according to advanced prompt engineering principles before it is dispatched to a multi-agent reasoning council.

You MUST apply the following techniques:
1. Persona & System Role Framing: Establish clear domain authority and context.
2. Task Decomposition: Break complex goals into sequential sub-tasks.
3. Chain-of-Thought (CoT): Mandate intermediate reasoning steps before final conclusions.
4. Explicit Guardrails & Negative Constraints: Specify boundaries, prohibit hallucination, and require edge-case handling.
5. Structural Delimiters: Use clear markdown sections and tags (<task>, <constraints>, <guidelines>, <evaluation_criteria>).

Respond strictly in valid JSON matching this schema:
{
  "intentSummary": "Brief 1-sentence synopsis of what the user seeks",
  "appliedTechniques": ["Chain-of-Thought", "Task Decomposition", "Role Framing", "Constraint Guardrails", "Delimiter Tagging"],
  "constraintsAdded": ["Specific boundary 1", "Specific boundary 2"],
  "reasoningFramework": "Step-by-step logic framework introduced",
  "optimizedPrompt": "The full, high-fidelity optimized prompt text"
}`;

/**
 * Have a specific AI model optimize the prompt from its own perspective.
 */
export async function optimizePromptWithModel(
  rawPrompt: string,
  modelName: string,
  modelId: string,
  apiKey?: string
): Promise<{ optimizedPrompt: string; summary: string }> {
  const token = apiKey || process.env.OPENROUTER_API_KEY;
  if (!token) {
    return createAgentSpecificAlgorithmicOptimization(rawPrompt, modelName);
  }

  try {
    const response = await fetch("https://openrouter.ai/api/v1/chat/completions", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${token}`,
        "Content-Type": "application/json",
        "HTTP-Referer": "http://localhost:5000",
        "X-Title": "TRA Multi-Agent Council",
      },
      body: JSON.stringify({
        model: modelId,
        messages: [
          {
            role: "system",
            content: `You are ${modelName}, a lead AI architect. Your task is to analyze the user's prompt, sharpen it, apply Chain-of-Thought directives, add strict constraints, and return an optimized prompt for another AI model to execute. Respond with ONLY the improved prompt text. Keep it direct, structured, and rigorous.`,
          },
          {
            role: "user",
            content: `Optimize and sharpen this prompt for another AI model:\\n\\n\"\"\"${rawPrompt}\"\"\"`,
          },
        ],
        temperature: 0.2,
        max_tokens: 700,
      }),
      signal: AbortSignal.timeout(9000),
    });

    if (response.ok) {
      const data: any = await response.json();
      const content = (data?.choices?.[0]?.message?.content || "").trim();
      if (content.length > 20) {
        return {
          optimizedPrompt: content,
          summary: `Reframed with Chain-of-Thought and structural constraints by ${modelName}`,
        };
      }
    }
  } catch {
    // Fall back to agent-specific algorithmic optimization
  }

  return createAgentSpecificAlgorithmicOptimization(rawPrompt, modelName);
}

export function createAgentSpecificAlgorithmicOptimization(
  rawPrompt: string,
  modelName: string
): { optimizedPrompt: string; summary: string } {
  const trimmed = rawPrompt.trim();
  const optimizedPrompt = `### [OPTIMIZED DIRECTIVE — PREPARED BY ${modelName.toUpperCase()}]
<objective>
Execute the following user request with rigorous accuracy, verified logical deductions, and no hallucination.
</objective>

<user_task>
${trimmed}
</user_task>

### [EXECUTION PROTOCOL]
1. Deconstruct core requirements and address implicit assumptions.
2. Provide step-by-step reasoning (Chain-of-Thought) before the final conclusion.
3. Validate boundary conditions, potential edge cases, and failure modes.
4. Conclude with a definitive, clean, and actionable output.`;

  return {
    optimizedPrompt,
    summary: `Sharpened with CoT and edge-case guardrails by ${modelName}`,
  };
}

export async function optimizeUserPrompt(
  rawPrompt: string,
  apiKey?: string
): Promise<PromptOptimizationResult> {
  const token = apiKey || process.env.OPENROUTER_API_KEY;

  if (token) {
    const candidateModels = [
      "nvidia/nemotron-3.5-lightning:free",
      "nvidia/nemotron-3-ultra-550b-a55b:free",
      "cohere/north-mini-code:free",
    ];

    for (const model of candidateModels) {
      try {
        const response = await fetch("https://openrouter.ai/api/v1/chat/completions", {
          method: "POST",
          headers: {
            "Authorization": `Bearer ${token}`,
            "Content-Type": "application/json",
            "HTTP-Referer": "http://localhost:5000",
            "X-Title": "TRA Multi-Agent Prompt Optimizer",
          },
          body: JSON.stringify({
            model,
            messages: [
              { role: "system", content: PROMPT_OPTIMIZER_SYSTEM_INSTRUCTION },
              {
                role: "user",
                content: `Optimize the following user prompt for high-precision multi-agent reasoning:\n\n"""${rawPrompt}"""`,
              },
            ],
            temperature: 0.2,
            max_tokens: 1000,
          }),
          signal: AbortSignal.timeout(8000),
        });

        if (!response.ok) continue;

        const data: any = await response.json();
        const msg = data?.choices?.[0]?.message;
        const rawText = (msg?.content || msg?.reasoning || "").trim();
        if (!rawText) continue;

        const jsonMatch = rawText.match(/```(?:json)?\s*([\s\S]*?)\s*```/) || [null, rawText];
        const parsed = JSON.parse(jsonMatch[1] || rawText);

        if (parsed && parsed.optimizedPrompt) {
          return {
            originalPrompt: rawPrompt,
            optimizedPrompt: parsed.optimizedPrompt,
            appliedTechniques: parsed.appliedTechniques || [
              "Chain-of-Thought (CoT)",
              "Role & Persona Framing",
              "Task Decomposition",
              "Negative Constraints",
            ],
            intentSummary: parsed.intentSummary || "Optimized user query for multi-agent precision",
            constraintsAdded: parsed.constraintsAdded || [
              "Strict factual adherence",
              "Structured verifiable reasoning",
            ],
            reasoningFramework: parsed.reasoningFramework || "Step-by-step cognitive deduction",
          };
        }
      } catch {
        // Fallback on next model or algorithmic generator
      }
    }
  }

  return createAlgorithmicOptimization(rawPrompt);
}

export function createAlgorithmicOptimization(rawPrompt: string): PromptOptimizationResult {
  const trimmed = rawPrompt.trim();
  const intentSummary = `Synthesize a rigorous, verifiable solution for: "${trimmed.slice(0, 80)}${trimmed.length > 80 ? '...' : ''}"`;

  const optimizedPrompt = `### [ROLE & OBJECTIVE]
You are a Principal AI Subject-Matter Expert and Formal Analyst on the TRA Council. Provide an exhaustive, accurate, and logically airtight response to the following user task.

### [USER QUERY]
<task>
${trimmed}
</task>

### [REASONING GUIDELINES & CHAIN-OF-THOUGHT]
1. Deconstruct the primary objectives and any implicit assumptions present in the task.
2. Outline your intermediate reasoning step-by-step before delivering concrete conclusions.
3. If multiple methodologies or perspectives exist, compare their trade-offs with explicit criteria.
4. Validate edge cases, potential failure modes, or boundary conditions.

### [GUARDRAILS & CONSTRAINTS]
- Adhere strictly to verified facts, established principles, or syntactically valid code.
- If certain parameters are ambiguous, explicitly state your assumptions rather than hallucinating facts.
- Use clear structural headers, bullet points, or code snippets with language tags where appropriate.
- Conclude with a definitive, actionable summary.`;

  return {
    originalPrompt: rawPrompt,
    optimizedPrompt,
    appliedTechniques: [
      "Role & Persona Framing",
      "Task Decomposition",
      "Chain-of-Thought (CoT)",
      "Boundary Constraints & Guardrails",
      "Structural Delimiter Tagging",
    ],
    intentSummary,
    constraintsAdded: [
      "No speculative hallucination; state assumptions explicitly",
      "Structured step-by-step reasoning requirement",
      "Edge case and failure mode validation",
    ],
    reasoningFramework: "Decomposition -> Step-by-Step Deduction -> Verification -> Synthesis",
  };
}
