import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tra_mobile/providers/chat_provider.dart';
import 'package:tra_mobile/theme/app_theme.dart';
import 'package:tra_mobile/widgets/chat_input_bar.dart';
import 'package:tra_mobile/widgets/pipeline_stepper.dart';

void main() {
  for (final width in [320.0, 360.0, 411.0]) {
    testWidgets('pipeline stepper + input bar do not overflow at ${width}px',
        (tester) async {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      for (final stage in [
        PipelineStage.optimizing,
        PipelineStage.queryingAgents,
        PipelineStage.interAgentDebate,
        PipelineStage.synthesizing,
      ]) {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.darkTheme,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(1.3)),
              child: child!,
            ),
            home: Scaffold(
              body: Column(
                children: [
                  PipelineStepper(
                    stage: stage,
                    stageMessage:
                        'Synthesizing verified Rank 1 Consensus Solution...',
                  ),
                  const Spacer(),
                  ChatInputBar(onSend: (_) {}, isGenerating: false),
                ],
              ),
            ),
          ),
        );
        expect(tester.takeException(), isNull);
      }
    });
  }
}
