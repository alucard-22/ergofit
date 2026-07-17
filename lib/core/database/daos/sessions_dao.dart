import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/sessions_table.dart';

part 'sessions_dao.g.dart';

@DriftAccessor(tables: [Sessions])
class SessionsDao extends DatabaseAccessor<AppDatabase>
    with _$SessionsDaoMixin {
  SessionsDao(super.db);

  // ── Inserción ─────────────────────────────────────────────────────────────

  Future<void> insertSession(SessionsCompanion entry) =>
      into(sessions).insert(entry);

  // ── Lecturas ──────────────────────────────────────────────────────────────

  /// Todas las sesiones de más reciente a más antigua.
  Future<List<Session>> getAll() =>
      (select(sessions)
        ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]))
          .get();

  /// Stream reactivo de todas las sesiones.
  Stream<List<Session>> watchAll() =>
      (select(sessions)
        ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]))
          .watch();

  // ── Estadísticas ──────────────────────────────────────────────────────────

  /// Total de minutos activos entre dos fechas.
  Future<int> getTotalMinutes({
    required int fromMs,
    required int toMs,
  }) async {
    final query = selectOnly(sessions)
      ..addColumns([sessions.durationSeconds.sum()])
      ..where(
        sessions.startedAt.isBiggerOrEqualValue(fromMs) &
        sessions.startedAt.isSmallerOrEqualValue(toMs) &
        sessions.completed.equals(true),
      );
    final row = await query.getSingle();
    final totalSeconds = row.read(sessions.durationSeconds.sum()) ?? 0;
    return totalSeconds ~/ 60;
  }

  /// Total de sesiones completadas en el mes actual.
  Future<int> getTotalSessionsThisMonth() async {
    final now = DateTime.now();
    final startOfMonth =
        DateTime(now.year, now.month, 1).millisecondsSinceEpoch;
    final endOfMonth =
        DateTime(now.year, now.month + 1, 1).millisecondsSinceEpoch;

    final query = selectOnly(sessions)
      ..addColumns([sessions.id.count()])
      ..where(
        sessions.startedAt.isBiggerOrEqualValue(startOfMonth) &
        sessions.startedAt.isSmallerOrEqualValue(endOfMonth) &
        sessions.completed.equals(true),
      );
    final row = await query.getSingle();
    return row.read(sessions.id.count()) ?? 0;
  }

  /// Minutos activos por cada día de los últimos N días.
  /// Retorna un Map donde la clave es 'yyyy-MM-dd'.
  Future<Map<String, int>> getDailyMinutes({int days = 7}) async {
    final now = DateTime.now();
    final result = <String, int>{};

    for (int i = 0; i < days; i++) {
      final day = now.subtract(Duration(days: i));
      final startOfDay =
          DateTime(day.year, day.month, day.day).millisecondsSinceEpoch;
      final endOfDay = DateTime(day.year, day.month, day.day, 23, 59, 59)
          .millisecondsSinceEpoch;

      final query = selectOnly(sessions)
        ..addColumns([sessions.durationSeconds.sum()])
        ..where(
          sessions.startedAt.isBiggerOrEqualValue(startOfDay) &
          sessions.startedAt.isSmallerOrEqualValue(endOfDay) &
          sessions.completed.equals(true),
        );
      final row = await query.getSingle();
      final seconds = row.read(sessions.durationSeconds.sum()) ?? 0;
      final key =
          '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
      result[key] = seconds ~/ 60;
    }

    return result;
  }

  /// Racha actual: días consecutivos con al menos 1 sesión completada.
  Future<int> getCurrentStreak() async {
    int streak = 0;
    final now = DateTime.now();

    for (int i = 0; i < 365; i++) {
      final day = now.subtract(Duration(days: i));
      final startOfDay =
          DateTime(day.year, day.month, day.day).millisecondsSinceEpoch;
      final endOfDay = DateTime(day.year, day.month, day.day, 23, 59, 59)
          .millisecondsSinceEpoch;

      final query = selectOnly(sessions)
        ..addColumns([sessions.id.count()])
        ..where(
          sessions.startedAt.isBiggerOrEqualValue(startOfDay) &
          sessions.startedAt.isSmallerOrEqualValue(endOfDay) &
          sessions.completed.equals(true),
        );
      final row = await query.getSingle();
      final count = row.read(sessions.id.count()) ?? 0;

      if (count > 0) {
        streak++;
      } else {
        if (i == 0) continue;
        break;
      }
    }

    return streak;
  }

  /// Adherencia semanal: % de días laborales con al menos 1 sesión.
  Future<double> getWeeklyAdherence() async {
    final now = DateTime.now();
    int activeDays = 0;
    int totalWorkdays = 0;

    for (int i = 0; i < 7; i++) {
      final day = now.subtract(Duration(days: i));
      if (day.weekday > 5) continue;
      if (day.isAfter(now)) continue;

      totalWorkdays++;

      final startOfDay =
          DateTime(day.year, day.month, day.day).millisecondsSinceEpoch;
      final endOfDay = DateTime(day.year, day.month, day.day, 23, 59, 59)
          .millisecondsSinceEpoch;

      final query = selectOnly(sessions)
        ..addColumns([sessions.id.count()])
        ..where(
          sessions.startedAt.isBiggerOrEqualValue(startOfDay) &
          sessions.startedAt.isSmallerOrEqualValue(endOfDay) &
          sessions.completed.equals(true),
        );
      final row = await query.getSingle();
      if ((row.read(sessions.id.count()) ?? 0) > 0) activeDays++;
    }

    if (totalWorkdays == 0) return 0.0;
    return (activeDays / totalWorkdays) * 100;
  }

  /// Minutos activos hoy.
  Future<int> getTodayMinutes() async {
    final now = DateTime.now();
    final startOfDay =
        DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final endOfDay =
        DateTime(now.year, now.month, now.day, 23, 59, 59)
            .millisecondsSinceEpoch;
    return getTotalMinutes(fromMs: startOfDay, toMs: endOfDay);
  }

  /// Minutos activos en la semana actual (lunes a hoy).
  Future<int> getWeekMinutes() async {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeek =
        DateTime(monday.year, monday.month, monday.day)
            .millisecondsSinceEpoch;
    final endOfToday =
        DateTime(now.year, now.month, now.day, 23, 59, 59)
            .millisecondsSinceEpoch;
    return getTotalMinutes(fromMs: startOfWeek, toMs: endOfToday);
  }
}