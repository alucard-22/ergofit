import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_database.dart';

/// Provider global de la base de datos.
/// Solo existe una instancia durante toda la vida de la app.
///
/// Uso desde cualquier pantalla o provider:
///   final db = ref.read(databaseProvider);
///   final exercises = await db.exercisesDao.getAll();
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();

  // Cierra la conexión cuando el provider es destruido
  ref.onDispose(db.close);

  return db;
});

// ── Shortcuts a los DAOs ──────────────────────────────────────────────────────

/// Acceso directo al ExercisesDao.
final exercisesDaoProvider = Provider(
  (ref) => ref.watch(databaseProvider).exercisesDao,
);

/// Acceso directo al SessionsDao.
final sessionsDaoProvider = Provider(
  (ref) => ref.watch(databaseProvider).sessionsDao,
);

/// Acceso directo al AlarmsDao.
final alarmsDaoProvider = Provider(
  (ref) => ref.watch(databaseProvider).alarmsDao,
);

/// Acceso directo al UserProfileDao.
final userProfileDaoProvider = Provider(
  (ref) => ref.watch(databaseProvider).userProfileDao,
);