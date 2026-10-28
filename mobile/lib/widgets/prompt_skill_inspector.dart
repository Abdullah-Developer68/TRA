import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../models/multi_agent_turn.dart';
import '../theme/app_theme.dart';

class PromptSkillInspector extends StatefulWidget {
  final PromptOptimizationDetails optimization;

  const PromptSkillInspector({super.key, required this.optimization});

  @override
  State<PromptSkillInspector> createState() => _PromptSkillInspectorState();
}

class _PromptSkillInspectorState extends State<PromptSkillInspector> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final opt = widget.optimization;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0E1017),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF232736)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFF38BDF8),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Prompt Engineering Skill Applied',
                    style: TextStyle(
                      color: Color(0xFF7DD3FC),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '• ${opt.appliedTechniques.take(2).join(", ")}${opt.appliedTechniques.length > 2 ? " +${opt.appliedTechniques.length - 2}" : ""}',
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 11,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _expanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                    size: 14,
                    color: AppTheme.textMuted,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            const Divider(color: Color(0xFF1E212E), height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ENFORCED REASONING TECHNIQUES',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: opt.appliedTechniques
                        .map(
                          (t) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF132238),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFF1E3A5F)),
                            ),
                            child: Text(
                              '✓ $t',
                              style: const TextStyle(
                                color: Color(0xFF38BDF8),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  if (opt.constraintsAdded.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'GUARDRAILS & NEGATIVE CONSTRAINTS',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ...opt.constraintsAdded.map(
                      (c) => Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(color: Color(0xFF38BDF8))),
                            Expanded(
                              child: Text(
                                c,
                                style: const TextStyle(
                                  color: Color(0xFFCBD5E1),
                                  fontSize: 11,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  const Text(
                    'OPTIMIZED PROMPT DISPATCHED TO 4 MODELS',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF090A0F),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF222638)),
                    ),
                    child: Text(
                      opt.optimizedPrompt,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: Color(0xFFA5B4FC),
                        fontSize: 10.5,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
