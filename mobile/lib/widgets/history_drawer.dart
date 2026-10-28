import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../providers/chat_provider.dart';
import '../theme/app_theme.dart';

class HistoryDrawer extends ConsumerWidget {
  final VoidCallback? onLogout;

  const HistoryDrawer({super.key, this.onLogout});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(chatNotifierProvider);
    final notifier = ref.read(chatNotifierProvider.notifier);

    return Drawer(
      backgroundColor: AppTheme.sidebar,
      width: 290,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusSm + 2),
                        ),
                        child: const Icon(LucideIcons.brain,
                            size: 18, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Multi-Agent Council',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Material(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    child: InkWell(
                      onTap: () {
                        notifier.resetChat();
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      child: const SizedBox(
                        width: double.infinity,
                        height: 42,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.plus,
                                size: 16, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'New Session',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            const Padding(
              padding: EdgeInsets.fromLTRB(18, 14, 18, 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'RECENT SESSIONS',
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ),
            Expanded(
              child: chatState.threads.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.messagesSquare,
                              size: 22, color: AppTheme.textMuted),
                          SizedBox(height: 8),
                          Text(
                            'No previous sessions',
                            style: TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      itemCount: chatState.threads.length,
                      itemBuilder: (context, index) {
                        final thread = chatState.threads[index];
                        final isSelected =
                            thread.id == chatState.activeThreadId;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Material(
                            color: isSelected
                                ? AppTheme.accent
                                : Colors.transparent,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusMd),
                            child: InkWell(
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusMd),
                              onTap: () {
                                notifier.selectThread(thread.id);
                                Navigator.pop(context);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      AppTheme.radiusMd),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppTheme.tint(AppTheme.primary, 0.4)
                                        : Colors.transparent,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      LucideIcons.messageSquare,
                                      size: 14,
                                      color: isSelected
                                          ? AppTheme.primaryLight
                                          : AppTheme.textMuted,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        thread.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: isSelected
                                              ? AppTheme.accentForeground
                                              : AppTheme.textSecondary,
                                          fontSize: 12.5,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: const BoxDecoration(
                      color: AppTheme.surfaceHigh,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'U',
                      style: TextStyle(
                        color: AppTheme.primaryLight,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Signed in user',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '3 Free Active AI Models',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 10.5,
                          ),
                        ),
                      ],
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
