import 'package:drift/drift.dart';
import 'exercises_table.dart';

class Sessions extends Table {
  // UUID v4 generado en Dart
  TextColumn get id => text()();

  // Referencia al ejercicio realizado
  TextColumn get exerciseId =>
      text().named('exercise_id').references(Exercises, #id)();

  // Cuándo inició la sesión (Unix timestamp en milisegundos)
  IntColumn get startedAt => integer().named('started_at')();

  // Cuántos segundos duró realmente
  IntColumn get durationSeconds => integer().named('duration_seconds')();

  // true si llegó al final del timer
  BoolColumn get completed =>
      boolean().withDefault(const Constant(false))();

  // true si activó la cámara durante la sesión
  BoolColumn get usedAiCoach =>
      boolean().named('used_ai_coach').withDefault(const Constant(false))();

  // Puntuación de postura de la IA (0.0 a 1.0). Null si no usó IA Coach.
  RealColumn get aiScore => real().named('ai_score').nullable()();

  // Notas opcionales del usuario
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}