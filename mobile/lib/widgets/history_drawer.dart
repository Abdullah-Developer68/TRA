import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../providers/chat_provider.dart';
import '../theme/app_theme.dart';

class HistoryDrawer extends ConsumerWidget {
  const HistoryDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(chatNotifierProvider);
    final notifier = ref.read(chatNotifierProvider.notifier);

    return Drawer(
      backgroundColor: AppTheme.sidebar,
      child: SafeArea(
        child: Column(
          children: [
            // Brand & New Chat Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          LucideIcons.brain,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'TRA',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(
                          LucideIcons.edit3,
                          size: 17,
                          color: AppTheme.textSecondary,
                        ),
                        onPressed: () {
                          notifier.resetChat();
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // New Chat Button
                  InkWell(
                    onTap: () {
                      notifier.resetChat();
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.plus, size: 15, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'New Deliberation',
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
                ],
              ),
            ),
            const Divider(color: AppTheme.border, height: 1),

            // Threads List
            Expanded(
              child: chatState.threads.isEmpty
                  ? const Center(
                      child: Text(
                        'No previous sessions',
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: chatState.threads.length,
                      itemBuilder: (context, index) {
                        final thread = chatState.threads[index];
                        final isSelected =
                            thread.id == chatState.activeThreadId;

                        return Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.accent
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.primary.withValues(alpha: 0.3)
                                  : Colors.transparent,
                            ),
                          ),
                          child: ListTile(
                            dense: true,
                            leading: Icon(
                              LucideIcons.messageSquare,
                              size: 14,
                              color: isSelected
                                  ? AppTheme.primaryLight
                                  : AppTheme.textMuted,
                            ),
                            title: Text(
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
                                    : FontWeight.w400,
                              ),
                            ),
                            onTap: () {
                              notifier.selectThread(thread.id);
                              Navigator.pop(context);
                            },
                          ),
                        );
                      },
                    ),
            ),

            // User Info Footer
            const Divider(color: AppTheme.border, height: 1),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1E293B),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'AK',
                      style: TextStyle(
                        color: Color(0xFF93C5FD),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Abdullah',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Supabase • Drizzle ORM',
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
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
