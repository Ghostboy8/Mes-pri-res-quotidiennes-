import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ScheduledReminder {
  final int id;
  final String title;
  final String body;
  final DateTime scheduledTime;
  final String type;

  ScheduledReminder({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledTime,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'scheduledTime': scheduledTime.toIso8601String(),
    'type': type,
  };

  factory ScheduledReminder.fromJson(Map<String, dynamic> json) => ScheduledReminder(
    id: json['id'],
    title: json['title'],
    body: json['body'],
    scheduledTime: DateTime.parse(json['scheduledTime']),
    type: json['type'],
  );
}

class NotificationService with ChangeNotifier {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  int _notificationIdCounter = 0;
  List<ScheduledReminder> _scheduledReminders = [];

  Future<void> init() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('ic_stat_notification');
    const InitializationSettings settings = InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint('Notification clicked: ${details.payload}');
      },
    );

    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          'prayer_channel_id',
          'Prayer Reminders',
          description: 'Notifications for prayer reminders',
          importance: Importance.max,
        ),
      );

      // Request permissions
      bool? notificationsGranted = await androidPlugin?.requestNotificationsPermission();
      bool? exactAlarmsGranted = await androidPlugin?.requestExactAlarmsPermission();

      if (notificationsGranted != true || exactAlarmsGranted != true) {
        debugPrint('Notification or Exact Alarm permission denied');
      }
    }

    await _loadScheduledReminders();
    await _rescheduleStoredReminders();
  }

  Future<void> _loadScheduledReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final String? remindersJson = prefs.getString('scheduled_reminders');
    if (remindersJson != null) {
      final List<dynamic> jsonList = jsonDecode(remindersJson);
      _scheduledReminders = jsonList.map((json) => ScheduledReminder.fromJson(json)).toList();
      _notificationIdCounter = _scheduledReminders.isNotEmpty
          ? _scheduledReminders.map((r) => r.id).reduce((a, b) => a > b ? a : b) + 1
          : 0;
    }
    notifyListeners();
  }

  Future<void> _saveScheduledReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(_scheduledReminders.map((r) => r.toJson()).toList());
    await prefs.setString('scheduled_reminders', jsonString);
    notifyListeners();
  }

  Future<void> _rescheduleStoredReminders() async {
    final now = tz.TZDateTime.now(tz.local);
    for (var reminder in List.from(_scheduledReminders)) {
      tz.TZDateTime tzScheduledTime = tz.TZDateTime.from(reminder.scheduledTime, tz.local);
      if (tzScheduledTime.isBefore(now)) {
        _scheduledReminders.remove(reminder);
        continue;
      }
      await _schedule(tzScheduledTime, reminder.id, reminder.title, reminder.body);
    }
    await _saveScheduledReminders();
  }

  Future<void> _schedule(tz.TZDateTime scheduledTime, int id, String title, String body) async {
    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'prayer_channel_id',
          'Prayer Reminders',
          channelDescription: 'Notifications for prayer reminders',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
    debugPrint('Scheduled notification: $title at ${scheduledTime.toString()} with ID: $id');
  }

  Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledTime,
    required String type,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);
    if (tzScheduledTime.isBefore(now)) {
      tzScheduledTime = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        scheduledTime.hour,
        scheduledTime.minute,
      ).add(const Duration(days: 1));
    }
    final uniqueId = _notificationIdCounter++;
    await _schedule(tzScheduledTime, uniqueId, title, body);
    _scheduledReminders.add(
      ScheduledReminder(
        id: uniqueId,
        title: title,
        body: body,
        scheduledTime: tzScheduledTime,
        type: type,
      ),
    );
    await _saveScheduledReminders();
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
    _scheduledReminders.removeWhere((r) => r.id == id);
    await _saveScheduledReminders();
  }

  List<ScheduledReminder> getScheduledReminders() {
    final now = tz.TZDateTime.now(tz.local);
    _scheduledReminders.removeWhere((r) => tz.TZDateTime.from(r.scheduledTime, tz.local).isBefore(now));
    return List.from(_scheduledReminders);
  }
}