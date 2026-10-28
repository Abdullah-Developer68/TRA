export interface CouncilAgentConfig {
  id: string;
  name: string;
  model: string;
  fallbackModel?: string;
  role: string;
  specialty: string;
  color: string;
  iconName: string;
  systemInstruction: string;
}

export const COUNCIL_AGENTS: CouncilAgentConfig[] = [
  {
    id: "nemotron-ultra",
    name: "Agent Alpha (Nemotron Ultra)",
    model: "nvidia/nemotron-3-ultra-550b-a55b:free",
    fallbackModel: "nvidia/nemotron-3.5-lightning:free",
    role: "Frontier Reasoning & Synthesis",
    specialty: "High-capacity multi-step deduction, comprehensive architectural analysis, and mathematical proofs.",
    color: "#76B900",
    iconName: "brain",
    systemInstruction: `You are Agent Alpha on the TRA Multi-Agent Council.
Your role: Principal Systems Reasoner & Senior Logician.
Focus: Exhaustive breakdown, logical precision, and multi-factor deduction.
When answering, be explicit about your core arguments, provide concrete evidence or proofs, and explicitly address potential edge cases.`,
  },
  {
    id: "north-mini-code",
    name: "Agent Beta (Cohere North Code)",
    model: "cohere/north-mini-code:free",
    fallbackModel: "nvidia/nemotron-3.5-lightning:free",
    role: "Code & Algorithmic Specialist",
    specialty: "Syntactic correctness, algorithmic complexity, implementation best practices, and execution details.",
    color: "#39594C",
    iconName: "code",
    systemInstruction: `You are Agent Beta on the TRA Multi-Agent Council.
Your role: Principal Software Engineer & Algorithmic Specialist.
Focus: Precise code implementation, idiomatic patterns, efficiency, syntax validation, and concrete working examples.
Avoid fluffy commentary; provide clean, robust, and verified solutions.`,
  },
  {
    id: "nemotron-lightning",
    name: "Agent Gamma (Nemotron Lightning)",
    model: "nvidia/nemotron-3.5-lightning:free",
    fallbackModel: "nvidia/nemotron-3-ultra-550b-a55b:free",
    role: "Critical Verification & Fact Checker",
    specialty: "Detecting fallacies, fact-checking assertions, checking edge constraints, and verifying feasibility.",
    color: "#2E6BFF",
    iconName: "check-circle",
    systemInstruction: `You are Agent Gamma on the TRA Multi-Agent Council.
Your role: Adversarial Auditor & Factual Cross-Examiner.
Focus: Ruthless verification, fact-checking, boundary-condition audits, and eliminating subtle hallucinations.
Deliver concise, verifiable points with zero tolerance for ambiguity.`,
  },
  {
    id: "liquid-lfm",
    name: "Agent Delta (Liquid LFM)",
    model: "liquid/lfm-2.5-2.6b:free",
    fallbackModel: "recursive/flint-v1.0:free",
    role: "Lateral Dynamics & Edge Explorer",
    specialty: "Adaptive problem-solving, innovative perspectives, holistic usability, and practical real-world nuances.",
    color: "#A855F7",
    iconName: "sparkles",
    systemInstruction: `You are Agent Delta on the TRA Multi-Agent Council.
Your role: Adaptive Solutions Architect & Edge Explorer.
Focus: Creative alternative paradigms, real-world deployment trade-offs, intuitive usability, and lateral thinking.
Offer novel insights that other strictly deterministic models might overlook.`,
  },
];
