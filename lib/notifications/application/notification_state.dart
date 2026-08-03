import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apexflow/notifications/domain/app_notification.dart';
import 'package:apexflow/notifications/apex_notification_service.dart';

final notificationsProvider =
    NotifierProvider<NotificationsController, List<AppNotification>>(
      NotificationsController.new,
    );

/// Derived provider: count of unread notifications.
final unreadNotificationCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsProvider);
  return notifications.where((n) => !n.isRead).length;
});

class NotificationsController extends Notifier<List<AppNotification>> {
  @override
  List<AppNotification> build() {
    return const [];
  }

  /// Add a new notification to the top of the list and trigger phone notification.
  void addNotification({
    required String title,
    required String body,
    NotificationType type = NotificationType.general,
    String? relatedId,
  }) {
    final notification = AppNotification(
      id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      body: body,
      type: type,
      timestamp: DateTime.now(),
      relatedId: relatedId,
    );

    state = [notification, ...state];

    // Trigger physical notification on the phone
    try {
      final id = DateTime.now().millisecondsSinceEpoch % 100000;
      unawaited(
        ApexNotificationService.instance.showNotification(
          id: id,
          title: title,
          body: body,
          payload: relatedId,
        ),
      );
    } catch (_) {}
  }

  /// Mark a single notification as read.
  void markAsRead(String id) {
    state = [
      for (final n in state)
        if (n.id == id) n.copyWith(isRead: true) else n,
    ];
  }

  /// Mark all notifications as read.
  void markAllAsRead() {
    state = [for (final n in state) n.copyWith(isRead: true)];
  }

  /// Remove a single notification.
  void remove(String id) {
    state = state.where((n) => n.id != id).toList();
  }

  /// Clear all notifications.
  void clearAll() {
    state = const [];
  }
}
