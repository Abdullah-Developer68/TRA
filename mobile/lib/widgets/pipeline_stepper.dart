import 'package:flutter/material.dart';
import '../providers/chat_provider.dart';
import '../theme/app_theme.dart';

class PipelineStepper extends StatelessWidget {
  final PipelineStage stage;
  final String stageMessage;

  const PipelineStepper({
    super.key,
    required this.stage,
    required this.stageMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (stage == PipelineStage.idle || stage == PipelineStage.complete) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1424),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryLight),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'TRA MULTI-AGENT COUNCIL',
                style: TextStyle(
                  color: AppTheme.primaryLight,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _stageLabel(stage),
                  style: const TextStyle(
                    color: AppTheme.primaryLight,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            stageMessage,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 12,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          // 4-Phase Step Indicators
          Row(
            children: [
              _buildStepPill(
                '1. Prompt Skill',
                isActive: stage == PipelineStage.optimizing,
                isDone: stage.index > PipelineStage.optimizing.index,
              ),
              const SizedBox(width: 6),
              _buildStepPill(
                '2. 4 AI Agents',
                isActive: stage == PipelineStage.queryingAgents,
                isDone: stage.index > PipelineStage.queryingAgents.index,
              ),
              const SizedBox(width: 6),
              _buildStepPill(
                '3. Debate',
                isActive: stage == PipelineStage.interAgentDebate,
                isDone: stage.index > PipelineStage.interAgentDebate.index,
              ),
              const SizedBox(width: 6),
              _buildStepPill(
                '4. Consensus',
                isActive: stage == PipelineStage.synthesizing,
                isDone: stage.index > PipelineStage.synthesizing.index,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepPill(String label, {required bool isActive, required bool isDone}) {
    Color bg = const Color(0xFF141926);
    Color border = const Color(0xFF1F283C);
    Color text = AppTheme.textMuted;

    if (isActive) {
      bg = AppTheme.primary.withOpacity(0.2);
      border = AppTheme.primary;
      text = AppTheme.primaryLight;
    } else if (isDone) {
      bg = const Color(0xFF10B981).withOpacity(0.15);
      border = const Color(0xFF10B981).withOpacity(0.4);
      text = const Color(0xFF34D399);
    }

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: border),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: text,
            fontSize: 9.5,
            fontWeight: isActive || isDone ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  String _stageLabel(PipelineStage s) {
    switch (s) {
      case PipelineStage.optimizing:
        return 'Optimizing';
      case PipelineStage.queryingAgents:
        return 'Consulting 4 AIs';
      case PipelineStage.interAgentDebate:
        return 'Debating';
      case PipelineStage.synthesizing:
        return 'Synthesizing';
      default:
        return '';
    }
  }
}
