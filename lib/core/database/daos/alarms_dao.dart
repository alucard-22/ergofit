import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/alarms_table.dart';

part 'alarms_dao.g.dart';

@DriftAccessor(tables: [Alarms])
class AlarmsDao extends DatabaseAccessor<AppDatabase>
    with _$AlarmsDaoMixin {
  AlarmsDao(super.db);

  // ── Lecturas ──────────────────────────────────────────────────────────────

  /// Todas las alarmas ordenadas por hora de inicio.
  Future<List<Alarm>> getAll() =>
      (select(alarms)
        ..orderBy([
          (t) => OrderingTerm.asc(t.startHour),
          (t) => OrderingTerm.asc(t.startMinute),
        ]))
          .get();

  /// Stream reactivo — la UI se actualiza sola al cambiar una alarma.
  Stream<List<Alarm>> watchAll() =>
      (select(alarms)
        ..orderBy([
          (t) => OrderingTerm.asc(t.startHour),
          (t) => OrderingTerm.asc(t.startMinute),
        ]))
          .watch();

  /// Solo las alarmas activas.
  Future<List<Alarm>> getEnabled() =>
      (select(alarms)
        ..where((t) => t.isEnabled.equals(true)))
          .get();

  /// Alarma por ID.
  Future<Alarm?> getById(String id) =>
      (select(alarms)
        ..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  // ── Escrituras ────────────────────────────────────────────────────────────

  /// Insertar nueva alarma.
  Future<void> insertAlarm(AlarmsCompanion entry) =>
      into(alarms).insert(entry);

  /// Activar o desactivar una alarma.
  Future<void> toggleEnabled(String id, bool enabled) =>
      (update(alarms)..where((t) => t.id.equals(id))).write(
        AlarmsCompanion(isEnabled: Value(enabled)),
      );

  /// Eliminar alarma por ID.
  Future<void> deleteById(String id) =>
      (delete(alarms)..where((t) => t.id.equals(id))).go();

  /// Actualizar una alarma completa.
  Future<void> updateAlarm(AlarmsCompanion entry) =>
      (update(alarms)..where((t) => t.id.equals(entry.id.value)))
          .write(entry);

  /// Total de alarmas activas (usado en el Home).
  Future<int> countEnabled() async {
    final query = selectOnly(alarms)
      ..addColumns([alarms.id.count()])
      ..where(alarms.isEnabled.equals(true));
    final row = await query.getSingle();
    return row.read(alarms.id.count()) ?? 0;
  }
}