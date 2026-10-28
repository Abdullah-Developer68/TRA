import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tra_mobile/models/multi_agent_turn.dart';
import 'package:tra_mobile/theme/app_theme.dart';
import 'package:tra_mobile/widgets/multi_agent_turn_card.dart';

MultiAgentTurn _createMockTurn() {
  return MultiAgentTurn(
    threadId: 'thread_1',
    turnId: 'turn_1',
    userPrompt: 'Explain TCP vs UDP',
    optimization: PromptOptimizationDetails(
      originalPrompt: 'Explain TCP vs UDP',
      optimizedPrompt: 'Detailed breakdown with CoT',
      appliedTechniques: ['CoT'],
      intentSummary: 'Networking protocols comparison',
      constraintsAdded: ['No hallucinations'],
      reasoningFramework: 'Deductive',
    ),
    consensusSolution: 'TCP is connection-oriented, UDP is connectionless.',
    consensusRationale: 'Comprehensive comparison.',
    agentResponses: [
      AgentResponseItem(
        agentId: 'nemotron-lightning',
        agentName: 'Nemotron 3.5 Lightning',
        model: 'nvidia/nemotron-3.5-lightning:free',
        role: 'General AI (Nvidia)',
        avatarIcon: 'zap',
        answer: 'TCP guarantees delivery via three-way handshakes.',
        accuracyScore: 95,
        confidence: 90,
        reasoningSteps: ['Step 1'],
        rank: 1,
        optimizedByAgentId: 'nemotron-ultra',
        optimizedByAgentName: 'Nemotron Ultra',
        receivedPrompt: 'Handed prompt from Nemotron Ultra',
      ),
      AgentResponseItem(
        agentId: 'north-mini-code',
        agentName: 'Cohere North Mini',
        model: 'cohere/north-mini-code:free',
        role: 'General AI (Cohere)',
        avatarIcon: 'code',
        answer: 'UDP sends datagrams without connection setup.',
        accuracyScore: 92,
        confidence: 88,
        reasoningSteps: ['Step 1'],
        rank: 2,
        optimizedByAgentId: 'nemotron-lightning',
        optimizedByAgentName: 'Nemotron 3.5 Lightning',
        receivedPrompt: 'Handed prompt from Nemotron Lightning',
      ),
      AgentResponseItem(
        agentId: 'nemotron-ultra',
        agentName: 'Nemotron Ultra',
        model: 'nvidia/nemotron-3-ultra-550b-a55b:free',
        role: 'General AI (Nvidia)',
        avatarIcon: 'brain',
        answer: 'TCP trades throughput for strict reliability.',
        accuracyScore: 90,
        confidence: 85,
        reasoningSteps: ['Step 1'],
        rank: 3,
        optimizedByAgentId: 'north-mini-code',
        optimizedByAgentName: 'Cohere North Mini',
        receivedPrompt: 'Handed prompt from Cohere North Mini',
      ),
    ],
    discussionRounds: [],
    rankedAgentIds: ['nemotron-lightning', 'north-mini-code', 'nemotron-ultra'],
  );
}

void main() {
  testWidgets('renders all 3 models view and attribution', (tester) async {
    final turn = _createMockTurn();
    String activeView = 'all_models';

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (context, setState) {
                return MultiAgentTurnCard(
                  turn: turn,
                  activeView: activeView,
                  onViewChanged: (v) => setState(() => activeView = v),
                );
              },
            ),
          ),
        ),
      ),
    );

    // Verify all 3 models are displayed simultaneously
    expect(find.text('All 3 Models'), findsOneWidget);
    expect(find.text('Nemotron 3.5 Lightning'), findsWidgets);
    expect(find.text('Cohere North Mini'), findsWidgets);
    expect(find.text('Nemotron Ultra'), findsWidgets);

    // Verify attribution
    expect(find.text('Optimized by: Nemotron Ultra'), findsOneWidget);
    expect(find.text('Optimized by: Nemotron 3.5 Lightning'), findsOneWidget);
    expect(find.text('Optimized by: Cohere North Mini'), findsOneWidget);
  });
}
