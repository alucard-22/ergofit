import 'package:drift/drift.dart';

class Achievements extends Table {
  // Slug del logro: 'first_session', 'streak_7', etc.
  TextColumn get id => text()();

  // Cuándo se desbloqueó. Null si aún no está desbloqueado.
  IntColumn get unlockedAt => integer().named('unlocked_at').nullable()();

  // Progreso hacia el logro: 0.0 (sin progreso) a 1.0 (completado)
  // Ejemplo: logro "10 sesiones" con 4 completadas → progress = 0.4
  RealColumn get progress =>
      real().withDefault(const Constant(0.0))();

  @override
  Set<Column> get primaryKey => {id};
}