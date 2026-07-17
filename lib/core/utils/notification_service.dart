import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(const InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    ));
    await _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(
      const AndroidNotificationChannel(
        'ergofit_breaks',
        'Pausas activas',
        description: 'Recordatorios de pausas y estiramientos',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      ),
    );
    _initialized = true;
  }

  Future<bool> requestPermission() async {
    final granted = await _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
    await _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    return granted ?? true;
  }

  Future<void> scheduleAlarm({
    required int notificationId,
    required String name,
    required int startHour,
    required int startMinute,
    required int intervalMinutes,
    required List<bool> weekdays,
  }) async {
    await cancelAlarm(notificationId);
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'ergofit_breaks',
        'Pausas activas',
        channelDescription: 'Recordatorios de pausas y estiramientos',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        enableVibration: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
    final now = tz.TZDateTime.now(tz.local);
    for (int dayIndex = 0; dayIndex < 7; dayIndex++) {
      if (!weekdays[dayIndex]) continue;
      final weekday = dayIndex + 1;
      final maxNotifs = (480 / intervalMinutes).ceil();
      for (int i = 0; i < maxNotifs; i++) {
        final totalMinutes = startHour * 60 + startMinute + (intervalMinutes * i);
        final hour = (totalMinutes ~/ 60) % 24;
        final minute = totalMinutes % 60;
        if (totalMinutes > 23 * 60 + 59) break;
        final scheduleDate = _nextWeekdayTime(now, weekday, hour, minute);
        final uniqueId = notificationId + (dayIndex * 100) + i;
        await _plugin.zonedSchedule(
          uniqueId,
          '⏰ ¡Hora de tu pausa activa!',
          '$name · Tómate un momento para estirarte 🧘',
          scheduleDate,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      }
    }
  }

  Future<void> cancelAlarm(int notificationId) async {
    for (int day = 0; day < 7; day++) {
      for (int i = 0; i < 20; i++) {
        await _plugin.cancel(notificationId + (day * 100) + i);
      }
    }
  }

  Future<void> cancelAll() => _plugin.cancelAll();

  Future<void> showTestNotification() async {
    await _plugin.show(
      99999,
      '✅ ¡Notificaciones funcionando!',
      'ErgoFit puede enviarte recordatorios de pausa',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'ergofit_breaks',
          'Pausas activas',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
      ),
    );
  }

  tz.TZDateTime _nextWeekdayTime(tz.TZDateTime from, int weekday, int hour, int minute) {
    var date = tz.TZDateTime(tz.local, from.year, from.month, from.day, hour, minute);
    while (date.weekday != weekday || date.isBefore(from)) {
      date = date.add(const Duration(days: 1));
    }
    return date;
  }
}