import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/multi_agent_turn.dart';
import '../services/api_service.dart';

enum PipelineStage {
  idle,
  optimizing,
  queryingAgents,
  interAgentDebate,
  synthesizing,
  complete,
  error,
}

class ChatState {
  final List<MultiAgentTurn> turns;
  final List<ThreadSummary> threads;
  final String? activeThreadId;
  final PipelineStage activeStage;
  final String stageMessage;
  final String? error;
  final Map<String, String> activeViews; // turnId -> active view ('all_models' or agentId)

  /// The prompt currently being processed (shown as a user bubble with a
  /// typing indicator until the answer arrives).
  final String? pendingPrompt;

  ChatState({
    required this.turns,
    required this.threads,
    this.activeThreadId,
    required this.activeStage,
    required this.stageMessage,
    this.error,
    required this.activeViews,
    this.pendingPrompt,
  });

  factory ChatState.initial() => ChatState(
        turns: [],
        threads: [],
        activeThreadId: null,
        activeStage: PipelineStage.idle,
        stageMessage: '',
        error: null,
        activeViews: {},
      );

  ChatState copyWith({
    List<MultiAgentTurn>? turns,
    List<ThreadSummary>? threads,
    String? activeThreadId,
    PipelineStage? activeStage,
    String? stageMessage,
    String? error,
    Map<String, String>? activeViews,
    String? pendingPrompt,
    bool clearPendingPrompt = false,
  }) {
    return ChatState(
      turns: turns ?? this.turns,
      threads: threads ?? this.threads,
      activeThreadId: activeThreadId ?? this.activeThreadId,
      activeStage: activeStage ?? this.activeStage,
      stageMessage: stageMessage ?? this.stageMessage,
      error: error,
      activeViews: activeViews ?? this.activeViews,
      pendingPrompt:
          clearPendingPrompt ? null : (pendingPrompt ?? this.pendingPrompt),
    );
  }
}

class ChatNotifier extends Notifier<ChatState> {
  late final ApiService _apiService;

  @override
  ChatState build() {
    _apiService = ref.watch(apiServiceProvider);
    Future.microtask(() => loadThreads());
    return ChatState.initial();
  }

  Future<void> loadThreads() async {
    try {
      final threads = await _apiService.fetchThreads();
      state = state.copyWith(threads: threads);
    } catch (_) {}
  }

  Future<void> selectThread(String? threadId) async {
    if (threadId == null) {
      state = state.copyWith(
        activeThreadId: null,
        turns: [],
        activeStage: PipelineStage.idle,
        stageMessage: '',
      );
      return;
    }

    state = state.copyWith(
      activeThreadId: threadId,
      turns: [],
      activeStage: PipelineStage.idle,
      stageMessage: 'Loading discussion history...',
    );

    try {
      final turns = await _apiService.fetchThreadMessages(threadId);
      final views = <String, String>{};
      for (final t in turns) {
        views[t.turnId] = 'all_models';
      }
      state = state.copyWith(turns: turns, activeViews: views);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void setActiveView(String turnId, String view) {
    final updatedViews = Map<String, String>.from(state.activeViews);
    updatedViews[turnId] = view;
    state = state.copyWith(activeViews: updatedViews);
  }

  Future<void> submitPrompt(String prompt) async {
    final trimmed = prompt.trim();
    if (trimmed.isEmpty) return;

    final currentThread = state.activeThreadId;
    state = state.copyWith(
      activeStage: PipelineStage.optimizing,
      stageMessage: 'Refining your prompt...',
      pendingPrompt: trimmed,
      error: null,
    );

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (state.activeStage == PipelineStage.optimizing) {
        state = state.copyWith(
          activeStage: PipelineStage.queryingAgents,
          stageMessage: 'Passing it to multiple agents...',
        );
      }
    });

    try {
      final turn = await _apiService.sendPrompt(
        prompt: trimmed,
        threadId: currentThread,
      );

      final updatedTurns = [...state.turns, turn];
      final updatedViews = Map<String, String>.from(state.activeViews);
      updatedViews[turn.turnId] = 'all_models';

      state = state.copyWith(
        turns: updatedTurns,
        activeViews: updatedViews,
        activeStage: PipelineStage.complete,
        stageMessage: '',
        activeThreadId: turn.threadId,
        clearPendingPrompt: true,
      );

      loadThreads();
    } catch (e) {
      state = state.copyWith(
        activeStage: PipelineStage.error,
        stageMessage: '',
        error: e.toString().replaceAll('Exception: ', ''),
        clearPendingPrompt: true,
      );
    }
  }

  void resetChat() {
    state = state.copyWith(
      activeThreadId: null,
      turns: [],
      activeStage: PipelineStage.idle,
      stageMessage: '',
      error: null,
      clearPendingPrompt: true,
    );
  }
}

final apiServiceProvider = Provider((ref) => ApiService());

final chatNotifierProvider = NotifierProvider<ChatNotifier, ChatState>(() {
  return ChatNotifier();
});
