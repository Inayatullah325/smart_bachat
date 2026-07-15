import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// ─── Background isolate handler ─────────────────────────────────────────────
@pragma('vm:entry-point')
void _onBackgroundNotificationResponse(NotificationResponse response) {
  _persistNotificationWithCurrentTime(response.payload);
}

void _persistNotificationWithCurrentTime(String? payload) {
  if (payload == null || payload.isEmpty) return;
  SharedPreferences.getInstance().then((p) {
    final parts = payload.split('||');
    if (parts.length < 2) return;

    final scheduledKey = parts[0];
    final title = parts.length > 1 ? parts[1] : '';
    final body = parts.length > 2 ? parts[2] : '';

    // Read the currently logged-in user's UID so history is per-user
    final uid = p.getString('loggedInUID') ?? 'guest';
    final historyKey = 'notification_history_$uid';
    final lastFireKey = 'last_recorded_fire_$uid';

    final history = p.getStringList(historyKey) ?? [];
    if (history.any((e) => e.contains('|key:$scheduledKey|'))) return;

    final actualNow = DateTime.now().toIso8601String();
    final entry = '$actualNow||$title||$body|key:$scheduledKey|';
    history.insert(0, entry);
    while (history.length > 30) history.removeLast();

    p.setStringList(historyKey, history);
    p.setString(lastFireKey, scheduledKey);
    NotificationService.historyChanged.value++;
  });
}

