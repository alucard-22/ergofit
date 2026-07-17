import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/utils/notification_service.dart';

// ── Stream de alarmas ─────────────────────────────────────────────────────────

/// Stream reactivo de todas las alarmas.
/// La UI se actualiza automáticamente cada vez que cambia la tabla.
final alarmsStreamProvider = StreamProvider<List<Alarm>>((ref) {
  final dao = ref.watch(alarmsDaoProvider);
  return dao.watchAll();
});

// ── Notifier para CRUD ────────────────────────────────────────────────────────

class AlarmsNotifier extends Notifier<void> {
  @override
  void build() {}

  /// Crea una alarma nueva y programa sus notificaciones.
  Future<void> create({
    required String name,
    required TimeOfDay startTime,
    required int intervalMinutes,
    required List<bool> weekdays,
    required List<String> categories,
  }) async {
    final dao   = ref.read(alarmsDaoProvider);
    final notif = NotificationService.instance;

    final notifId =
        DateTime.now().millisecondsSinceEpoch % 2000000000;

    final alarm = AlarmsCompanion.insert(
      id:              const Uuid().v4(),
      name:            name,
      startHour:       startTime.hour,
      startMinute:     startTime.minute,
      intervalMinutes: intervalMinutes,
      weekdaysJson:    jsonEncode(weekdays),
      categoriesJson:  jsonEncode(categories),
      notificationId:  notifId,
      createdAt:       DateTime.now().millisecondsSinceEpoch,
    );

    await dao.insertAlarm(alarm);

    await notif.scheduleAlarm(
      notificationId:  notifId,
      name:            name,
      startHour:       startTime.hour,
      startMinute:     startTime.minute,
      intervalMinutes: intervalMinutes,
      weekdays:        weekdays,
    );
  }

  /// Activa o desactiva una alarma.
  Future<void> toggle(Alarm alarm) async {
    final dao        = ref.read(alarmsDaoProvider);
    final notif      = NotificationService.instance;
    final newEnabled = !alarm.isEnabled;

    await dao.toggleEnabled(alarm.id, newEnabled);

    if (newEnabled) {
      await notif.scheduleAlarm(
        notificationId:  alarm.notificationId,
        name:            alarm.name,
        startHour:       alarm.startHour,
        startMinute:     alarm.startMinute,
        intervalMinutes: alarm.intervalMinutes,
        weekdays: List<bool>.from(
            jsonDecode(alarm.weekdaysJson)),
      );
    } else {
      await notif.cancelAlarm(alarm.notificationId);
    }
  }

  /// Elimina una alarma y cancela sus notificaciones.
  Future<void> delete(Alarm alarm) async {
    final dao  = ref.read(alarmsDaoProvider);
    final notif = NotificationService.instance;
    await notif.cancelAlarm(alarm.notificationId);
    await dao.deleteById(alarm.id);
  }
}

final alarmsNotifierProvider =
    NotifierProvider<AlarmsNotifier, void>(AlarmsNotifier.new);