import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../models/multi_agent_turn.dart';
import '../theme/app_theme.dart';
import 'prompt_skill_inspector.dart';

/// Card rendering a multi-agent deliberation turn.
///
/// Features:
/// - "All Models" simultaneous view displaying all AI models at the same time.
/// - Clear attribution of which model produced the answer and which peer model optimized its prompt.
/// - One-tap jump buttons on every model card to switch between models.
/// - Low text-heaviness: rationale & secondary metadata are compact/collapsible.
/// - Pure flat dark Zinc UI: hairline borders, zero gradients, zero box shadows.
class MultiAgentTurnCard extends StatefulWidget {
  final MultiAgentTurn turn;
  final String activeView;
  final Function(String view) onViewChanged;

  const MultiAgentTurnCard({
    super.key,
    required this.turn,
    required this.activeView,
    required this.onViewChanged,
  });

  static String cleanName(String name) {
    return name
        .replaceAll('Agent Alpha (', '')
        .replaceAll('Agent Beta (', '')
        .replaceAll('Agent Gamma (', '')
        .replaceAll('Agent Delta (', '')
        .replaceAll('(550B)', '')
        .replaceAll('(2.6B)', '')
        .replaceAll(')', '')
        .trim();
  }

  static String shortName(String name) {
    var s = cleanName(name)
        .replaceAll('(3.5)', '')
        .trim();
    s = s.replaceAll('Nvidia ', '');
    s = s.replaceAll('Cohere ', '');
    s = s.replaceAll('Liquid ', '');
    return s.trim();
  }

  @override
  State<MultiAgentTurnCard> createState() => _MultiAgentTurnCardState();
}

class _MultiAgentTurnCardState extends State<MultiAgentTurnCard> {
  final Set<String> _expandedDirectives = {};
  bool _expandedRationale = false;
  final Set<String> _expandedReasoning = {};

