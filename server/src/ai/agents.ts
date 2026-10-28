export interface CouncilAgentConfig {
  id: string;
  name: string;
  model: string;
  fallbackModel?: string;
  provider: string;
  color: string;
  iconName: string;
  systemInstruction: string;
}

// 4 General-Purpose AI Models given the identical prompt
export const COUNCIL_AGENTS: CouncilAgentConfig[] = [
  {
    id: "nemotron-ultra",
    name: "Nvidia Nemotron Ultra (550B)",
    model: "nvidia/nemotron-3-ultra-550b-a55b:free",
    fallbackModel: "nvidia/nemotron-3.5-lightning:free",
    provider: "Nvidia",
    color: "#76B900",
    iconName: "brain",
    systemInstruction: "You are an intelligent, capable, and rigorous AI assistant. Provide a comprehensive, accurate, and high-quality solution to the user's prompt.",
  },
  {
    id: "north-mini-code",
    name: "Cohere North Mini",
    model: "cohere/north-mini-code:free",
    fallbackModel: "nvidia/nemotron-3.5-lightning:free",
    provider: "Cohere",
    color: "#39594C",
    iconName: "code",
    systemInstruction: "You are an intelligent, capable, and rigorous AI assistant. Provide a comprehensive, accurate, and high-quality solution to the user's prompt.",
  },
  {
    id: "nemotron-lightning",
    name: "Nvidia Nemotron 3.5 Lightning",
    model: "nvidia/nemotron-3.5-lightning:free",
    fallbackModel: "nvidia/nemotron-3-ultra-550b-a55b:free",
    provider: "Nvidia",
    color: "#2E6BFF",
    iconName: "zap",
    systemInstruction: "You are an intelligent, capable, and rigorous AI assistant. Provide a comprehensive, accurate, and high-quality solution to the user's prompt.",
  },
  {
    id: "liquid-lfm",
    name: "Liquid LFM (2.6B)",
    model: "liquid/lfm-2.5-2.6b:free",
    fallbackModel: "recursive/flint-v1.0:free",
    provider: "Liquid AI",
    color: "#A855F7",
    iconName: "sparkles",
    systemInstruction: "You are an intelligent, capable, and rigorous AI assistant. Provide a comprehensive, accurate, and high-quality solution to the user's prompt.",
  },
];
