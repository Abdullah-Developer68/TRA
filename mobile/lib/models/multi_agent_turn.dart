class AgentResponseItem {
  final String agentId;
  final String agentName;
  final String model;
  final String role;
  final String avatarIcon;
  final String answer;
  final int accuracyScore;
  final int confidence;
  final List<String> reasoningSteps;
  final String? critiqueOfOthers;
  final int rank;
  final String? optimizedByAgentId;
  final String? optimizedByAgentName;
  final String? receivedPrompt;

  AgentResponseItem({
    required this.agentId,
    required this.agentName,
    required this.model,
    required this.role,
    required this.avatarIcon,
    required this.answer,
    required this.accuracyScore,
    required this.confidence,
    required this.reasoningSteps,
    this.critiqueOfOthers,
    required this.rank,
    this.optimizedByAgentId,
    this.optimizedByAgentName,
    this.receivedPrompt,
  });

  factory AgentResponseItem.fromJson(Map<String, dynamic> json) {
    return AgentResponseItem(
      agentId: json['agentId'] as String? ?? '',
      agentName: json['agentName'] as String? ?? 'Agent',
      model: json['model'] as String? ?? '',
      role: json['role'] as String? ?? '',
      avatarIcon: json['avatarIcon'] as String? ?? 'brain',
      answer: json['answer'] as String? ?? '',
      accuracyScore: (json['accuracyScore'] as num?)?.toInt() ?? 80,
      confidence: (json['confidence'] as num?)?.toInt() ?? 80,
      reasoningSteps: (json['reasoningSteps'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      critiqueOfOthers: json['critiqueOfOthers'] as String?,
      rank: (json['rank'] as num?)?.toInt() ?? 1,
      optimizedByAgentId: json['optimizedByAgentId'] as String?,
      optimizedByAgentName: json['optimizedByAgentName'] as String?,
      receivedPrompt: json['receivedPrompt'] as String?,
    );
  }
}

class PromptOptimizationDetails {
  final String originalPrompt;
  final String optimizedPrompt;
  final List<String> appliedTechniques;
  final String intentSummary;
  final List<String> constraintsAdded;
  final String reasoningFramework;

  PromptOptimizationDetails({
    required this.originalPrompt,
    required this.optimizedPrompt,
    required this.appliedTechniques,
    required this.intentSummary,
    required this.constraintsAdded,
    required this.reasoningFramework,
  });

  factory PromptOptimizationDetails.fromJson(Map<String, dynamic> json) {
    return PromptOptimizationDetails(
      originalPrompt: json['originalPrompt'] as String? ?? '',
      optimizedPrompt: json['optimizedPrompt'] as String? ?? '',
      appliedTechniques: (json['appliedTechniques'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      intentSummary: json['intentSummary'] as String? ?? '',
      constraintsAdded: (json['constraintsAdded'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      reasoningFramework: json['reasoningFramework'] as String? ?? '',
    );
  }
}

class DiscussionRoundItem {
  final String speaker;
  final String? targetAgent;
  final String statement;
  final String type; // critique, endorsement, rebuttal, synthesis

  DiscussionRoundItem({
    required this.speaker,
    this.targetAgent,
    required this.statement,
    required this.type,
  });

  factory DiscussionRoundItem.fromJson(Map<String, dynamic> json) {
    return DiscussionRoundItem(
      speaker: json['speaker'] as String? ?? '',
      targetAgent: json['targetAgent'] as String?,
      statement: json['statement'] as String? ?? '',
      type: json['type'] as String? ?? 'critique',
    );
  }
}

class MultiAgentTurn {
  final String threadId;
  final String turnId;
  final String userPrompt;
  final PromptOptimizationDetails optimization;
  final String consensusSolution;
  final String consensusRationale;
  final List<AgentResponseItem> agentResponses;
  final List<DiscussionRoundItem> discussionRounds;
  final List<String> rankedAgentIds;

  MultiAgentTurn({
    required this.threadId,
    required this.turnId,
    required this.userPrompt,
    required this.optimization,
    required this.consensusSolution,
    required this.consensusRationale,
    required this.agentResponses,
    required this.discussionRounds,
    required this.rankedAgentIds,
  });

  factory MultiAgentTurn.fromJson(Map<String, dynamic> json) {
    return MultiAgentTurn(
      threadId: json['threadId'] as String? ?? '',
      turnId: json['turnId'] as String? ?? json['id'] as String? ?? '',
      userPrompt: json['userPrompt'] as String? ?? json['user_prompt'] as String? ?? '',
      optimization: json['optimization'] != null
          ? PromptOptimizationDetails.fromJson(json['optimization'] as Map<String, dynamic>)
          : PromptOptimizationDetails(
              originalPrompt: json['user_prompt'] as String? ?? '',
              optimizedPrompt: json['optimized_prompt'] as String? ?? '',
              appliedTechniques: ['Peer Prompt Optimization'],
              intentSummary: 'Cross-agent optimized query',
              constraintsAdded: [],
              reasoningFramework: 'Peer-to-Peer Ring Optimization',
            ),
      consensusSolution: json['consensusSolution'] as String? ?? json['consensus_solution'] as String? ?? '',
      consensusRationale: json['consensusRationale'] as String? ?? json['consensus_rationale'] as String? ?? '',
      agentResponses: (json['agentResponses'] as List<dynamic>?)
              ?.map((e) => AgentResponseItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          (json['agent_responses'] as List<dynamic>?)
              ?.map((e) => AgentResponseItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      discussionRounds: (json['discussionRounds'] as List<dynamic>?)
              ?.map((e) => DiscussionRoundItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          (json['discussion_rounds'] as List<dynamic>?)
              ?.map((e) => DiscussionRoundItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      rankedAgentIds: (json['rankedAgentIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          (json['ranked_agent_ids'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

class ThreadSummary {
  final String id;
  final String title;

  ThreadSummary({required this.id, required this.title});

  factory ThreadSummary.fromJson(Map<String, dynamic> json) {
    return ThreadSummary(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Multi-Agent Session',
    );
  }
}
