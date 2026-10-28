import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../models/multi_agent_turn.dart';
import '../theme/app_theme.dart';

class MultiAgentTurnCard extends StatelessWidget {
  final MultiAgentTurn turn;
  final String activeView;
  final Function(String view) onViewChanged;

  const MultiAgentTurnCard({
    super.key,
    required this.turn,
    required this.activeView,
    required this.onViewChanged,
  });

  static String cleanName(String name) => name
      .replaceAll('Agent Alpha (', '')
      .replaceAll('Agent Beta (', '')
      .replaceAll('Agent Gamma (', '')
      .replaceAll(')', '')
      .trim();

  @override
  Widget build(BuildContext context) {
    final agents = turn.agentResponses;
    final isAllModels = activeView == 'all_models' || activeView == 'consensus';

    AgentResponseItem? selectedAgent;
    int selectedIndex = 0;
    if (!isAllModels) {
      final idx = agents.indexWhere((a) => a.agentId == activeView);
      if (idx >= 0) {
        selectedAgent = agents[idx];
        selectedIndex = idx;
      } else if (agents.isNotEmpty) {
        selectedAgent = agents.first;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. User Prompt Bubble
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              margin: const EdgeInsets.only(left: 48, bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                  topRight: Radius.circular(4),
                ),
              ),
              child: Text(
                turn.userPrompt,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14.5,
                  height: 1.4,
                ),
              ),
            ),
          ),

          // 2. Multi-Model Selector Bar (All 3 Models or Single Model View)
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
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // View All 3 Models Button
                        _TabChip(
                          label: 'All 3 Models',
                          icon: LucideIcons.layoutGrid,
                          badge: '${agents.length}',
                          color: AppTheme.primaryLight,
                          isSelected: isAllModels,
                          onTap: () => onViewChanged('all_models'),
                        ),
                        const SizedBox(width: 8),
                        // Individual Model Tabs
                        for (var i = 0; i < agents.length; i++) ...[
                          _TabChip(
                            label: cleanName(agents[i].agentName),
                            icon: LucideIcons.bot,
                            badge: null,
                            color: AppTheme.agentColors[
                                i % AppTheme.agentColors.length],
                            isSelected: activeView == agents[i].agentId,
                            onTap: () => onViewChanged(agents[i].agentId),
                          ),
                          if (i < agents.length - 1) const SizedBox(width: 8),
                        ],
                      ],
                    ),
                  ),
                ),

                // Content Area
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: isAllModels
                      ? Column(
                          children: [
                            for (var i = 0; i < agents.length; i++) ...[
                              ModelAnswerCard(
                                agent: agents[i],
                                color: AppTheme.agentColors[
                                    i % AppTheme.agentColors.length],
                                allAgents: agents,
                                isSingleView: false,
                                onViewChanged: onViewChanged,
                              ),
                              if (i < agents.length - 1)
                                const SizedBox(height: 16),
                            ],
                          ],
                        )
                      : selectedAgent != null
                          ? ModelAnswerCard(
                              agent: selectedAgent,
                              color: AppTheme.agentColors[
                                  selectedIndex % AppTheme.agentColors.length],
                              allAgents: agents,
                              isSingleView: true,
                              onViewChanged: onViewChanged,
                            )
                          : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ModelAnswerCard extends StatefulWidget {
  final AgentResponseItem agent;
  final Color color;
  final List<AgentResponseItem> allAgents;
  final bool isSingleView;
  final Function(String view) onViewChanged;

  const ModelAnswerCard({
    super.key,
    required this.agent,
    required this.color,
    required this.allAgents,
    required this.isSingleView,
    required this.onViewChanged,
  });

  @override
  State<ModelAnswerCard> createState() => _ModelAnswerCardState();
}

class _ModelAnswerCardState extends State<ModelAnswerCard> {
  bool _showPromptDirective = false;

