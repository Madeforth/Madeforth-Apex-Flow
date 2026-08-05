import 'package:apexflow/core/i18n/app_strings.dart';
import 'package:apexflow/garage/domain/motorcycle_profile.dart';
import 'package:apexflow/notifications/apex_notification_service.dart';

class NotificationScheduler {
  static const int _serviceAlertId = 1001;
  static const int _componentAlertId = 1002;
  static const int _dailyCheckAlertId = 1003;

  /// Syncs notifications based on current motorcycle status.
  static Future<void> syncNotifications(
    MotorcycleProfile bike,
    AppStrings strings,
  ) async {
    // 1. Check Service Window State
    final serviceState = bike.serviceWindowState;
    if (serviceState == ServiceWindowState.overdue) {
      final title = strings.notifServiceOverdueTitle;
      final body = strings.notifServiceOverdueBody(bike.name);
      await ApexNotificationService.instance.showNotification(
        id: _serviceAlertId,
        title: title,
        body: body,
      );
    } else if (serviceState == ServiceWindowState.dueSoon) {
      final title = strings.notifServiceSoonTitle;
      final body = strings.notifServiceSoonBody(bike.name, bike.kmUntilService);
      await ApexNotificationService.instance.showNotification(
        id: _serviceAlertId,
        title: title,
        body: body,
      );
    } else {
      await ApexNotificationService.instance.cancelNotification(
        _serviceAlertId,
      );
    }

    // 2. Check Component Health Wear Alerts
    final warningComponents = <String>[];
    if (bike.chainWearPercent >= 75) warningComponents.add(strings.notifChain);
    if (bike.tireWearPercent >= 75) warningComponents.add(strings.notifTires);
    if (bike.brakeWearPercent >= 75) warningComponents.add(strings.notifBrakes);
    if (bike.oilHealthPercent <= 30) warningComponents.add(strings.notifOil);
    if (bike.batteryHealthPercent <= 30)
      warningComponents.add(strings.notifBattery);

    if (warningComponents.isNotEmpty) {
      final title = strings.notifComponentWarningTitle;
      final body = strings.notifComponentWarningBody(
        warningComponents.join(", "),
      );
      await ApexNotificationService.instance.showNotification(
        id: _componentAlertId,
        title: title,
        body: body,
      );
    } else {
      await ApexNotificationService.instance.cancelNotification(
        _componentAlertId,
      );
    }
  }

  /// Schedules a reminder for the daily safety checklist (Daily Check)
  static Future<void> scheduleDailyCheckReminder(
    AppStrings strings, {
    int delayHours = 24,
  }) async {
    final title = strings.notifDailyCheckTitle;
    final body = strings.notifDailyCheckBody;

    await ApexNotificationService.instance.scheduleNotification(
      id: _dailyCheckAlertId,
      title: title,
      body: body,
      scheduledDate: DateTime.now().add(Duration(hours: delayHours)),
    );
  }

  /// Schedules a reminder for document expiration (30 days before expiry).
  /// If the document expires in under 30 days, falls back to a near-term
  /// reminder (1 hour from now, or 1 day before expiry if that's later)
  /// rather than silently scheduling nothing.
  static Future<void> scheduleDocumentExpiryReminder({
    required String docId,
    required String title,
    required DateTime expirationDate,
    required AppStrings strings,
  }) async {
    final now = DateTime.now();
    var reminderDate = expirationDate.subtract(const Duration(days: 30));
    if (reminderDate.isBefore(now)) {
      final oneDayBefore = expirationDate.subtract(const Duration(days: 1));
      final soon = now.add(const Duration(hours: 1));
      reminderDate = oneDayBefore.isAfter(soon) ? oneDayBefore : soon;
      if (reminderDate.isBefore(now) || reminderDate.isAfter(expirationDate)) {
        return; // Already expired or expiring within the hour — nothing meaningful to remind.
      }
    }

    final nTitle = strings.notifDocExpiryTitle;
    final nBody = strings.notifDocExpiryBody(title);

    await ApexNotificationService.instance.scheduleNotification(
      id: docId.hashCode,
      title: nTitle,
      body: nBody,
      scheduledDate: reminderDate,
    );
  }

  /// Cancels a previously scheduled document expiry reminder for [docId].
  static Future<void> cancelDocumentExpiryReminder(String docId) async {
    await ApexNotificationService.instance.cancelNotification(docId.hashCode);
  }
}