  @override
  Widget build(BuildContext context) {
    final turn = widget.turn;
    final activeView = widget.activeView;

    AgentResponseItem? selectedAgent;
    int selectedIndex = 0;
    if (activeView != 'consensus' &&
        activeView != 'debate' &&
        activeView != 'all_models') {
      final idx = turn.agentResponses.indexWhere((a) => a.agentId == activeView);
      if (idx >= 0) {
        selectedAgent = turn.agentResponses[idx];
        selectedIndex = idx;
      }
    }
    final agentColor =
        AppTheme.agentColors[selectedIndex % AppTheme.agentColors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. User prompt bubble (Flat primary fill, no gradient)
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              margin: const EdgeInsets.only(left: 48, bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: const BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                  topRight: Radius.circular(4),
                ),
              ),
              child: Text(
                turn.userPrompt,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.35,
                ),
              ),
            ),
          ),

          // 2. Peer Prompt-Optimization Inspector (Collapsible & minimal)
          PromptSkillInspector(optimization: turn.optimization),
          const SizedBox(height: 10),

          // 3. Deliberation & Answers Container
          Container(
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(color: AppTheme.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Tab Bar
                Container(
                  decoration: const BoxDecoration(
                    color: AppTheme.background,
                    border: Border(bottom: BorderSide(color: AppTheme.border)),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // Best Answer tab
                        _TabChip(
                          label: 'Best Answer',
                          icon: LucideIcons.award,
                          badge: null,
                          color: AppTheme.primary,
                          isSelected: activeView == 'consensus',
                          onTap: () => widget.onViewChanged('consensus'),
                        ),
                        const SizedBox(width: 6),

                        // View All Models simultaneously tab
                        _TabChip(
                          label: 'All Models',
                          icon: LucideIcons.layoutGrid,
                          badge: '${turn.agentResponses.length}',
                          color: AppTheme.info,
                          isSelected: activeView == 'all_models',
                          onTap: () => widget.onViewChanged('all_models'),
                        ),
                        const SizedBox(width: 6),

                        // Individual Model tabs
                        for (var i = 0;
                            i < turn.agentResponses.length;
                            i++) ...[
                          _TabChip(
                            label: MultiAgentTurnCard.shortName(
                                turn.agentResponses[i].agentName),
                            icon: LucideIcons.bot,
                            badge: '${turn.agentResponses[i].accuracyScore}%',
                            color: AppTheme.agentColors[
                                i % AppTheme.agentColors.length],
                            isSelected:
                                activeView == turn.agentResponses[i].agentId,
                            onTap: () => widget.onViewChanged(
                                turn.agentResponses[i].agentId),
                          ),
                          const SizedBox(width: 6),
                        ],

                        // Debate tab
                        _TabChip(
                          label: 'Debate',
                          icon: LucideIcons.messagesSquare,
                          badge: '${turn.discussionRounds.length}',
                          color: AppTheme.violet,
                          isSelected: activeView == 'debate',
                          onTap: () => widget.onViewChanged('debate'),
                        ),
                      ],
                    ),
                  ),
                ),

                // Main Content View
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (activeView == 'all_models')
                        _buildAllModelsView()
                      else if (activeView == 'consensus')
                        _buildConsensusView()
                      else if (selectedAgent != null)
                        _buildSingleAgentView(selectedAgent, agentColor)
                      else if (activeView == 'debate')
                        _buildDebateView(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── 1. ALL MODELS VIEW (Simultaneous Side-by-Side / Stacked) ──────────────
  Widget _buildAllModelsView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Compact overview banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppTheme.tint(AppTheme.info, 0.08),
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(color: AppTheme.tint(AppTheme.info, 0.2)),
          ),
          child: Row(
            children: [
              const Icon(LucideIcons.layoutGrid,
                  size: 13, color: AppTheme.info),
              const SizedBox(width: 7),
              const Expanded(
                child: Text(
                  'All model outputs from peer-optimized prompts',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xFFBAE6FD),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceHigh,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Text(
                  '${widget.turn.agentResponses.length} Models',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Stacked cards for each model
        for (var i = 0; i < widget.turn.agentResponses.length; i++) ...[
          _buildModelCard(
            agent: widget.turn.agentResponses[i],
            agentColor:
                AppTheme.agentColors[i % AppTheme.agentColors.length],
            isSolo: false,
          ),
          if (i < widget.turn.agentResponses.length - 1)
            const SizedBox(height: 12),
        ],
      ],
    );
  }

  // ─── 2. SINGLE MODEL VIEW ──────────────────────────────────────────────────
  Widget _buildSingleAgentView(AgentResponseItem agent, Color agentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildModelCard(
          agent: agent,
          agentColor: agentColor,
          isSolo: true,
        ),
      ],
    );
  }

  // ─── MODEL CARD COMPONENT (Used in both All Models & Solo) ─────────────────
  Widget _buildModelCard({
    required AgentResponseItem agent,
    required Color agentColor,
    required bool isSolo,
  }) {
    final cleanModelName = MultiAgentTurnCard.cleanName(agent.agentName);
    final optimizerName = agent.optimizedByAgentName ?? 'Peer Agent';
    final hasPeerPrompt =
        agent.receivedPrompt != null && agent.receivedPrompt!.isNotEmpty;
    final isDirectiveExpanded = _expandedDirectives.contains(agent.agentId);
    final isReasoningExpanded = _expandedReasoning.contains(agent.agentId);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Model name + Score + Solo toggle + Copy
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: const BoxDecoration(
              color: AppTheme.card,
              border: Border(bottom: BorderSide(color: AppTheme.border)),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: agentColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              cleanModelName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppTheme.tint(agentColor, 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${agent.accuracyScore}%',
                              style: TextStyle(
                                color: agentColor,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (agent.model.isNotEmpty)
                        Text(
                          agent.model,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 10,
                            fontFamily: 'monospace',
                          ),
                        ),
                    ],
                  ),
                ),

                // Focus/Solo button when in all models mode
                if (!isSolo) ...[
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(LucideIcons.focus,
                        size: 13, color: AppTheme.textSecondary),
                    tooltip: 'Focus on this model',
                    onPressed: () => widget.onViewChanged(agent.agentId),
                  ),
                ],

                // Copy answer button
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(LucideIcons.copy,
                      size: 13, color: AppTheme.textMuted),
                  tooltip: 'Copy answer',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: agent.answer));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Copied $cleanModelName response'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Peer Optimization Lineage Badge (Overflow-safe with Text.rich)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: const BoxDecoration(
              color: AppTheme.surfaceHigh,
              border: Border(bottom: BorderSide(color: AppTheme.border)),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.sparkles,
                    size: 11, color: AppTheme.primaryLight),
                const SizedBox(width: 5),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      text: 'Optimized by: ',
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 11,
                      ),
                      children: [
                        TextSpan(
                          text: optimizerName,
                          style: const TextStyle(
                            color: AppTheme.primaryLight,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (hasPeerPrompt) ...[
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: () {
                      setState(() {
                        if (isDirectiveExpanded) {
                          _expandedDirectives.remove(agent.agentId);
                        } else {
                          _expandedDirectives.add(agent.agentId);
                        }
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isDirectiveExpanded ? 'Hide' : 'Directive',
                            style: const TextStyle(
                              color: AppTheme.info,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            isDirectiveExpanded
                                ? LucideIcons.chevronUp
                                : LucideIcons.chevronDown,
                            size: 11,
                            color: AppTheme.info,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Expandable peer directive
          if (hasPeerPrompt && isDirectiveExpanded)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: AppTheme.background,
                border: Border(bottom: BorderSide(color: AppTheme.border)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Directive crafted by $optimizerName:'.toUpperCase(),
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 5),
                  SelectableText(
                    agent.receivedPrompt!,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

          // Body: Model's answer
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MarkdownBody(
                  data: agent.answer,
                  selectable: true,
                  styleSheet: _buildMarkdownStyle(context),
                ),

                // Peer critique note (if any)
                if (agent.critiqueOfOthers != null &&
                    agent.critiqueOfOthers!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.tint(AppTheme.violet, 0.08),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      border: Border.all(
                          color: AppTheme.tint(AppTheme.violet, 0.25)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Icon(LucideIcons.messageSquare,
                              size: 11, color: AppTheme.violet),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Peer critique: ${agent.critiqueOfOthers!}',
                            style: const TextStyle(
                              color: Color(0xFFDDD6FE),
                              fontSize: 11.5,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Reasoning steps (Collapsible pill)
                if (agent.reasoningSteps.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () {
                      setState(() {
                        if (isReasoningExpanded) {
                          _expandedReasoning.remove(agent.agentId);
                        } else {
                          _expandedReasoning.add(agent.agentId);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceHigh,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isReasoningExpanded
                                ? LucideIcons.chevronDown
                                : LucideIcons.chevronRight,
                            size: 11,
                            color: AppTheme.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'Reasoning (${agent.reasoningSteps.length} steps)',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (isReasoningExpanded) ...[
                    const SizedBox(height: 6),
                    for (final step in agent.reasoningSteps)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 3, left: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ',
                                style: TextStyle(
                                    color: AppTheme.primaryLight,
                                    fontSize: 11)),
                            Expanded(
                              child: Text(
                                step,
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 11,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ],
              ],
            ),
          ),

          // Quick switcher bar: "Jump to other model responses"
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: const BoxDecoration(
              color: AppTheme.card,
              border: Border(top: BorderSide(color: AppTheme.border)),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const Text(
                    'Jump to: ',
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  // Button to view all models
                  if (isSolo) ...[
                    _QuickJumpChip(
                      label: 'All Models',
                      icon: LucideIcons.layoutGrid,
                      color: AppTheme.info,
                      onTap: () => widget.onViewChanged('all_models'),
                    ),
                    const SizedBox(width: 5),
                  ],
                  // Quick buttons for other models
                  for (final peer in widget.turn.agentResponses) ...[
                    if (peer.agentId != agent.agentId) ...[
                      _QuickJumpChip(
                        label: MultiAgentTurnCard.shortName(peer.agentName),
                        icon: LucideIcons.bot,
                        color: AppTheme.textSecondary,
                        onTap: () => widget.onViewChanged(peer.agentId),
                      ),
                      const SizedBox(width: 5),
                    ],
                  ],
                  // Button for Best Answer
                  _QuickJumpChip(
                    label: 'Best Answer',
                    icon: LucideIcons.award,
                    color: AppTheme.primaryLight,
                    onTap: () => widget.onViewChanged('consensus'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── 3. CONSENSUS / BEST ANSWER VIEW ──────────────────────────────────────
  Widget _buildConsensusView() {
    final turn = widget.turn;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Subheader
        Row(
          children: [
            const Icon(LucideIcons.award, size: 16, color: AppTheme.warning),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Rank 1 Best Answer',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: const Icon(LucideIcons.copy,
                  size: 15, color: AppTheme.textMuted),
              tooltip: 'Copy best answer',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: turn.consensusSolution));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Copied best answer to clipboard'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 4),

        // Concise consensus rationale with expandable details (Reduces text heaviness)
        if (turn.consensusRationale.isNotEmpty) ...[
          Container(
            margin: const EdgeInsets.only(top: 4, bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceHigh,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(LucideIcons.checkCheck,
                        size: 12, color: AppTheme.success),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Text(
                        'Verified consensus across 4 models',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: () {
                        setState(() => _expandedRationale = !_expandedRationale);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          _expandedRationale ? 'Less' : 'Why this won',
                          style: const TextStyle(
                            color: AppTheme.primaryLight,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_expandedRationale) ...[
                  const SizedBox(height: 6),
                  const Divider(height: 1, color: AppTheme.border),
                  const SizedBox(height: 6),
                  Text(
                    turn.consensusRationale,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 11.5,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],

        const Divider(height: 1, color: AppTheme.border),
        const SizedBox(height: 12),

        // Consensus Markdown Body
        MarkdownBody(
          data: turn.consensusSolution,
          selectable: true,
          styleSheet: _buildMarkdownStyle(context),
        ),

        const SizedBox(height: 16),

        // Quick Switcher to see responses from all other models
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'COMPARE WITH INDIVIDUAL AI MODELS',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 6),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _QuickJumpChip(
                      label: 'View All 4 Models',
                      icon: LucideIcons.layoutGrid,
                      color: AppTheme.info,
                      onTap: () => widget.onViewChanged('all_models'),
                    ),
                    const SizedBox(width: 6),
                    for (final a in turn.agentResponses) ...[
                      _QuickJumpChip(
                        label:
                            '${MultiAgentTurnCard.shortName(a.agentName)} (${a.accuracyScore}%)',
                        icon: LucideIcons.bot,
                        color: AppTheme.textSecondary,
                        onTap: () => widget.onViewChanged(a.agentId),
                      ),
                      const SizedBox(width: 6),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── 4. DEBATE VIEW ────────────────────────────────────────────────────────
  Widget _buildDebateView() {
    final rounds = widget.turn.discussionRounds;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(LucideIcons.messagesSquare,
                size: 16, color: AppTheme.violet),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Cross-Model Deliberation',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.tint(AppTheme.violet, 0.14),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${rounds.length} Rounds',
                style: const TextStyle(
                  color: AppTheme.violet,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Inter-agent critiques, endorsements, and rebuttals',
          style: TextStyle(color: AppTheme.textMuted, fontSize: 11.5),
        ),
        const SizedBox(height: 12),
        const Divider(height: 1, color: AppTheme.border),
        const SizedBox(height: 12),

        if (rounds.isEmpty)
          const Text(
            'No inter-agent debate records recorded for this turn.',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 12.5),
          )
        else
          for (final round in rounds) _buildDebateItem(round),

        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _QuickJumpChip(
                label: 'Return to Best Answer',
                icon: LucideIcons.award,
                color: AppTheme.primaryLight,
                onTap: () => widget.onViewChanged('consensus'),
              ),
              const SizedBox(width: 6),
              _QuickJumpChip(
                label: 'View All Models',
                icon: LucideIcons.layoutGrid,
                color: AppTheme.info,
                onTap: () => widget.onViewChanged('all_models'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDebateItem(DiscussionRoundItem round) {
    Color typeColor = AppTheme.info;
    IconData typeIcon = LucideIcons.messageCircle;

    if (round.type == 'critique') {
      typeColor = AppTheme.error;
      typeIcon = LucideIcons.circleAlert;
    } else if (round.type == 'endorsement') {
      typeColor = AppTheme.success;
      typeIcon = LucideIcons.circleCheck;
    } else if (round.type == 'synthesis') {
      typeColor = AppTheme.violet;
      typeIcon = LucideIcons.sparkles;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 3, color: typeColor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(typeIcon, size: 12, color: typeColor),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  round.speaker,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: typeColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4),
                                child: Icon(LucideIcons.arrowRight,
                                    size: 10, color: AppTheme.textMuted),
                              ),
                              Flexible(
                                child: Text(
                                  round.targetAgent ?? 'All models',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: AppTheme.tint(typeColor, 0.14),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            round.type.toUpperCase(),
                            style: TextStyle(
                              color: typeColor,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      round.statement,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 12.5,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  MarkdownStyleSheet _buildMarkdownStyle(BuildContext context) {
    return MarkdownStyleSheet(
      p: const TextStyle(color: Color(0xFFE4E4E7), fontSize: 13.5, height: 1.55),
      pPadding: const EdgeInsets.only(bottom: 2),
      h1: const TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.w800,
          height: 1.35),
      h2: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w700,
          height: 1.35),
      h3: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          height: 1.35),
      h4: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w600),
      strong: const TextStyle(
          color: Colors.white, fontWeight: FontWeight.w700),
      code: const TextStyle(
        color: AppTheme.info,
        backgroundColor: AppTheme.surfaceHigh,
        fontFamily: 'monospace',
        fontSize: 12,
      ),
      codeblockPadding: const EdgeInsets.all(10),
      codeblockDecoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: AppTheme.border),
      ),
      blockquote: const TextStyle(
          color: AppTheme.textSecondary, fontStyle: FontStyle.italic),
      blockquoteDecoration: const BoxDecoration(
        border: Border(left: BorderSide(color: AppTheme.primary, width: 3)),
      ),
      listBullet: const TextStyle(color: AppTheme.primaryLight),
      tableHead:
          const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      tableBorder: TableBorder.all(color: AppTheme.border, width: 1),
      horizontalRuleDecoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final String? badge;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabChip({
    required this.label,
    required this.icon,
    required this.badge,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppTheme.tint(color, 0.16) : AppTheme.card,
      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            border: Border.all(
              color: isSelected ? color : AppTheme.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 12.5, color: isSelected ? color : AppTheme.textMuted),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? color : AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 5),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4.5, vertical: 1),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.tint(color, 0.22)
                        : AppTheme.surfaceHigh,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    badge!,
                    style: TextStyle(
                      color: isSelected ? color : AppTheme.textMuted,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickJumpChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickJumpChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surfaceHigh,
      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 11, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
