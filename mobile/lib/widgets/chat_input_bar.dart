import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../models/council_models.dart';
import '../theme/app_theme.dart';

/// Message composer: a card with the text area on top and a compact toolbar
/// underneath (examples, active models, send).
///
/// With [hero] set it is shown as a large centred card (empty state);
/// otherwise it is docked to the bottom of the chat.
class ChatInputBar extends StatefulWidget {
  final Function(String text) onSend;
  final bool isGenerating;
  final bool hero;

  const ChatInputBar({
    super.key,
    required this.onSend,
    required this.isGenerating,
    this.hero = false,
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSend() {
    if (widget.isGenerating) return;
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _controller.clear();
  }

  void _showExamples() {
    _showSheet(
      title: 'Try an example',
      children: [
        for (final e in examplePrompts)
          _SheetRow(
            leading: Icon(e.$1, size: 16, color: AppTheme.primaryLight),
            title: e.$2,
            maxLines: 2,
            onTap: () {
              Navigator.pop(context);
              _controller.text = e.$2;
              _controller.selection =
                  TextSelection.collapsed(offset: e.$2.length);
            },
          ),
      ],
    );
  }

  void _showModels() {
    _showSheet(
      title: 'Answering models',
      children: [
        for (final m in councilModels)
          _SheetRow(
            leading: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: m.color, shape: BoxShape.circle),
            ),
            title: m.name,
            trailing: m.provider,
          ),
      ],
    );
  }

  void _showSheet({required String title, required List<Widget> children}) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.card,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: AppTheme.border),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canSend = _hasText && !widget.isGenerating;

    final card = Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(color: AppTheme.borderStrong),
      ),
      padding: EdgeInsets.fromLTRB(16, widget.hero ? 16 : 10, 10, 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: TextField(
              controller: _controller,
              minLines: widget.hero ? 3 : 1,
              maxLines: 6,
              cursorColor: AppTheme.primaryLight,
              textInputAction: TextInputAction.send,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 15,
                height: 1.4,
              ),
              decoration: const InputDecoration(
                hintText: 'Type your message here…',
                hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 15),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 6),
              ),
              onSubmitted: (_) => _handleSend(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _ToolbarButton(
                tooltip: 'Examples',
                onTap: _showExamples,
                child: const Icon(LucideIcons.plus,
                    size: 18, color: AppTheme.textSecondary),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: InkWell(
                  onTap: _showModels,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm + 2),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // One flat dot per model.
                        for (final m in councilModels)
                          Padding(
                            padding: const EdgeInsets.only(right: 3),
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: m.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        const SizedBox(width: 5),
                        const Flexible(
                          child: Text(
                            '3 Models',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(LucideIcons.chevronDown,
                            size: 14, color: AppTheme.textMuted),
                      ],
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Material(
                color: canSend
                    ? AppTheme.primary
                    : AppTheme.tint(AppTheme.primary, 0.16),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                child: InkWell(
                  onTap: canSend ? _handleSend : null,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  child: SizedBox(
                    width: 38,
                    height: 38,
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
                                  : AppTheme.tint(AppTheme.primaryLight, 0.6),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (widget.hero) return card;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: const BoxDecoration(
        color: AppTheme.background,
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: SafeArea(top: false, child: card),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final String tooltip;
  final VoidCallback onTap;
  final Widget child;

  const _ToolbarButton({
    required this.tooltip,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: SizedBox(width: 38, height: 38, child: Center(child: child)),
      ),
    );
  }
}

class _SheetRow extends StatelessWidget {
  final Widget leading;
  final String title;
  final String? trailing;
  final int maxLines;
  final VoidCallback? onTap;

  const _SheetRow({
    required this.leading,
    required this.title,
    this.trailing,
    this.maxLines = 1,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        child: Row(
          children: [
            SizedBox(width: 20, child: Center(child: leading)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 13.5,
                  height: 1.3,
                ),
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 12),
              Text(
                trailing!,
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