// ─── Service ─────────────────────────────────────────────────────────────────
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  /// Incremented every time a new notification is persisted.
  /// NotificationsScreen listens to this to auto-refresh instantly.
  static final ValueNotifier<int> historyChanged = ValueNotifier(0);

  static const _channelId = 'smart_bachat_daily_v1';
  static const _notifId = 0;
  static const _defaultTitle = 'Smart Bachat Reminder 💰';
  static const _defaultBody =
      "Don't forget to add today's income & expenses. Smart tracking leads to smart savings! ✨";

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // ─── Per-user key helpers ────────────────────────────────────────────────
  Future<String> _uid() async {
    final p = await SharedPreferences.getInstance();
    return p.getString('loggedInUID') ?? 'guest';
  }

  String _enabledKey(String uid) => 'notif_enabled_$uid';
  String _hourKey(String uid) => 'notification_hour_$uid';
  String _minuteKey(String uid) => 'notification_minute_$uid';
  String _historyKey(String uid) => 'notification_history_$uid';
  String _nextFireKey(String uid) => 'next_fire_time_$uid';
  String _pendingTitleKey(String uid) => 'pending_title_$uid';
  String _pendingBodyKey(String uid) => 'pending_body_$uid';
  String _lastFireKey(String uid) => 'last_recorded_fire_$uid';

  // ─── Init ─────────────────────────────────────────────────────────────────
  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    final tzInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(tzInfo.identifier));

    const android = AndroidInitializationSettings('@drawable/ic_stat_notify');

    await _plugin.initialize(
      settings: const InitializationSettings(android: android),
      onDidReceiveNotificationResponse: handleNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          _onBackgroundNotificationResponse,
    );

    final impl = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await impl?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        'Daily Reminders',
        description: 'Daily reminder to track your income & expenses',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      ),
    );

    await impl?.requestNotificationsPermission();
    await impl?.requestExactAlarmsPermission();

    _initialized = true;
    await syncFiredNotifications();
    if (await isEnabled()) {
      await scheduleDailyNotification();
    }
  }

  void handleNotificationResponse(NotificationResponse response) {
    _persistNotificationWithCurrentTime(response.payload);
  }

  // ─── Enable / Disable ────────────────────────────────────────────────────
  Future<bool> isEnabled() async {
    final uid = await _uid();
    final p = await SharedPreferences.getInstance();
    return p.getBool(_enabledKey(uid)) ?? true;
  }

  Future<void> setEnabled(bool value) async {
    final uid = await _uid();
    final p = await SharedPreferences.getInstance();
    await p.setBool(_enabledKey(uid), value);
    if (value) {
      await scheduleDailyNotification();
    } else {
      await _plugin.cancel(id: _notifId);
    }
  }

  Future<(int hour, int minute)> getNotificationTime() async {
    final uid = await _uid();
    final p = await SharedPreferences.getInstance();
    return (p.getInt(_hourKey(uid)) ?? 20, p.getInt(_minuteKey(uid)) ?? 0);
  }

  // ─── Schedule ─────────────────────────────────────────────────────────────
  Future<void> scheduleDailyNotification() async {
    final uid = await _uid();
    final p = await SharedPreferences.getInstance();

    if (!(p.getBool(_enabledKey(uid)) ?? true)) return;

    final hour = p.getInt(_hourKey(uid)) ?? 20;
    final minute = p.getInt(_minuteKey(uid)) ?? 0;

    final scheduledDate = _nextInstanceOfTime(hour, minute);
    final payload = _buildPayload(scheduledDate, _defaultTitle, _defaultBody);

    await p.setString(_nextFireKey(uid), scheduledDate.toIso8601String());
    await p.setString(_pendingTitleKey(uid), _defaultTitle);
    await p.setString(_pendingBodyKey(uid), _defaultBody);

    await _plugin.zonedSchedule(
      id: _notifId,
      title: _defaultTitle,
      body: _defaultBody,
      scheduledDate: scheduledDate,
      payload: payload,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'Daily Reminders',
          channelDescription: 'Daily reminder to track your income & expenses',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          icon: '@drawable/ic_stat_notify',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // ─── Update time ──────────────────────────────────────────────────────────
  Future<void> updateNotificationTime(int hour, int minute) async {
    final uid = await _uid();
    final p = await SharedPreferences.getInstance();
    await p.setInt(_hourKey(uid), hour);
    await p.setInt(_minuteKey(uid), minute);
    if (await isEnabled()) {
      await scheduleDailyNotification();
    }
  }

  // ─── History sync (when notification fires and app reopens) ───────────────
  Future<void> syncFiredNotifications() async {
    final uid = await _uid();
    final p = await SharedPreferences.getInstance();

    final nextFireStr = p.getString(_nextFireKey(uid));
    if (nextFireStr == null) return;

    final title = p.getString(_pendingTitleKey(uid)) ?? _defaultTitle;
    final body = p.getString(_pendingBodyKey(uid)) ?? _defaultBody;
    final lastRecordedStr = p.getString(_lastFireKey(uid));
    final lastRecorded = lastRecordedStr != null
        ? DateTime.tryParse(lastRecordedStr)
        : null;

    var nextFire = DateTime.parse(nextFireStr);
    final now = DateTime.now();

    while (!nextFire.isAfter(now)) {
      if (lastRecorded == null || nextFire.isAfter(lastRecorded)) {
        await _addToHistory(uid, nextFire, title, body);
        await p.setString(_lastFireKey(uid), nextFire.toIso8601String());
      }
      nextFire = nextFire.add(const Duration(days: 1));
    }

    await p.setString(_nextFireKey(uid), nextFire.toIso8601String());
  }

  Future<List<Map<String, String>>> getHistory() async {
    await syncFiredNotifications();
    final uid = await _uid();
    final p = await SharedPreferences.getInstance();
    final raw = p.getStringList(_historyKey(uid)) ?? [];
    return raw.map((e) {
      final parts = e.split('||');
      final time = parts.isNotEmpty ? parts[0] : '';
      final title = parts.length > 1 ? parts[1] : '';
      // body may contain "|key:....|", strip it
      final body = parts.length > 2
          ? parts[2].replaceAll(RegExp(r'\|key:[^|]*\|'), '')
          : '';
      return {'time': time, 'title': title, 'body': body};
    }).toList();
  }

  Future<void> clearHistory() async {
    final uid = await _uid();
    final p = await SharedPreferences.getInstance();
    await p.remove(_historyKey(uid));
  }

  /// Deletes specific items from history by their indices (0-based).
  Future<void> deleteHistoryItemsByIndex(List<int> indices) async {
    final uid = await _uid();
    final p = await SharedPreferences.getInstance();
    final raw = p.getStringList(_historyKey(uid)) ?? [];
    final sortedDesc = indices.toSet().toList()..sort((a, b) => b.compareTo(a));
    for (final i in sortedDesc) {
      if (i >= 0 && i < raw.length) raw.removeAt(i);
    }
    await p.setStringList(_historyKey(uid), raw);
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  String _buildPayload(DateTime time, String title, String body) {
    return '${time.toIso8601String()}||$title||$body';
  }

  Future<void> _addToHistory(
    String uid,
    DateTime scheduledTime,
    String title,
    String body,
  ) async {
    final p = await SharedPreferences.getInstance();
    final history = p.getStringList(_historyKey(uid)) ?? [];

    final scheduledKey = scheduledTime.toIso8601String();
    final exists = history.any(
      (e) => e.startsWith(scheduledKey) || e.contains('|key:$scheduledKey|'),
    );
    if (exists) return;

    final actualNow = DateTime.now().toIso8601String();
    final entry = '$actualNow||$title||$body|key:$scheduledKey|';
    history.insert(0, entry);
    while (history.length > 30) history.removeLast();

    await p.setStringList(_historyKey(uid), history);
    await p.setString(_lastFireKey(uid), scheduledKey);
    historyChanged.value++;
  }
}