  @override
  Widget build(BuildContext context) {
    final agent = widget.agent;
    final color = widget.color;
    final optimizerName = agent.optimizedByAgentName ?? 'Peer Model';
    final hasReceivedPrompt = agent.receivedPrompt != null && agent.receivedPrompt!.trim().isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceHigh,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.border),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Model name & Copy button
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppTheme.tint(color, 0.16),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Icon(LucideIcons.bot, size: 16, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      MultiAgentTurnCard.cleanName(agent.agentName),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(LucideIcons.arrowRightLeft,
                            size: 11, color: AppTheme.textMuted),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Optimized by: ${MultiAgentTurnCard.cleanName(optimizerName)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: color,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(LucideIcons.copy,
                    size: 15, color: AppTheme.textMuted),
                tooltip: 'Copy Answer',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: agent.answer));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Copied response to clipboard'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
          ),

          // Transformed Prompt Inspector Accordion
          if (hasReceivedPrompt) ...[
            const SizedBox(height: 10),
            InkWell(
              onTap: () {
                setState(() {
                  _showPromptDirective = !_showPromptDirective;
                });
              },
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: _showPromptDirective
                      ? AppTheme.tint(color, 0.12)
                      : AppTheme.background,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  border: Border.all(
                    color: _showPromptDirective
                        ? AppTheme.tint(color, 0.4)
                        : AppTheme.border,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.sparkles,
                      size: 13,
                      color: _showPromptDirective ? color : AppTheme.primaryLight,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _showPromptDirective
                            ? 'Hide Prompt Engineered by ${MultiAgentTurnCard.cleanName(optimizerName)}'
                            : 'View Prompt Engineered by ${MultiAgentTurnCard.cleanName(optimizerName)}',
                        style: TextStyle(
                          color: _showPromptDirective ? color : AppTheme.textSecondary,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      _showPromptDirective
                          ? LucideIcons.chevronUp
                          : LucideIcons.chevronDown,
                      size: 14,
                      color: AppTheme.textMuted,
                    ),
                  ],
                ),
              ),
            ),
            if (_showPromptDirective) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(LucideIcons.fileCode2,
                            size: 13, color: AppTheme.textMuted),
                        const SizedBox(width: 6),
                        Text(
                          'Handed Directive (Refined by ${MultiAgentTurnCard.cleanName(optimizerName)})',
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      agent.receivedPrompt!,
                      style: const TextStyle(
                        color: Color(0xFFD4D4D8),
                        fontSize: 11.5,
                        fontFamily: 'monospace',
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],

          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Markdown Content
          MarkdownBody(
            data: agent.answer,
            selectable: true,
            styleSheet: _buildMarkdownStyle(context),
          ),

          // Bottom quick switch buttons
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text(
                'View model:',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final other in widget.allAgents) ...[
                        if (other.agentId != agent.agentId || !widget.isSingleView)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: InkWell(
                              onTap: () => widget.onViewChanged(other.agentId),
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusSm),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.input,
                                  borderRadius:
                                      BorderRadius.circular(AppTheme.radiusSm),
                                  border: Border.all(color: AppTheme.border),
                                ),
                                child: Text(
                                  MultiAgentTurnCard.cleanName(other.agentName),
                                  style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                      if (widget.isSingleView)
                        InkWell(
                          onTap: () => widget.onViewChanged('all_models'),
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusSm),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.tint(AppTheme.primary, 0.14),
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusSm),
                              border: Border.all(
                                  color: AppTheme.tint(AppTheme.primary, 0.4)),
                            ),
                            child: const Text(
                              'Show All 3',
                              style: TextStyle(
                                color: AppTheme.primaryLight,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  MarkdownStyleSheet _buildMarkdownStyle(BuildContext context) {
    return MarkdownStyleSheet(
      p: const TextStyle(color: Color(0xFFE4E4E7), fontSize: 13.5, height: 1.55),
      pPadding: const EdgeInsets.only(bottom: 4),
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
          fontWeight: FontWeight.w600,
          height: 1.35),
      strong:
          const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      code: const TextStyle(
        color: AppTheme.info,
        backgroundColor: AppTheme.card,
        fontFamily: 'monospace',
        fontSize: 12,
      ),
      codeblockPadding: const EdgeInsets.all(10),
      codeblockDecoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: AppTheme.border),
      ),
      listBullet: const TextStyle(color: AppTheme.primaryLight),
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
      borderRadius: BorderRadius.circular(AppTheme.radiusSm + 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm + 2),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusSm + 2),
            border: Border.all(
              color: isSelected ? color : AppTheme.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 13, color: isSelected ? color : AppTheme.textMuted),
              const SizedBox(width: 6),
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
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.tint(color, 0.2)
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
