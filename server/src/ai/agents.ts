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

// Exactly 3 Verified Active Free AI Models
export const COUNCIL_AGENTS: CouncilAgentConfig[] = [
  {
    id: "nemotron-lightning",
    name: "Nemotron 3.5 Lightning",
    model: "nvidia/nemotron-3.5-lightning:free",
    fallbackModel: "nvidia/nemotron-3-ultra-550b-a55b:free",
    provider: "Nvidia",
    color: "#38BDF8",
    iconName: "zap",
    systemInstruction: "You are an intelligent, capable, and rigorous AI assistant. Provide a comprehensive, accurate, and high-quality solution to the user's prompt.",
  },
  {
    id: "north-mini-code",
    name: "Cohere North Mini",
    model: "cohere/north-mini-code:free",
    fallbackModel: "nvidia/nemotron-3.5-lightning:free",
    provider: "Cohere",
    color: "#34D399",
    iconName: "code",
    systemInstruction: "You are an intelligent, capable, and rigorous AI assistant. Provide a comprehensive, accurate, and high-quality solution to the user's prompt.",
  },
  {
    id: "nemotron-ultra",
    name: "Nemotron Ultra (550B)",
    model: "nvidia/nemotron-3-ultra-550b-a55b:free",
    fallbackModel: "cohere/north-mini-code:free",
    provider: "Nvidia",
    color: "#FBBF24",
    iconName: "brain",
    systemInstruction: "You are an intelligent, capable, and rigorous AI assistant. Provide a comprehensive, accurate, and high-quality solution to the user's prompt.",
  },
];
