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
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.tint(AppTheme.primary, 0.14),
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.brain,
                      size: 13, color: AppTheme.primaryLight),
                  SizedBox(width: 5),
                  Text(
                    'TRA',
                    style: TextStyle(
                      color: AppTheme.primaryLight,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Multi-Agent Council',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.squarePen, size: 18),
            tooltip: 'New session',
            onPressed: () => notifier.resetChat(),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          PipelineStepper(
            stage: chatState.activeStage,
            stageMessage: chatState.stageMessage,
          ),
          Expanded(
            child: chatState.turns.isEmpty && !isWorking
                ? _buildEmptyState(context, notifier)
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: chatState.turns.length,
                    itemBuilder: (context, index) {
                      final turn = chatState.turns[index];
                      final activeView =
                          chatState.activeViews[turn.turnId] ?? 'consensus';

                      return MultiAgentTurnCard(
                        turn: turn,
                        activeView: activeView,
                        onViewChanged: (view) =>
                            notifier.setActiveView(turn.turnId, view),
                      );
                    },
                  ),
          ),
          if (chatState.error != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 6, 16, 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.tint(AppTheme.error, 0.10),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(color: AppTheme.tint(AppTheme.error, 0.4)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(LucideIcons.circleAlert,
                      size: 16, color: AppTheme.error),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      chatState.error!,
                      style: const TextStyle(
                        color: Color(0xFFFCA5A5),
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ChatInputBar(
            isGenerating: isWorking,
            onSend: (text) => notifier.submitPrompt(text),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ChatNotifier notifier) {
    const suggestions = <(IconData, String, String)>[
      (
        LucideIcons.network,
        'Distributed systems',
        'Compare Raft vs Paxos consensus with network partition edge cases',
      ),
      (
        LucideIcons.code,
        'Data structures',
        'Design a concurrency-safe LRU Cache with O(1) ops in TypeScript',
      ),
      (
        LucideIcons.globe,
        'Networking',
        'Explain the difference between TCP and UDP with a real-world scenario',
      ),
      (
        LucideIcons.shieldCheck,
        'Security',
        'Analyze JWT vs Session Cookie architectures for security and revocation',
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppTheme.tint(AppTheme.primary, 0.14),
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(color: AppTheme.tint(AppTheme.primary, 0.35)),
            ),
            child: const Icon(LucideIcons.brain,
                size: 26, color: AppTheme.primaryLight),
          ),
          const SizedBox(height: 20),
          const Text(
            'Four minds.\nOne best answer.',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 28,
              height: 1.15,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.9,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Your prompt is sharpened, debated across four free models, and '
            'distilled into the most accurate solution.',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'TRY ONE',
            style: TextStyle(
              color: AppTheme.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          for (final s in suggestions)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                child: InkWell(
                  onTap: () => notifier.submitPrompt(s.$3),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceHigh,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusSm),
                          ),
                          child: Icon(s.$1,
                              size: 16, color: AppTheme.primaryLight),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.$2,
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                s.$3,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12.5,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Icon(LucideIcons.arrowUpRight,
                              size: 14, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
