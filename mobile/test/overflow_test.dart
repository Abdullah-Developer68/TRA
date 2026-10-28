import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tra_mobile/models/multi_agent_turn.dart';
import 'package:tra_mobile/theme/app_theme.dart';
import 'package:tra_mobile/widgets/chat_input_bar.dart';
import 'package:tra_mobile/widgets/multi_agent_turn_card.dart';
import 'package:tra_mobile/widgets/typing_indicator.dart';

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

  for (final width in [320.0, 360.0, 411.0]) {
    testWidgets('typing bubble + composer do not overflow at ${width}px',
        (tester) async {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      for (final hero in [false, true]) {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.darkTheme,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(1.3)),
              child: child!,
            ),
            home: Scaffold(
              body: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: PendingTurn(
                      prompt: 'Explain the difference between TCP and UDP '
                          'with a real-world scenario',
                    ),
                  ),
                  const Spacer(),
                  ChatInputBar(
                    onSend: (_) {},
                    isGenerating: !hero,
                    hero: hero,
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 400));
        expect(tester.takeException(), isNull);
        expect(
          find.text('Refining your prompt and passing it to multiple agents'),
          findsOneWidget,
        );
      }
    });

    testWidgets('multi agent turn card in all views does not overflow at ${width}px',
        (tester) async {
      tester.view.physicalSize = Size(width, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      for (final view in ['consensus', 'all_models', 'nemotron-ultra', 'debate']) {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.darkTheme,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(1.3)),
              child: child!,
            ),
            home: Scaffold(
              body: SingleChildScrollView(
                child: MultiAgentTurnCard(
                  turn: sampleTurn,
                  activeView: view,
                  onViewChanged: (_) {},
                ),
              ),
            ),
          ),
        );
        expect(tester.takeException(), isNull);
      }
    });
  }
}
