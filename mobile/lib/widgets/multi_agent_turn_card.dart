import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../models/multi_agent_turn.dart';
import '../theme/app_theme.dart';
import 'prompt_skill_inspector.dart';

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

  static String _cleanName(String name) => name
      .replaceAll('Agent Alpha (', '')
      .replaceAll('Agent Beta (', '')
      .replaceAll('Agent Gamma (', '')
      .replaceAll('Agent Delta (', '')
      .replaceAll(')', '')
      .trim();

  @override
  Widget build(BuildContext context) {
    AgentResponseItem? selectedAgent;
    int selectedIndex = 0;
    if (activeView != 'consensus' && activeView != 'debate') {
      final idx = turn.agentResponses.indexWhere((a) => a.agentId == activeView);
      if (idx >= 0) {
        selectedAgent = turn.agentResponses[idx];
        selectedIndex = idx;
      }
    }
    final agentColor =
        AppTheme.agentColors[selectedIndex % AppTheme.agentColors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. User prompt bubble
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

          // 2. Prompt-engineering skill accordion
          PromptSkillInspector(optimization: turn.optimization),
          const SizedBox(height: 12),

          // 3. Answer container
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
                // Tab bar
                Container(
                  decoration: const BoxDecoration(
                    color: AppTheme.background,
                    border: Border(bottom: BorderSide(color: AppTheme.border)),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _TabChip(
                          label: 'Best answer',
                          icon: LucideIcons.award,
                          badge: null,
                          color: AppTheme.primary,
                          isSelected: activeView == 'consensus',
                          onTap: () => onViewChanged('consensus'),
                        ),
                        const SizedBox(width: 8),
                        for (var i = 0; i < turn.agentResponses.length; i++) ...[
                          _TabChip(
                            label: _cleanName(turn.agentResponses[i].agentName),
                            icon: LucideIcons.bot,
                            badge: '${turn.agentResponses[i].accuracyScore}%',
                            color: AppTheme.agentColors[
                                i % AppTheme.agentColors.length],
                            isSelected:
                                activeView == turn.agentResponses[i].agentId,
                            onTap: () =>
                                onViewChanged(turn.agentResponses[i].agentId),
                          ),
                          const SizedBox(width: 8),
                        ],
                        _TabChip(
                          label: 'Debate',
                          icon: LucideIcons.messagesSquare,
                          badge: '${turn.discussionRounds.length}',
                          color: AppTheme.violet,
                          isSelected: activeView == 'debate',
                          onTap: () => onViewChanged('debate'),
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sub-header
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildSubheader(selectedAgent, agentColor),
                          ),
                          if (activeView != 'debate')
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(LucideIcons.copy,
                                  size: 16, color: AppTheme.textMuted),
                              tooltip: 'Copy answer',
                              onPressed: () {
                                final textToCopy = activeView == 'consensus'
                                    ? turn.consensusSolution
                                    : (selectedAgent?.answer ?? '');
                                Clipboard.setData(
                                    ClipboardData(text: textToCopy));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Copied to clipboard'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 16),

                      // Body
                      if (activeView == 'consensus')
                        MarkdownBody(
                          data: turn.consensusSolution,
                          selectable: true,
                          styleSheet: _buildMarkdownStyle(context),
                        )
                      else if (selectedAgent != null) ...[
                        if (selectedAgent.critiqueOfOthers != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 14),
                            decoration: BoxDecoration(
                              color: AppTheme.tint(AppTheme.info, 0.08),
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusMd),
                              border: Border.all(
                                  color: AppTheme.tint(AppTheme.info, 0.25)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 1),
                                  child: Icon(LucideIcons.info,
                                      size: 14, color: AppTheme.info),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Peer note: ${selectedAgent.critiqueOfOthers!}',
                                    style: const TextStyle(
                                      color: Color(0xFFBAE6FD),
                                      fontSize: 12.5,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        MarkdownBody(
                          data: selectedAgent.answer,
                          selectable: true,
                          styleSheet: _buildMarkdownStyle(context),
                        ),
                      ] else if (activeView == 'debate') ...[
                        if (turn.discussionRounds.isEmpty)
                          const Text(
                            'No inter-agent debate records found.',
                            style: TextStyle(
                                color: AppTheme.textMuted, fontSize: 13),
                          )
                        else
                          ...turn.discussionRounds.map(_buildDebateItem),
                      ],
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

  Widget _buildSubheader(AgentResponseItem? selectedAgent, Color agentColor) {
    late final IconData icon;
    late final Color color;
    late final String title;
    late final String subtitle;
    Color subtitleColor = AppTheme.textSecondary;

    if (activeView == 'consensus') {
      icon = LucideIcons.award;
      color = AppTheme.warning;
      title = 'Best answer';
      subtitle = turn.consensusRationale;
    } else if (selectedAgent != null) {
      icon = LucideIcons.bot;
      color = agentColor;
      title = _cleanName(selectedAgent.agentName);
      subtitle =
          'Raw response • Deliberation score ${selectedAgent.accuracyScore}%';
      subtitleColor = agentColor;
    } else {
      icon = LucideIcons.messagesSquare;
      color = AppTheme.violet;
      title = 'AI discussion';
      subtitle = 'How the models critiqued and verified each other';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(color: subtitleColor, fontSize: 12, height: 1.35),
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
      margin: const EdgeInsets.only(bottom: 10),
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
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(typeIcon, size: 14, color: typeColor),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            round.speaker,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: typeColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(LucideIcons.arrowRight,
                              size: 11, color: AppTheme.textMuted),
                        ),
                        Flexible(
                          child: Text(
                            round.targetAgent ?? 'All models',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.tint(typeColor, 0.14),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            round.type.toUpperCase(),
                            style: TextStyle(
                              color: typeColor,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      round.statement,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 13,
                        height: 1.45,
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
      p: const TextStyle(color: Color(0xFFE4E4E7), fontSize: 14, height: 1.6),
      pPadding: const EdgeInsets.only(bottom: 2),
      h1: const TextStyle(
          color: Colors.white,
          fontSize: 19,
          fontWeight: FontWeight.w800,
          height: 1.4),
      h2: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 16.5,
          fontWeight: FontWeight.w700,
          height: 1.4),
      h3: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w700,
          height: 1.4),
      h4: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 13.5,
          fontWeight: FontWeight.w600),
      strong: const TextStyle(
          color: Colors.white, fontWeight: FontWeight.w700),
      code: const TextStyle(
        color: AppTheme.info,
        backgroundColor: AppTheme.surfaceHigh,
        fontFamily: 'monospace',
        fontSize: 12.5,
      ),
      codeblockPadding: const EdgeInsets.all(12),
      codeblockDecoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm + 2),
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
      borderRadius: BorderRadius.circular(AppTheme.radiusSm + 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm + 2),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
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
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.tint(color, 0.2)
                        : AppTheme.surfaceHigh,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    badge!,
                    style: TextStyle(
                      color: isSelected ? color : AppTheme.textMuted,
                      fontSize: 10,
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
