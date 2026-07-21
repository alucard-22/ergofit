import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// Tablas
import 'tables/exercises_table.dart';
import 'tables/sessions_table.dart';
import 'tables/alarms_table.dart';
import 'tables/user_profile_table.dart';
import 'tables/achievements_table.dart';

// DAOs
import 'daos/exercises_dao.dart';
import 'daos/sessions_dao.dart';
import 'daos/alarms_dao.dart';
import 'daos/user_profile_dao.dart';

// Seed
import 'seed/exercises_seed.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Exercises,
    Sessions,
    Alarms,
    UserProfile,
    Achievements,
  ],
  daos: [
    ExercisesDao,
    SessionsDao,
    AlarmsDao,
    UserProfileDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  // Constructor especial para tests en memoria
  AppDatabase.forTesting(super.connection);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    // Se ejecuta UNA SOLA VEZ al crear la BD por primera vez
    onCreate: (m) async {
      await m.createAll();
      await _seedInitialData();
    },

    // Se ejecuta cuando schemaVersion aumenta
    onUpgrade: (m, from, to) async {
      // Aquí irán las migraciones futuras
    },

    // Se ejecuta en cada apertura de la BD
    beforeOpen: (details) async {
      // Activar foreign keys (SQLite las tiene desactivadas por defecto)
      await customStatement('PRAGMA foreign_keys = ON');
      // Mejor rendimiento en lecturas concurrentes
      await customStatement('PRAGMA journal_mode = WAL');
    },
  );

  /// Inserta los datos iniciales al crear la BD por primera vez.
  Future<void> _seedInitialData() async {
    await exercisesDao.insertAll(ExercisesSeedData.all);
    await userProfileDao.createInitial();
    await _insertDemoData();
  }

  Future<void> _insertDemoData() async {
    final now = DateTime.now();

    // Ejercicios para rotar en los datos de demo
    final exerciseIds = [
      'shoulder_rolls',
      'neck_lateral_tilt',
      'neck_rotation',
      'back_cat_cow',
      'wrist_extension_stretch',
      'eyes_20_20_20',
      'breathing_box',
      'chest_opener',
      'neck_chin_tuck',
      'wrist_circles',
    ];

    // Genera sesiones para los últimos 7 días
    // con variación realista de minutos y ejercicios
    final sessions = <SessionsCompanion>[];
    const uuid = Uuid();

    // Día 7 (hace 6 días) — 2 sesiones
    final day7 = DateTime(now.year, now.month, now.day - 6, 9, 15);
    sessions.addAll([
      SessionsCompanion.insert(
        id: uuid.v4(),
        exerciseId: exerciseIds[0],
        startedAt: day7.millisecondsSinceEpoch,
        durationSeconds: 60,
        completed: const Value(true),
        usedAiCoach: const Value(true),
        aiScore: const Value(0.88),
      ),
      SessionsCompanion.insert(
        id: uuid.v4(),
        exerciseId: exerciseIds[5],
        startedAt: day7.add(const Duration(hours: 2)).millisecondsSinceEpoch,
        durationSeconds: 20,
        completed: const Value(true),
        usedAiCoach: const Value(false),
      ),
    ]);

    // Día 6 (hace 5 días) — 3 sesiones
    final day6 = DateTime(now.year, now.month, now.day - 5, 10, 0);
    sessions.addAll([
      SessionsCompanion.insert(
        id: uuid.v4(),
        exerciseId: exerciseIds[1],
        startedAt: day6.millisecondsSinceEpoch,
        durationSeconds: 120,
        completed: const Value(true),
        usedAiCoach: const Value(true),
        aiScore: const Value(0.92),
      ),
      SessionsCompanion.insert(
        id: uuid.v4(),
        exerciseId: exerciseIds[3],
        startedAt: day6.add(const Duration(hours: 3)).millisecondsSinceEpoch,
        durationSeconds: 120,
        completed: const Value(true),
        usedAiCoach: const Value(false),
      ),
      SessionsCompanion.insert(
        id: uuid.v4(),
        exerciseId: exerciseIds[6],
        startedAt: day6.add(const Duration(hours: 5)).millisecondsSinceEpoch,
        durationSeconds: 240,
        completed: const Value(true),
        usedAiCoach: const Value(false),
      ),
    ]);

    // Día 5 (hace 4 días) — 2 sesiones
    final day5 = DateTime(now.year, now.month, now.day - 4, 11, 30);
    sessions.addAll([
      SessionsCompanion.insert(
        id: uuid.v4(),
        exerciseId: exerciseIds[2],
        startedAt: day5.millisecondsSinceEpoch,
        durationSeconds: 90,
        completed: const Value(true),
        usedAiCoach: const Value(true),
        aiScore: const Value(0.85),
      ),
      SessionsCompanion.insert(
        id: uuid.v4(),
        exerciseId: exerciseIds[4],
        startedAt: day5.add(const Duration(hours: 4)).millisecondsSinceEpoch,
        durationSeconds: 120,
        completed: const Value(true),
        usedAiCoach: const Value(false),
      ),
    ]);

    // Día 4 (hace 3 días) — 4 sesiones
    final day4 = DateTime(now.year, now.month, now.day - 3, 9, 0);
    sessions.addAll([
      SessionsCompanion.insert(
        id: uuid.v4(),
        exerciseId: exerciseIds[7],
        startedAt: day4.millisecondsSinceEpoch,
        durationSeconds: 120,
        completed: const Value(true),
        usedAiCoach: const Value(true),
        aiScore: const Value(0.94),
      ),
      SessionsCompanion.insert(
        id: uuid.v4(),
        exerciseId: exerciseIds[5],
        startedAt: day4.add(const Duration(hours: 1)).millisecondsSinceEpoch,
        durationSeconds: 20,
        completed: const Value(true),
        usedAiCoach: const Value(false),
      ),
      SessionsCompanion.insert(
        id: uuid.v4(),
        exerciseId: exerciseIds[0],
        startedAt: day4.add(const Duration(hours: 3)).millisecondsSinceEpoch,
        durationSeconds: 60,
        completed: const Value(true),
        usedAiCoach: const Value(false),
      ),
      SessionsCompanion.insert(
        id: uuid.v4(),
        exerciseId: exerciseIds[8],
        startedAt: day4.add(const Duration(hours: 5)).millisecondsSinceEpoch,
        durationSeconds: 60,
        completed: const Value(true),
        usedAiCoach: const Value(true),
        aiScore: const Value(0.90),
      ),
    ]);

    // Día 3 (hace 2 días) — 3 sesiones
    final day3 = DateTime(now.year, now.month, now.day - 2, 10, 0);
    sessions.addAll([
      SessionsCompanion.insert(
        id: uuid.v4(),
        exerciseId: exerciseIds[1],
        startedAt: day3.millisecondsSinceEpoch,
        durationSeconds: 120,
        completed: const Value(true),
        usedAiCoach: const Value(true),
        aiScore: const Value(0.91),
      ),
      SessionsCompanion.insert(
        id: uuid.v4(),
        exerciseId: exerciseIds[9],
        startedAt: day3.add(const Duration(hours: 2)).millisecondsSinceEpoch,
        durationSeconds: 60,
        completed: const Value(true),
        usedAiCoach: const Value(false),
      ),
      SessionsCompanion.insert(
        id: uuid.v4(),
        exerciseId: exerciseIds[6],
        startedAt: day3.add(const Duration(hours: 4)).millisecondsSinceEpoch,
        durationSeconds: 240,
        completed: const Value(true),
        usedAiCoach: const Value(false),
      ),
    ]);

    // Día 2 (ayer) — 3 sesiones
    final day2 = DateTime(now.year, now.month, now.day - 1, 9, 30);
    sessions.addAll([
      SessionsCompanion.insert(
        id: uuid.v4(),
        exerciseId: exerciseIds[3],
        startedAt: day2.millisecondsSinceEpoch,
        durationSeconds: 120,
        completed: const Value(true),
        usedAiCoach: const Value(true),
        aiScore: const Value(0.96),
      ),
      SessionsCompanion.insert(
        id: uuid.v4(),
        exerciseId: exerciseIds[2],
        startedAt: day2.add(const Duration(hours: 2)).millisecondsSinceEpoch,
        durationSeconds: 90,
        completed: const Value(true),
        usedAiCoach: const Value(false),
      ),
      SessionsCompanion.insert(
        id: uuid.v4(),
        exerciseId: exerciseIds[4],
        startedAt: day2.add(const Duration(hours: 5)).millisecondsSinceEpoch,
        durationSeconds: 120,
        completed: const Value(true),
        usedAiCoach: const Value(true),
        aiScore: const Value(0.87),
      ),
    ]);

    // Hoy — 2 sesiones
    final today = DateTime(now.year, now.month, now.day, 9, 0);
    sessions.addAll([
      SessionsCompanion.insert(
        id: uuid.v4(),
        exerciseId: exerciseIds[0],
        startedAt: today.millisecondsSinceEpoch,
        durationSeconds: 60,
        completed: const Value(true),
        usedAiCoach: const Value(true),
        aiScore: const Value(0.93),
      ),
      SessionsCompanion.insert(
        id: uuid.v4(),
        exerciseId: exerciseIds[5],
        startedAt: today.add(const Duration(hours: 1)).millisecondsSinceEpoch,
        durationSeconds: 20,
        completed: const Value(true),
        usedAiCoach: const Value(false),
      ),
    ]);

    // Insertar todas las sesiones
    await batch((b) => b.insertAll(sessionsDao.sessions, sessions));
  }

  /// Resetea toda la BD. Solo usar durante desarrollo.
  Future<void> resetDatabase() async {
    await transaction(() async {
      for (final table in allTables) {
        await delete(table).go();
      }
      await _seedInitialData();
    });
  }
}

/// Abre la conexión a la BD en el directorio de documentos de la app.
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'ergofit.db'));
    return NativeDatabase.createInBackground(file);
  });
}