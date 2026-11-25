import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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

    // نحسب وقت الجهاز المحلي ثم نحوله إلى UTC، فلا نحتاج إضافة أصلية للمنطقة الزمنية.
    final deviceNow = DateTime.now();
    final target = DateTime(
      deviceNow.year,
      deviceNow.month,
      deviceNow.day,
      store.notificationHour,
      store.notificationMinute,
    ).subtract(deviceNow.timeZoneOffset);
    var scheduled = tz.TZDateTime.utc(
      target.year,
      target.month,
      target.day,
      target.hour,
      target.minute,
    );
    final nowUtc = tz.TZDateTime.now(tz.UTC);
    if (!scheduled.isAfter(nowUtc)) {
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
        'Data Hmamat',
        L.isAr ? 'التنبيهات تعمل بشكل صحيح' : 'Notifications are working',
        details,
      );
    } catch (_) {
      // تجاهل فشل العرض على الأجهزة التي ترفض الإشعارات.
    }
  }
}
