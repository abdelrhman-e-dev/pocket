import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../../core/services/notification_service.dart';

class ReminderSettings {
  const ReminderSettings({
    required this.enabled,
    required this.time,
    required this.timezone,
    this.permissionDenied = false,
  });

  final bool enabled;
  final TimeOfDay time;
  final String timezone;
  final bool permissionDenied;

  ReminderSettings copyWith({
    bool? enabled,
    TimeOfDay? time,
    String? timezone,
    bool? permissionDenied,
  }) => ReminderSettings(
    enabled: enabled ?? this.enabled,
    time: time ?? this.time,
    timezone: timezone ?? this.timezone,
    permissionDenied: permissionDenied ?? this.permissionDenied,
  );
}

final reminderSettingsProvider =
    StateNotifierProvider<ReminderSettingsController, ReminderSettings>((ref) {
      return ReminderSettingsController(
        SharedPreferencesAsync(),
        NotificationService.instance,
      );
    });

class ReminderSettingsController extends StateNotifier<ReminderSettings> {
  ReminderSettingsController(this._preferences, this._notifications)
    : super(
        const ReminderSettings(
          enabled: false,
          time: TimeOfDay(hour: 21, minute: 0),
          timezone: 'UTC',
        ),
      ) {
    _load();
  }

  static const _enabledKey = 'daily_reminder_enabled';
  static const _hourKey = 'daily_reminder_hour';
  static const _minuteKey = 'daily_reminder_minute';
  static const _timezoneKey = NotificationService.timezonePreferenceKey;

  final SharedPreferencesAsync _preferences;
  final NotificationService _notifications;

  Future<void> _load() async {
    final enabled = await _preferences.getBool(_enabledKey) ?? false;
    final hour = await _preferences.getInt(_hourKey) ?? 21;
    final minute = await _preferences.getInt(_minuteKey) ?? 0;
    var timezone = await _preferences.getString(_timezoneKey) ?? 'UTC';
    try {
      _notifications.setTimezone(timezone);
    } catch (_) {
      timezone = 'UTC';
      _notifications.setTimezone(timezone);
    }
    state = state.copyWith(
      enabled: enabled,
      time: TimeOfDay(hour: hour, minute: minute),
      timezone: timezone,
    );
    if (enabled) {
      await _notifications.scheduleDaily(state.time);
    }
  }

  Future<bool> setEnabled(bool enabled) async {
    if (enabled) {
      final granted = await _notifications.requestPermission();
      if (!granted) {
        state = state.copyWith(permissionDenied: true);
        return false;
      }
      await _notifications.scheduleDaily(state.time);
    } else {
      await _notifications.cancelReminder();
    }
    await _preferences.setBool(_enabledKey, enabled);
    state = state.copyWith(enabled: enabled, permissionDenied: false);
    return true;
  }

  Future<void> setTime(TimeOfDay time) async {
    await _preferences.setInt(_hourKey, time.hour);
    await _preferences.setInt(_minuteKey, time.minute);
    state = state.copyWith(time: time);
    if (state.enabled) await _notifications.scheduleDaily(time);
  }

  Future<void> setTimezone(String timezone) async {
    _notifications.setTimezone(timezone);
    await _preferences.setString(_timezoneKey, timezone);
    state = state.copyWith(timezone: timezone);
    if (state.enabled) await _notifications.scheduleDaily(state.time);
  }

  List<String> get availableTimezones =>
      tz.timeZoneDatabase.locations.keys.toList()..sort();
}
