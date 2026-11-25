import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'l10n.dart';
import 'storage.dart';

/// إشعارات محلية بالكامل، بلا إنترنت ولا خوادم.
abstract final class Notifications {
  static final FlutterLocalNotificationsPlugin plugin =
      FlutterLocalNotificationsPlugin();
  static const int _dailyId = 910;
  static const String _channelId = 'data_hmamat_daily';
  static bool _ready = false;

  static Future<void> init() async {
    tzdata.initializeTimeZones();
    try {
      final name = await FlutterTimezone.getLocalTimezone();
      if (name.isNotEmpty) tz.setLocalLocation(tz.getLocation(name));
    } catch (_) {
      // يبقى التوقيت UTC إذا تعذّر قراءة منطقة الجهاز.
    }

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await plugin.initialize(settings);
    try {
      await plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } catch (_) {
      // قد تُرفض الأذونات؛ التطبيق يعمل بدون إشعارات.
    }
    _ready = true;
  }

  static Future<void> sync() async {
    if (!_ready) return;
    await plugin.cancel(_dailyId);
    final store = Store.instance;
    if (!store.notificationsEnabled || store.dueBirds.isEmpty) return;

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      store.notificationHour,
      store.notificationMinute,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        'Data Hmamat',
        channelDescription: 'Weekly bird photo reminders',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    final count = store.dueBirds.length;
    final title = L.isAr ? 'صور الحمام الأسبوعية' : 'Weekly pigeon photos';
    final body = L.isAr
        ? '$count طير ينتظر صورته الأسبوعية'
        : '$count birds waiting for weekly photos';

    try {
      await plugin.zonedSchedule(
        _dailyId,
        title,
        body,
        scheduled,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (_) {
      // بعض الأجهزة تمنع الإشعارات المجدولة؛ لا يُوقف عمل التطبيق.
    }
  }

  static Future<void> test() async {
    if (!_ready) return;
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        'Data Hmamat',
        channelDescription: 'Weekly bird photo reminders',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );
    try {
      await plugin.show(
        911,
        L.isAr ? 'Data Hmamat' : 'Data Hmamat',
        L.isAr ? 'التنبيهات تعمل بشكل صحيح' : 'Notifications are working',
        details,
      );
    } catch (_) {
      // تجاهل فشل العرض على الأجهزة التي ترفض الإشعارات.
    }
  }
}
