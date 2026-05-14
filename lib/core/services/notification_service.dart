import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

/// Singleton service for managing local notifications.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Initializes the notification plugin, timezones, and requests permissions.
  Future<void> initialize() async {
    tz.initializeTimeZones();

    try {
      dynamic tzInfo = await FlutterTimezone.getLocalTimezone();
      String timeZoneName = tzInfo.toString();

      if (timeZoneName.startsWith('TimezoneInfo(')) {
        timeZoneName = timeZoneName.substring(13).split(',').first.trim();
      }

      tz.setLocalLocation(tz.getLocation(timeZoneName));
      debugPrint('Timezone configured: $timeZoneName');
    } catch (e) {
      debugPrint('Error configuring timezone: $e');
      tz.setLocalLocation(tz.getLocation('Europe/Madrid'));
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('ic_notification');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(settings: initSettings);
    await requestExactAlarmPermission();
  }

  /// Schedules a daily repeating notification at the specified time.
  Future<void> scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    await _notificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: _nextInstanceOfTime(hour, minute),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminders_channel_id',
          'Daily Reminders',
          channelDescription: 'Notifications for supplements and daily tasks',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Cancels a scheduled notification by its [id].
  Future<void> cancelReminder(int id) async {
    await _notificationsPlugin.cancel(id: id);
  }

  /// Calculates the next occurrence of the specified [hour] and [minute].
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  /// Requests exact alarm permissions for Android devices.
  Future<void> requestExactAlarmPermission() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidImplementation != null) {
      await androidImplementation.requestExactAlarmsPermission();
    }
  }
}
