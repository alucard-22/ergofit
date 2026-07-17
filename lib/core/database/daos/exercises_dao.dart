import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/exercises_table.dart';

part 'exercises_dao.g.dart';

@DriftAccessor(tables: [Exercises])
class ExercisesDao extends DatabaseAccessor<AppDatabase>
    with _$ExercisesDaoMixin {
  ExercisesDao(super.db);

  // ── Lecturas ──────────────────────────────────────────────────────────────

  /// Todos los ejercicios ordenados por nombre.
  Future<List<Exercise>> getAll() =>
      (select(exercises)
        ..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .get();

  /// Stream reactivo — la UI se actualiza sola cuando cambia la tabla.
  Stream<List<Exercise>> watchAll() =>
      (select(exercises)
        ..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .watch();

  /// Ejercicios filtrados por categoría.
  Future<List<Exercise>> getByCategory(String category) =>
      (select(exercises)
        ..where((t) => t.category.equals(category))
        ..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .get();

  /// Stream de ejercicios por categoría.
  Stream<List<Exercise>> watchByCategory(String category) =>
      (select(exercises)
        ..where((t) => t.category.equals(category))
        ..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .watch();

  /// Ejercicio por ID. Retorna null si no existe.
  Future<Exercise?> getById(String id) =>
      (select(exercises)
        ..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  /// Solo los ejercicios que tienen IA Coach disponible.
  Future<List<Exercise>> getWithAiCoach() =>
      (select(exercises)
        ..where((t) => t.hasAiCoach.equals(true))
        ..orderBy([(t) => OrderingTerm.asc(t.durationSeconds)]))
          .get();

  /// Ejercicios cortos ideales para pausas rápidas (máximo 2 minutos).
  Future<List<Exercise>> getForQuickBreak() =>
      (select(exercises)
        ..where((t) => t.durationSeconds.isSmallerOrEqualValue(120))
        ..orderBy([(t) => OrderingTerm.asc(t.durationSeconds)]))
          .get();

  /// Búsqueda por nombre o beneficio.
  Future<List<Exercise>> search(String query) =>
      (select(exercises)
        ..where((t) =>
            t.name.lower().contains(query.toLowerCase()) |
            t.benefit.lower().contains(query.toLowerCase())))
          .get();

  /// Verifica si la tabla ya tiene datos (para no re-seedear).
  Future<bool> hasData() async {
    final query = selectOnly(exercises)
      ..addColumns([exercises.id.count()]);
    final row = await query.getSingle();
    return (row.read(exercises.id.count()) ?? 0) > 0;
  }

  // ── Escrituras ────────────────────────────────────────────────────────────

  /// Inserción masiva para el seed inicial.
  Future<void> insertAll(List<ExercisesCompanion> entries) async {
    await batch((b) => b.insertAll(exercises, entries));
  }
}