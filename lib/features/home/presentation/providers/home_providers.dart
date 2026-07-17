import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/database/app_database.dart';

// ── Perfil de usuario ─────────────────────────────────────────────────────────

/// Stream reactivo del perfil del usuario.
/// La UI se actualiza automáticamente cuando cambia el nombre o la meta.
final userProfileProvider = StreamProvider<UserProfileData?>((ref) {
  final dao = ref.watch(userProfileDaoProvider);
  return dao.watchProfile();
});

// ── Estadísticas del home ─────────────────────────────────────────────────────

/// Todos los datos que necesita el Home en una sola llamada.
final homeStatsProvider = FutureProvider<HomeStats>((ref) async {
  final sessionsDao = ref.watch(sessionsDaoProvider);
  final alarmsDao   = ref.watch(alarmsDaoProvider);

  final results = await Future.wait([
    sessionsDao.getTodayMinutes(),
    sessionsDao.getWeekMinutes(),
    sessionsDao.getCurrentStreak(),
    sessionsDao.getWeeklyAdherence(),
    sessionsDao.getTotalSessionsThisMonth(),
    alarmsDao.countEnabled(),
  ]);

  return HomeStats(
    todayMinutes:     results[0] as int,
    weekMinutes:      results[1] as int,
    currentStreak:    results[2] as int,
    adherencePercent: results[3] as double,
    monthSessions:    results[4] as int,
    activeAlarms:     results[5] as int,
  );
});

/// Ejercicios cortos recomendados para mostrar en el Home.
final recommendedExercisesProvider = FutureProvider((ref) async {
  final dao = ref.watch(exercisesDaoProvider);
  final all = await dao.getForQuickBreak();
  all.shuffle();
  return all.take(3).toList();
});

// ── Modelo de datos ───────────────────────────────────────────────────────────

class HomeStats {
  final int todayMinutes;
  final int weekMinutes;
  final int currentStreak;
  final double adherencePercent;
  final int monthSessions;
  final int activeAlarms;

  const HomeStats({
    required this.todayMinutes,
    required this.weekMinutes,
    required this.currentStreak,
    required this.adherencePercent,
    required this.monthSessions,
    required this.activeAlarms,
  });
}