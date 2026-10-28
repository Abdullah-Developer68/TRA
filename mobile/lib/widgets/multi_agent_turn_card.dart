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
                  color: Colors.black.withValues(alpha: 0.4),
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
                        // Best Answer (Always Shown First by Default)
                        _buildToggleChip(
                          label: '⭐ Best Answer',
                          badge: 'Consensus',
                          isSelected: activeView == 'consensus',
                          onTap: () => onViewChanged('consensus'),
                          activeColor: AppTheme.primary,
                        ),
                        const SizedBox(width: 8),

                        // Other AI Models given the same prompt
                        ...turn.agentResponses.map((agent) {
                          final isSelected = activeView == agent.agentId;
                          final cleanName = agent.agentName
                              .replaceAll('Agent Alpha (', '')
                              .replaceAll('Agent Beta (', '')
                              .replaceAll('Agent Gamma (', '')
                              .replaceAll('Agent Delta (', '')
                              .replaceAll(')', '')
                              .trim();

                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _buildToggleChip(
                              label: '🤖 $cleanName',
                              badge: '${agent.accuracyScore}%',
                              isSelected: isSelected,
                              onTap: () => onViewChanged(agent.agentId),
                              activeColor: const Color(0xFF1E293B),
                              activeBorderColor: const Color(0xFF0284C7),
                              activeTextColor: const Color(0xFF38BDF8),
                            ),
                          );
                        }),

                        // Inter-AI Discussion & Debate
                        _buildToggleChip(
                          label: '💬 AI Discussion (${turn.discussionRounds.length})',
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
                                  const Row(
                                    children: [
                                      Icon(LucideIcons.award, size: 16, color: Color(0xFFFBBF24)),
                                      SizedBox(width: 6),
                                      Text(
                                        'Best Answer (Multi-AI Consensus)',
                                        style: TextStyle(
                                          color: AppTheme.textPrimary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
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
                                  Row(
                                    children: [
                                      const Icon(LucideIcons.bot, size: 16, color: Color(0xFF38BDF8)),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          '${selectedAgent.agentName} (Raw Output)',
                                          style: const TextStyle(
                                            color: AppTheme.textPrimary,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Individual response to the exact same prompt • Deliberation Score: ${selectedAgent.accuracyScore}%',
                                    style: const TextStyle(
                                      color: Color(0xFF38BDF8),
                                      fontSize: 11,
                                    ),
                                  ),
                                ] else if (activeView == 'debate') ...[
                                  const Row(
                                    children: [
                                      Icon(LucideIcons.messagesSquare, size: 16, color: Color(0xFFA5B4FC)),
                                      SizedBox(width: 6),
                                      Text(
                                        'Inter-AI Discussion & Cross-Examination',
                                        style: TextStyle(
                                          color: AppTheme.textPrimary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'How the 4 models discussed, critiqued, and verified each other\'s answers',
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
                            child: Row(
                              children: [
                                const Icon(LucideIcons.info, size: 14, color: Color(0xFF93C5FD)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Peer Discussion Note: ${selectedAgent.critiqueOfOthers!}',
                                    style: const TextStyle(
                                      color: Color(0xFF93C5FD),
                                      fontSize: 11.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        MarkdownBody(
                          data: selectedAgent.answer,
                          styleSheet: _buildMarkdownStyle(context),
                        ),
                      ] else if (activeView == 'debate') ...[
                        if (turn.discussionRounds.isEmpty) ...[
                          const Text(
                            'No inter-agent debate records found.',
                            style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                          ),
                        ] else ...[
                          ...turn.discussionRounds.map((round) => _buildDebateItem(round)),
                        ],
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : const Color(0xFF141620),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: isSelected
                ? (activeBorderColor ?? activeColor)
                : const Color(0xFF242838),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? (activeTextColor ?? Colors.white)
                    : const Color(0xFF9CA3AF),
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.18)
                      : const Color(0xFF22283A),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textMuted,
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

  Widget _buildDebateItem(DiscussionRoundItem round) {
    Color typeColor = const Color(0xFF60A5FA);
    IconData typeIcon = LucideIcons.messageCircle;

    if (round.type == 'critique') {
      typeColor = const Color(0xFFF87171);
      typeIcon = LucideIcons.alertCircle;
    } else if (round.type == 'endorsement') {
      typeColor = const Color(0xFF34D399);
      typeIcon = LucideIcons.checkCircle;
    } else if (round.type == 'synthesis') {
      typeColor = const Color(0xFFA78BFA);
      typeIcon = LucideIcons.sparkles;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF10131E),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: typeColor.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(typeIcon, size: 13, color: typeColor),
              const SizedBox(width: 6),
              Text(
                round.speaker,
                style: TextStyle(
                  color: typeColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(LucideIcons.arrowRight, size: 10, color: AppTheme.textMuted),
              const SizedBox(width: 6),
              Text(
                round.targetAgent ?? 'All Models',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  round.type.toUpperCase(),
                  style: TextStyle(
                    color: typeColor,
                    fontSize: 8.5,
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
              color: AppTheme.textPrimary,
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  MarkdownStyleSheet _buildMarkdownStyle(BuildContext context) {
    return MarkdownStyleSheet(
      p: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 13, height: 1.5),
      h1: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700, height: 1.4),
      h2: const TextStyle(color: Color(0xFFF1F5F9), fontSize: 15, fontWeight: FontWeight.w700, height: 1.4),
      h3: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 13.5, fontWeight: FontWeight.w600, height: 1.4),
      h4: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 12.5, fontWeight: FontWeight.w600),
      code: const TextStyle(
        color: Color(0xFF38BDF8),
        backgroundColor: Color(0xFF171B26),
        fontFamily: 'monospace',
        fontSize: 11.5,
      ),
      codeblockDecoration: BoxDecoration(
        color: const Color(0xFF0D0F17),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF1E2333)),
      ),
      blockquote: const TextStyle(color: Color(0xFF94A3B8), fontStyle: FontStyle.italic),
      blockquoteDecoration: const BoxDecoration(
        border: Border(left: BorderSide(color: Color(0xFF2E6BFF), width: 3)),
      ),
      listBullet: const TextStyle(color: Color(0xFF2E6BFF)),
      tableHead: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      tableBorder: TableBorder.all(color: const Color(0xFF242A3D), width: 1),
    );
  }
}
