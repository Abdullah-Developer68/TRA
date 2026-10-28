import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_theme.dart';

class ChatInputBar extends StatefulWidget {
  final Function(String text) onSend;
  final bool isGenerating;

  const ChatInputBar({
    super.key,
    required this.onSend,
    required this.isGenerating,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final has = _controller.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
  }

  void _handleSend() {
    if (widget.isGenerating) return;
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSend = _hasText && !widget.isGenerating;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: AppTheme.background,
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mode selector — Expanded children so it can never overflow.
            Row(
              children: [
                Expanded(
                  child: _ModePill(
                    label: 'Consensus',
                    icon: LucideIcons.brain,
                    isSelected: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ModePill(
                    label: 'Prompt Skill',
                    icon: LucideIcons.sparkles,
                    isSelected: false,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                border: Border.all(color: AppTheme.borderStrong),
              ),
              padding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      maxLines: 5,
                      minLines: 1,
                      cursorColor: AppTheme.primaryLight,
                      textInputAction: TextInputAction.send,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14.5,
                        height: 1.35,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Ask the council anything…',
                        hintStyle: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 14.5,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                      onSubmitted: (_) => _handleSend(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Material(
                      color: canSend
                          ? AppTheme.primary
                          : widget.isGenerating
                              ? AppTheme.surfaceHigh
                              : AppTheme.input,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      child: InkWell(
                        onTap: canSend ? _handleSend : null,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: Center(
                            child: widget.isGenerating
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppTheme.primaryLight,
                                    ),
                                  )
                                : Icon(
                                    LucideIcons.arrowUp,
                                    size: 18,
                                    color: canSend
                                        ? Colors.white
                                        : AppTheme.textMuted,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModePill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;

  const _ModePill({
    required this.label,
    required this.icon,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final fg = isSelected ? AppTheme.accentForeground : AppTheme.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.accent : AppTheme.card,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: isSelected
              ? AppTheme.tint(AppTheme.primary, 0.55)
              : AppTheme.border,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 14,
            color: isSelected ? AppTheme.primaryLight : AppTheme.textMuted,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: fg,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
