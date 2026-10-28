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

  @override
  Widget build(BuildContext context) {
    AgentResponseItem? selectedAgent;
    if (activeView != 'consensus' && activeView != 'debate') {
      try {
        selectedAgent = turn.agentResponses.firstWhere((a) => a.agentId == activeView);
      } catch (_) {}
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
              decoration: BoxDecoration(
                color: AppTheme.input,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                  topRight: Radius.circular(4),
                ),
                border: Border.all(color: AppTheme.border),
              ),
              child: Text(
                turn.userPrompt,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 13.5,
                  height: 1.4,
                ),
              ),
            ),
          ),

          // 2. Prompt Engineering Skill Accordion
          PromptSkillInspector(optimization: turn.optimization),
          const SizedBox(height: 12),

          // 3. Multi-Agent Solution & Toggles Container
          Container(
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF232634)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                )
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Horizontal Toggles Bar
                Container(
                  color: const Color(0xFF090A0E),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // Rank 1: Consensus (Always Shown First)
                        _buildToggleChip(
                          label: '🏆 Rank 1: Most Accurate',
                          badge: 'Consensus',
                          isSelected: activeView == 'consensus',
                          onTap: () => onViewChanged('consensus'),
                          activeColor: AppTheme.primary,
                        ),
                        const SizedBox(width: 8),

                        // Other AI Agents
                        ...turn.agentResponses.map((agent) {
                          final isSelected = activeView == agent.agentId;
                          final medal = agent.rank == 2 ? '🥈' : agent.rank == 3 ? '🥉' : '🎖️';
                          final shortName = agent.agentName.split('(')[0].trim();

                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _buildToggleChip(
                              label: '$medal Rank ${agent.rank}: $shortName',
                              badge: '${agent.accuracyScore}%',
                              isSelected: isSelected,
                              onTap: () => onViewChanged(agent.agentId),
                              activeColor: const Color(0xFF1E293B),
                              activeBorderColor: const Color(0xFF0284C7),
                              activeTextColor: const Color(0xFF38BDF8),
                            ),
                          );
                        }),

                        // Inter-Agent Debate
                        _buildToggleChip(
                          label: '💬 Debate (${turn.discussionRounds.length})',
                          badge: null,
                          isSelected: activeView == 'debate',
                          onTap: () => onViewChanged('debate'),
                          activeColor: const Color(0xFF6366F1),
                        ),
                      ],
                    ),
                  ),
                ),

                // View Content Body
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Subheader
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (activeView == 'consensus') ...[
                                  const Text(
                                    'Verified Consensus & Most Accurate Solution',
                                    style: TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    turn.consensusRationale,
                                    style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                ] else if (selectedAgent != null) ...[
                                  Text(
                                    selectedAgent.agentName,
                                    style: const TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${selectedAgent.role} • Score: ${selectedAgent.accuracyScore}%',
                                    style: const TextStyle(
                                      color: Color(0xFF38BDF8),
                                      fontSize: 11,
                                    ),
                                  ),
                                ] else if (activeView == 'debate') ...[
                                  const Text(
                                    'Inter-Agent Deliberation & Cross-Examination',
                                    style: TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'Critiques and rebuttals exchanged between models',
                                    style: TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(LucideIcons.copy, size: 15, color: AppTheme.textMuted),
                            tooltip: 'Copy Answer',
                            onPressed: () {
                              final textToCopy = activeView == 'consensus'
                                  ? turn.consensusSolution
                                  : (selectedAgent?.answer ?? '');
                              Clipboard.setData(ClipboardData(text: textToCopy));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Copied to clipboard'),
                                  duration: Duration(seconds: 1),
                                  backgroundColor: Color(0xFF1E293B),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(color: Color(0xFF1E212E), height: 1),
                      const SizedBox(height: 14),

                      // Content Display
                      if (activeView == 'consensus') ...[
                        MarkdownBody(
                          data: turn.consensusSolution,
                          styleSheet: _buildMarkdownStyle(context),
                        ),
                      ] else if (selectedAgent != null) ...[
                        if (selectedAgent.critiqueOfOthers != null) ...[
                          Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF141824),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF20293D)),
                            ),
                            child: Text(
                              'Council Assessment: ${selectedAgent.critiqueOfOthers!}',
                              style: const TextStyle(
                                color: Color(0xFF93C5FD),
                                fontSize: 11.5,
                              ),
                            ),
                          ),
                        ],
                        MarkdownBody(
                          data: selectedAgent.answer,
                          styleSheet: _buildMarkdownStyle(context),
                        ),
                      ] else if (activeView == 'debate') ...[
                        ...turn.discussionRounds.map((round) {
                          Color badgeColor = const Color(0xFF3B82F6);
                          if (round.type == 'critique') badgeColor = const Color(0xFFEF4444);
                          if (round.type == 'endorsement') badgeColor = const Color(0xFF10B981);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0D0F16),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFF1E2232)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      round.speaker,
                                      style: const TextStyle(
                                        color: Color(0xFF818CF8),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (round.targetAgent != null) ...[
                                      const Text(
                                        ' → ',
                                        style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
                                      ),
                                      Text(
                                        round.targetAgent!,
                                        style: const TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: badgeColor.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: badgeColor.withOpacity(0.4)),
                                      ),
                                      child: Text(
                                        round.type.toUpperCase(),
                                        style: TextStyle(
                                          color: badgeColor,
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  round.statement,
                                  style: const TextStyle(
                                    color: Color(0xFFD1D5DB),
                                    fontSize: 12,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
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

  Widget _buildToggleChip({
    required String label,
    required String? badge,
    required bool isSelected,
    required VoidCallback onTap,
    required Color activeColor,
    Color? activeBorderColor,
    Color? activeTextColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : const Color(0xFF13141E),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? (activeBorderColor ?? activeColor.withOpacity(0.6))
                : const Color(0xFF1E2130),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? (activeTextColor ?? Colors.white) : AppTheme.textSecondary,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFFF59E0B),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  MarkdownStyleSheet _buildMarkdownStyle(BuildContext context) {
    return MarkdownStyleSheet(
      p: const TextStyle(color: Color(0xFFECECF1), fontSize: 13, height: 1.45),
      h1: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
      h2: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
      h3: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
      code: const TextStyle(
        backgroundColor: Color(0xFF1A1D27),
        color: Color(0xFF67E8F9),
        fontFamily: 'monospace',
        fontSize: 11.5,
      ),
      codeblockDecoration: BoxDecoration(
        color: const Color(0xFF0D0F17),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF222638)),
      ),
      blockquote: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
      listBullet: const TextStyle(color: AppTheme.primaryLight),
    );
  }
}
