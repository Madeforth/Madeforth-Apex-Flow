import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apexflow/core/design/apex_colors.dart';
import 'package:apexflow/core/design/apex_spacing.dart';
import 'package:apexflow/core/i18n/app_strings.dart';
import 'package:apexflow/notifications/application/notification_state.dart';
import 'package:apexflow/notifications/domain/app_notification.dart';
import 'package:apexflow/core/design/theme_extensions.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key, required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = strings.locale.languageCode == 'tr';
    final notifications = ref.watch(notificationsProvider);
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(ApexSpacing.x2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.notifications_outlined,
                            color: context.colors.cyan,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            tInline(
                              AppStrings.currentLanguageCode,
                              'Bildirimler',
                              'Notifications',
                              'Benachrichtigungen',
                            ),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: context.colors.white,
                            ),
                          ),
                        ],
                      ),
                      if (unreadCount > 0) ...[
                        const SizedBox(height: 4),
                        Text(
                          tInline(
                            AppStrings.currentLanguageCode,
                            '$unreadCount okunmamış bildirim',
                            '$unreadCount unread',
                            '$unreadCount ungelesen',
                          ),
                          style: TextStyle(
                            color: context.colors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (notifications.isNotEmpty)
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: context.colors.textSecondary,
                      ),
                      color: context.colors.surface,
                      onSelected: (value) {
                        if (value == 'read_all') {
                          ref
                              .read(notificationsProvider.notifier)
                              .markAllAsRead();
                        } else if (value == 'clear_all') {
                          ref.read(notificationsProvider.notifier).clearAll();
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'read_all',
                          child: Row(
                            children: [
                              Icon(
                                Icons.done_all,
                                size: 18,
                                color: context.colors.cyan,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                tInline(
                                  AppStrings.currentLanguageCode,
                                  'Tümünü Okundu İşaretle',
                                  'Mark All Read',
                                  'Alle als gelesen markieren',
                                ),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: context.colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'clear_all',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_sweep_outlined,
                                size: 18,
                                color: context.colors.red,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                tInline(
                                  AppStrings.currentLanguageCode,
                                  'Tümünü Temizle',
                                  'Clear All',
                                  'Alles löschen',
                                ),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: context.colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            Divider(color: context.colors.border, height: 1),

            // Notification list
            Expanded(
              child: notifications.isEmpty
                  ? _EmptyState(tr: tr)
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: notifications.length,
                      separatorBuilder: (_, __) => Divider(
                        color: context.colors.border,
                        height: 1,
                        indent: 64,
                      ),
                      itemBuilder: (context, index) {
                        final notif = notifications[index];
                        return _NotificationTile(
                          notification: notif,
                          tr: tr,
                          onTap: () {
                            ref
                                .read(notificationsProvider.notifier)
                                .markAsRead(notif.id);
                          },
                          onDismiss: () {
                            ref
                                .read(notificationsProvider.notifier)
                                .remove(notif.id);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.tr});
  final bool tr;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 56,
            color: context.colors.muted.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            tInline(
              AppStrings.currentLanguageCode,
              'Bildirim yok',
              'No notifications',
              'Keine Benachrichtigungen',
            ),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            tInline(
              AppStrings.currentLanguageCode,
              'Yeni bildirimler burada görünecek.',
              'New notifications will appear here.',
              'Hier werden neue Benachrichtigungen angezeigt.',
            ),
            style: TextStyle(fontSize: 12, color: context.colors.muted),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.tr,
    required this.onTap,
    required this.onDismiss,
  });

  final AppNotification notification;
  final bool tr;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;
    final timeDiff = DateTime.now().difference(notification.timestamp);
    final timeAgo = _formatTimeAgo(timeDiff, tr);

    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: context.colors.red.withValues(alpha: 0.15),
        child: Icon(Icons.delete_outline, color: context.colors.red, size: 22),
      ),
      onDismissed: (_) => onDismiss(),
      child: InkWell(
        onTap: onTap,
        child: Container(
          color: isUnread
              ? context.colors.cyan.withValues(alpha: 0.04)
              : Colors.transparent,
          padding: const EdgeInsets.symmetric(
            horizontal: ApexSpacing.x2,
            vertical: 12,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _iconBgColor(context).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(_iconData, size: 20, color: _iconBgColor(context)),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isUnread
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: context.colors.white,
                            ),
                          ),
                        ),
                        Text(
                          timeAgo,
                          style: TextStyle(
                            fontSize: 10,
                            color: context.colors.muted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      notification.body,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.colors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Unread dot
              if (isUnread) ...[
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(
                    color: context.colors.cyan,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData get _iconData {
    switch (notification.type) {
      case NotificationType.friendRequest:
        return Icons.person_add_alt_1_outlined;
      case NotificationType.friendAdded:
        return Icons.people_outline;
      case NotificationType.general:
        return Icons.info_outline;
    }
  }

  Color _iconBgColor(BuildContext context) {
    switch (notification.type) {
      case NotificationType.friendRequest:
        return context.colors.cyan;
      case NotificationType.friendAdded:
        return context.colors.healthy;
      case NotificationType.general:
        return context.colors.muted;
    }
  }

  String _formatTimeAgo(Duration diff, bool tr) {
    if (diff.inMinutes < 1)
      return tInline(AppStrings.currentLanguageCode, 'şimdi', 'now', 'Jetzt');
    if (diff.inMinutes < 60)
      return '${diff.inMinutes}${tInline(AppStrings.currentLanguageCode, ' dk', 'm', 'M')}';
    if (diff.inHours < 24)
      return '${diff.inHours}${tInline(AppStrings.currentLanguageCode, ' sa', 'h', 'H')}';
    if (diff.inDays < 7)
      return '${diff.inDays}${tInline(AppStrings.currentLanguageCode, ' gün', 'd', 'D')}';
    return '${(diff.inDays / 7).floor()}${tInline(AppStrings.currentLanguageCode, ' hf', 'w', 'w')}';
  }
}
