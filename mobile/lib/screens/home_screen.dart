import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../providers/chat_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/history_drawer.dart';
import '../widgets/multi_agent_turn_card.dart';
import '../widgets/pipeline_stepper.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(chatNotifierProvider);
    final notifier = ref.read(chatNotifierProvider.notifier);
    final isWorking = chatState.activeStage != PipelineStage.idle &&
        chatState.activeStage != PipelineStage.complete &&
        chatState.activeStage != PipelineStage.error;

    return Scaffold(
      backgroundColor: AppTheme.background,
      drawer: const HistoryDrawer(),
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(LucideIcons.brain, size: 13, color: AppTheme.primaryLight),
                  SizedBox(width: 5),
                  Text(
                    'TRA',
                    style: TextStyle(
                      color: AppTheme.primaryLight,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Multi-Agent Council',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, size: 16),
            tooltip: 'New Session',
            onPressed: () => notifier.resetChat(),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // Dynamic Stepper for active multi-agent pipeline
          PipelineStepper(
            stage: chatState.activeStage,
            stageMessage: chatState.stageMessage,
          ),

          // Main Conversation Area
          Expanded(
            child: chatState.turns.isEmpty && !isWorking
                ? _buildEmptyState(context, notifier)
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: chatState.turns.length,
                    itemBuilder: (context, index) {
                      final turn = chatState.turns[index];
                      final activeView = chatState.activeViews[turn.turnId] ?? 'consensus';

                      return MultiAgentTurnCard(
                        turn: turn,
                        activeView: activeView,
                        onViewChanged: (view) => notifier.setActiveView(turn.turnId, view),
                      );
                    },
                  ),
          ),

          // Error Notification Banner
          if (chatState.error != null) ...[
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.error.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.error.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.alertCircle, size: 15, color: AppTheme.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      chatState.error!,
                      style: const TextStyle(color: Color(0xFFFCA5A5), fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Chat Input Bar
          ChatInputBar(
            isGenerating: isWorking,
            onSend: (text) => notifier.submitPrompt(text),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ChatNotifier notifier) {
    const suggestions = [
      'Compare Raft vs Paxos consensus with network partition edge cases',
      'Design a concurrency-safe LRU Cache with O(1) ops in TypeScript',
      'Explain the difference between TCP and UDP with a real-world scenario',
      'Analyze JWT vs Session Cookie architectures for security and revocation',
    ];

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.12),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
              ),
              child: const Icon(LucideIcons.brain, size: 36, color: AppTheme.primaryLight),
            ),
            const SizedBox(height: 16),
            const Text(
              '4-AI Deliberation & Consensus',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 19,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Prompt optimized with Prompt Engineering Skill, deliberated across 4 free OpenRouter AI models, and synthesized into the most accurate solution.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12.5,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            // Suggestions Chips
            Column(
              children: suggestions.map((s) {
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () => notifier.submitPrompt(s),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.card,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.sparkles, size: 14, color: AppTheme.primaryLight),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              s,
                              style: const TextStyle(
                                color: Color(0xFFD4D4D8),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
