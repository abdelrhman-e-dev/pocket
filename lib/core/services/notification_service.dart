import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final instance = NotificationService._();
  static const reminderNotificationId = 1001;
  static const timezonePreferenceKey = 'daily_reminder_timezone';

  final _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize({void Function(String?)? onNotificationTap}) async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOS = DarwinInitializationSettings();
    await _notifications.initialize(
      const InitializationSettings(android: android, iOS: iOS),
      onDidReceiveNotificationResponse: (response) {
        onNotificationTap?.call(response.payload);
      },
    );
    _initialized = true;
  }

  Future<bool> requestPermission() async {
    final android = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final iOS = _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();

    final androidGranted = await android?.requestNotificationsPermission();
    final iOSGranted = await iOS?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    final exactAlarmGranted = await android?.requestExactAlarmsPermission();
    return (androidGranted ?? true) &&
        (iOSGranted ?? true) &&
        (exactAlarmGranted ?? true);
  }

  Future<void> restoreFromPreferences(
    SharedPreferencesAsync preferences,
  ) async {
    final timezone = await preferences.getString(timezonePreferenceKey);
    if (timezone != null) {
      try {
        setTimezone(timezone);
      } catch (_) {
        setTimezone('UTC');
      }
    }
    if (await preferences.getBool('daily_reminder_enabled') != true) return;
    final hour = await preferences.getInt('daily_reminder_hour') ?? 21;
    final minute = await preferences.getInt('daily_reminder_minute') ?? 0;
    await scheduleDaily(TimeOfDay(hour: hour, minute: minute));
  }

  void setTimezone(String timezone) {
    tz.setLocalLocation(tz.getLocation(timezone));
  }

  Future<void> scheduleDaily(TimeOfDay time) async {
    await cancelReminder();
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      reminderNotificationId,
      'لا تنسَ تسجيل مصروفاتك اليوم',
      'خذ دقيقة لتسجيل دخلك أو مصروفك',
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminders',
          'التذكيرات اليومية',
          channelDescription: 'تذكير يومي لتسجيل المعاملات',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: '/add-transaction',
    );
  }

  Future<void> cancelReminder() =>
      _notifications.cancel(reminderNotificationId);
}
