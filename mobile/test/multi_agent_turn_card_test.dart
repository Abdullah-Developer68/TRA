import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tra_mobile/models/multi_agent_turn.dart';
import 'package:tra_mobile/theme/app_theme.dart';
import 'package:tra_mobile/widgets/multi_agent_turn_card.dart';

void main() {
  final sampleTurn = MultiAgentTurn(
    threadId: 't1',
    turnId: 'turn_1',
    userPrompt: 'Explain quantum computing in simple terms',
    optimization: PromptOptimizationDetails(
      originalPrompt: 'Explain quantum computing in simple terms',
      optimizedPrompt: 'You are a quantum physicist. Explain qubits and superposition with analogies.',
      appliedTechniques: ['System Framing', 'Chain of Thought', 'Constraint Injection'],
      intentSummary: 'Quantum computing explained simply',
      constraintsAdded: ['Keep under 200 words', 'Use qubit analogy'],
      reasoningFramework: 'Peer-to-Peer Ring Optimization',
    ),
    consensusSolution: 'Quantum computers use qubits that can exist in superposition...',
    consensusRationale: 'Cohere North Mini and Nemotron Ultra provided the strongest complementary explanations.',
    agentResponses: [
      AgentResponseItem(
        agentId: 'nemotron-ultra',
        agentName: 'Nvidia Nemotron Ultra (550B)',
        model: 'nvidia/nemotron-3-ultra-550b-a55b:free',
        role: 'General AI (Nvidia)',
        avatarIcon: 'brain',
        answer: 'Superposition allows qubits to be 0 and 1 simultaneously.',
        accuracyScore: 95,
        confidence: 90,
        reasoningSteps: ['Analyzed quantum principles', 'Formulated clear analogies'],
        rank: 1,
        optimizedByAgentId: 'liquid-lfm',
        optimizedByAgentName: 'Liquid LFM (2.6B)',
        receivedPrompt: 'Refined prompt from Liquid LFM...',
      ),
      AgentResponseItem(
        agentId: 'north-mini-code',
        agentName: 'Cohere North Mini',
        model: 'cohere/north-mini-code:free',
        role: 'General AI (Cohere)',
        avatarIcon: 'code',
        answer: 'Unlike classical bits, qubits perform parallel state evaluations.',
        accuracyScore: 92,
        confidence: 88,
        reasoningSteps: ['Structured concise explanation'],
        rank: 2,
        optimizedByAgentId: 'nemotron-ultra',
        optimizedByAgentName: 'Nvidia Nemotron Ultra (550B)',
        receivedPrompt: 'Refined prompt from Nemotron Ultra...',
      ),
    ],
    discussionRounds: [
      DiscussionRoundItem(
        speaker: 'Cohere North Mini',
        targetAgent: 'Nvidia Nemotron Ultra',
        statement: 'Nemotron\'s analogy on superposition is spot on.',
        type: 'endorsement',
      ),
    ],
    rankedAgentIds: ['nemotron-ultra', 'north-mini-code'],
  );

  testWidgets('renders Consensus view by default and shows attribution and jump buttons', (tester) async {
    tester.view.physicalSize = const Size(411, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    String currentView = 'consensus';

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: MultiAgentTurnCard(
                  turn: sampleTurn,
                  activeView: currentView,
                  onViewChanged: (view) {
                    setState(() => currentView = view);
                  },
                ),
              );
            },
          ),
        ),
      ),
    );

    // Verify consensus view
    expect(find.text('Rank 1 Best Answer'), findsOneWidget);
    expect(find.text('Explain quantum computing in simple terms'), findsOneWidget);

    // Verify All Models tab exists
    expect(find.text('All Models'), findsOneWidget);

    // Tap All Models tab
    await tester.tap(find.text('All Models'));
    await tester.pumpAndSettle();

    // Verify that BOTH models are shown simultaneously in All Models view
    expect(find.text('Nvidia Nemotron Ultra'), findsOneWidget);
    expect(find.text('Cohere North Mini'), findsOneWidget);

    // Verify peer optimization attribution is visible for both
    expect(find.textContaining('Liquid LFM'), findsOneWidget);
    expect(find.textContaining('Optimized by: Nvidia Nemotron Ultra (550B)'), findsOneWidget);

    // Verify individual answers are shown simultaneously
    expect(find.textContaining('Superposition allows qubits'), findsOneWidget);
    expect(find.textContaining('parallel state evaluations'), findsOneWidget);

    // Tap quick jump button on Cohere North Mini to go to solo view
    final jumpToNorthMini = find.text('North Mini').last;
    await tester.ensureVisible(jumpToNorthMini);
    await tester.tap(jumpToNorthMini);
    await tester.pumpAndSettle();

    // Now in North Mini solo view
    expect(currentView, 'north-mini-code');
    expect(find.textContaining('Optimized by: Nvidia Nemotron Ultra (550B)'), findsOneWidget);
  });
}
