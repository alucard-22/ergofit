import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';

// ── Modelo de estadísticas semanales ─────────────────────────────────────────

class WeeklyStats {
  final Map<String, int> dailyMinutes;
  final int weekMinutes;
  final int monthSessions;
  final int currentStreak;
  final double adherencePercent;
  final int todayMinutes;

  const WeeklyStats({
    required this.dailyMinutes,
    required this.weekMinutes,
    required this.monthSessions,
    required this.currentStreak,
    required this.adherencePercent,
    required this.todayMinutes,
  });

  /// Los 7 días de la semana actual en orden Lun→Dom.
  /// Retorna lista de (etiqueta, minutos).
  List<(String, int)> get weekDays {
    final now = DateTime.now();
    final mon = now.subtract(Duration(days: now.weekday - 1));
    return List.generate(7, (i) {
      final day = mon.add(Duration(days: i));
      final key =
          '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
      const labels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
      return (labels[i], dailyMinutes[key] ?? 0);
    });
  }

  /// Valor máximo de minutos de la semana (mínimo 10 para que la gráfica se vea).
  int get maxMinutes {
    final values = weekDays.map((d) => d.$2).toList();
    return values.isEmpty
        ? 10
        : values.reduce((a, b) => a > b ? a : b).clamp(10, 999);
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final weeklyStatsProvider = FutureProvider<WeeklyStats>((ref) async {
  final dao = ref.watch(sessionsDaoProvider);

  final results = await Future.wait([
    dao.getDailyMinutes(days: 7),
    dao.getWeekMinutes(),
    dao.getTotalSessionsThisMonth(),
    dao.getCurrentStreak(),
    dao.getWeeklyAdherence(),
    dao.getTodayMinutes(),
  ]);

  return WeeklyStats(
    dailyMinutes:     results[0] as Map<String, int>,
    weekMinutes:      results[1] as int,
    monthSessions:    results[2] as int,
    currentStreak:    results[3] as int,
    adherencePercent: results[4] as double,
    todayMinutes:     results[5] as int,
  );
});