import 'dart:io';
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