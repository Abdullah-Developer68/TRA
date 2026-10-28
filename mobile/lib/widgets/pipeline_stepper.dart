import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../providers/chat_provider.dart';
import '../theme/app_theme.dart';

/// Live progress card shown while the council is deliberating.
///
/// Every row is built from [Expanded]/[Flexible] children so it can never
/// overflow, regardless of screen width or font scale.
class PipelineStepper extends StatelessWidget {
  final PipelineStage stage;
  final String stageMessage;

  const PipelineStepper({
    super.key,
    required this.stage,
    required this.stageMessage,
  });

  static const _steps = <_Step>[
    _Step('Prepare', LucideIcons.wand),
    _Step('Query', LucideIcons.radio),
    _Step('Debate', LucideIcons.messagesSquare),
    _Step('Synthesize', LucideIcons.sparkles),
  ];

  static const _activeStages = <PipelineStage>[
    PipelineStage.optimizing,
    PipelineStage.queryingAgents,
    PipelineStage.interAgentDebate,
    PipelineStage.synthesizing,
  ];

  @override
  Widget build(BuildContext context) {
    if (stage == PipelineStage.idle || stage == PipelineStage.complete) {
      return const SizedBox.shrink();
    }

    final activeIndex = _activeStages.indexOf(stage);
    final stepNumber = activeIndex < 0 ? 0 : activeIndex + 1;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.primaryLight,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'COUNCIL IN SESSION',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.tint(AppTheme.primary, 0.14),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Step $stepNumber of 4',
                  style: const TextStyle(
                    color: AppTheme.primaryLight,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _stageLabel(stage),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            stageMessage,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12.5,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < _steps.length; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(
                  child: _StepSegment(
                    step: _steps[i],
                    isActive: i == activeIndex,
                    isDone: activeIndex >= 0 && i < activeIndex,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _stageLabel(PipelineStage stage) {
    switch (stage) {
      case PipelineStage.optimizing:
        return 'Optimizing your prompt';
      case PipelineStage.queryingAgents:
        return 'Asking 4 models';
      case PipelineStage.interAgentDebate:
        return 'Models are debating';
      case PipelineStage.synthesizing:
        return 'Selecting the best answer';
      case PipelineStage.complete:
        return 'Completed';
      case PipelineStage.idle:
        return 'Ready';
      case PipelineStage.error:
        return 'Something went wrong';
    }
  }
}

class _Step {
  final String label;
  final IconData icon;
  const _Step(this.label, this.icon);
}

class _StepSegment extends StatelessWidget {
  final _Step step;
  final bool isActive;
  final bool isDone;

  const _StepSegment({
    required this.step,
    required this.isActive,
    required this.isDone,
  });

  @override
  Widget build(BuildContext context) {
    final Color accent = isDone
        ? AppTheme.success
        : isActive
            ? AppTheme.primaryLight
            : AppTheme.textMuted;
    final Color bar = isDone
        ? AppTheme.success
        : isActive
            ? AppTheme.primary
            : AppTheme.border;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: Container(height: 4, color: bar),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(isDone ? LucideIcons.check : step.icon,
                size: 12, color: accent),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                step.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: accent,
                  fontSize: 10.5,
                  fontWeight:
                      isActive || isDone ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
