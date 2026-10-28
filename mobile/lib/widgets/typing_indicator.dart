import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_theme.dart';

/// Three dots that pulse one after another. Flat colour, no gradients.
class TypingDots extends StatefulWidget {
  final Color color;
  final double size;

  const TypingDots({
    super.key,
    this.color = AppTheme.primaryLight,
    this.size = 6,
  });

  @override
  State<TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 0..1 pulse for dot [index], staggered across the loop.
  double _pulse(int index) {
    final t = (_controller.value - index * 0.18) % 1.0;
    if (t > 0.5) return 0;
    // Triangle wave: up for the first quarter, down for the second.
    return t < 0.25 ? t / 0.25 : (0.5 - t) / 0.25;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < 3; i++) ...[
              if (i > 0) SizedBox(width: widget.size * 0.8),
              Transform.translate(
                offset: Offset(0, -widget.size * 0.7 * _pulse(i)),
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    color: widget.color
                        .withValues(alpha: 0.35 + 0.65 * _pulse(i)),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// What the user sees while a prompt is in flight: their message, followed by
/// a status bubble with animated typing dots.
class PendingTurn extends StatelessWidget {
  final String prompt;

  const PendingTurn({super.key, required this.prompt});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
              prompt,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14.5,
                height: 1.4,
              ),
            ),
          ),
        ),
        const Align(
          alignment: Alignment.centerLeft,
          child: TypingBubble(
            text: 'Refining your prompt and passing it to multiple agents',
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class TypingBubble extends StatelessWidget {
  final String text;

  const TypingBubble({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 40),
      padding: const EdgeInsets.fromLTRB(12, 12, 16, 12),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(18),
          bottomLeft: Radius.circular(18),
          bottomRight: Radius.circular(18),
        ),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppTheme.tint(AppTheme.primary, 0.14),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: const Icon(LucideIcons.sparkles,
                size: 14, color: AppTheme.primaryLight),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  text,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),
                const TypingDots(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
