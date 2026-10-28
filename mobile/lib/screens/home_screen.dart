import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../providers/chat_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/history_drawer.dart';
import '../widgets/multi_agent_turn_card.dart';
import '../widgets/typing_indicator.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatNotifierProvider);
    final notifier = ref.read(chatNotifierProvider.notifier);

    // Keep the in-flight message and typing bubble in view.
    ref.listen<String?>(
      chatNotifierProvider.select((s) => s.pendingPrompt),
      (prev, next) {
        if (next != null) _scrollToEnd();
      },
    );

    final isWorking = chatState.activeStage != PipelineStage.idle &&
        chatState.activeStage != PipelineStage.complete &&
        chatState.activeStage != PipelineStage.error;
    final isEmpty = chatState.turns.isEmpty && !isWorking;

    final errorBanner = chatState.error == null
        ? const SizedBox.shrink()
        : Container(
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
          );

    return Scaffold(
      backgroundColor: AppTheme.background,
      drawer: const HistoryDrawer(),
      appBar: AppBar(
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1),
        ),
        title: const Text(
          'Multi-Agent Council',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
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
      body: isEmpty
          ? _buildHero(notifier, errorBanner)
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    controller: _scroll,
                    padding: const EdgeInsets.all(16),
                    children: [
                      for (final turn in chatState.turns)
                        MultiAgentTurnCard(
                          turn: turn,
                          activeView:
                              chatState.activeViews[turn.turnId] ?? 'all_models',
                          onViewChanged: (view) =>
                              notifier.setActiveView(turn.turnId, view),
                        ),
                      if (isWorking && chatState.pendingPrompt != null)
                        PendingTurn(prompt: chatState.pendingPrompt!),
                    ],
                  ),
                ),
                errorBanner,
                ChatInputBar(
                  isGenerating: isWorking,
                  onSend: notifier.submitPrompt,
                ),
              ],
            ),
    );
  }

  Widget _buildHero(ChatNotifier notifier, Widget errorBanner) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'How can I help you?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
              ),
            ),
            const SizedBox(height: 24),
            ChatInputBar(
              hero: true,
              isGenerating: false,
              onSend: notifier.submitPrompt,
            ),
            errorBanner,
          ],
        ),
      ),
    );
  }
}
