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
    final techniques = opt.appliedTechniques;
    final summary = techniques.take(2).join(', ') +
        (techniques.length > 2 ? ' +${techniques.length - 2}' : '');

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: AppTheme.tint(AppTheme.info, 0.14),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: const Icon(LucideIcons.wand,
                        size: 13, color: AppTheme.info),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Prompt sharpened',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (summary.isNotEmpty)
                          Text(
                            summary,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 11.5,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _expanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                    size: 16,
                    color: AppTheme.textMuted,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionLabel('Reasoning techniques'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: techniques
                        .map(
                          (t) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.tint(AppTheme.info, 0.10),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: AppTheme.tint(AppTheme.info, 0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(LucideIcons.check,
                                    size: 11, color: AppTheme.info),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    t,
                                    style: const TextStyle(
                                      color: AppTheme.info,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  if (opt.constraintsAdded.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const _SectionLabel('Guardrails'),
                    const SizedBox(height: 8),
                    ...opt.constraintsAdded.map(
                      (c) => Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 6, right: 8),
                              child: Container(
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(
                                  color: AppTheme.info,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                c,
                                style: const TextStyle(
                                  color: Color(0xFFD4D4D8),
                                  fontSize: 12.5,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  const _SectionLabel('Prompt sent to the 4 models'),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm + 2),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: SelectableText(
                      opt.optimizedPrompt,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: AppTheme.primaryLight,
                        fontSize: 11.5,
                        height: 1.5,
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

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: AppTheme.textMuted,
        fontSize: 10.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
      ),
    );
  }
}
