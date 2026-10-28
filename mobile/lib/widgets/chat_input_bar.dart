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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppTheme.sidebar,
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mode Badges Row
            Row(
              children: [
                _buildModePill(
                  label: 'Multi-Agent Consensus',
                  icon: LucideIcons.brain,
                  isSelected: true,
                ),
                const SizedBox(width: 8),
                _buildModePill(
                  label: 'Prompt Skill',
                  icon: LucideIcons.sparkles,
                  isSelected: false,
                ),
                const Spacer(),
                const Text(
                  '4 Free AI Models',
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Text Input Box with Action Buttons
            Container(
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.border),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      maxLines: 4,
                      minLines: 1,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 13.5,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Ask anything to the 4-agent council...',
                        hintStyle: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 13,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                      ),
                      onSubmitted: (_) => _handleSend(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Send or Generating Spinner Button
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: InkWell(
                      onTap: widget.isGenerating ? null : _handleSend,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: widget.isGenerating ? const Color(0xFF1E212D) : AppTheme.primary,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: widget.isGenerating
                              ? null
                              : [
                                  BoxShadow(
                                    color: AppTheme.primary.withOpacity(0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  )
                                ],
                        ),
                        alignment: Alignment.center,
                        child: widget.isGenerating
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryLight),
                                ),
                              )
                            : const Icon(
                                LucideIcons.arrowUp,
                                color: Colors.white,
                                size: 16,
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

  Widget _buildModePill({
    required String label,
    required IconData icon,
    required bool isSelected,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.accent : const Color(0xFF141418),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? AppTheme.primary.withOpacity(0.4) : AppTheme.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: isSelected ? AppTheme.primaryLight : AppTheme.textMuted,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppTheme.accentForeground : AppTheme.textSecondary,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
