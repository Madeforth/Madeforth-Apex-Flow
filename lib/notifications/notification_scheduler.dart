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

  /// Days-before-deadline offsets shared by document expiry and tax/renewal
  /// due-date reminders.
  static const List<int> reminderOffsetsDays = [30, 15, 1];

  /// Schedules up to 3 reminders (30/15/1 days before expiry) for a
  /// document. Offsets already in the past are silently skipped (e.g. a
  /// document expiring in 10 days only gets the 1-day reminder).
  static Future<void> scheduleDocumentExpiryReminder({
    required String docId,
    required String title,
    required DateTime expirationDate,
    required AppStrings strings,
  }) async {
    final nTitle = strings.notifDocExpiryTitle;
    for (final daysLeft in reminderOffsetsDays) {
      final reminderDate = expirationDate.subtract(Duration(days: daysLeft));
      if (reminderDate.isBefore(DateTime.now())) continue;
      await ApexNotificationService.instance.scheduleNotification(
        id: Object.hash(docId, daysLeft),
        title: nTitle,
        body: strings.notifDocExpiryBody(title, daysLeft),
        scheduledDate: reminderDate,
      );
    }
  }

  /// Schedules up to 3 reminders (30/15/1 days before) for a tax/renewal
  /// due date (MTV taksiti, trafik sigortası, muayene, vb.).
  static Future<void> scheduleTaxDueReminder({
    required String recordId,
    required String typeLabel,
    required DateTime dueDate,
    required AppStrings strings,
  }) async {
    final nTitle = strings.notifTaxDueTitle;
    for (final daysLeft in reminderOffsetsDays) {
      final reminderDate = dueDate.subtract(Duration(days: daysLeft));
      if (reminderDate.isBefore(DateTime.now())) continue;
      await ApexNotificationService.instance.scheduleNotification(
        id: Object.hash(recordId, daysLeft),
        title: nTitle,
        body: strings.notifTaxDueBody(typeLabel, daysLeft),
        scheduledDate: reminderDate,
      );
    }
  }
}
