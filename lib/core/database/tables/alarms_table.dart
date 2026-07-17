import 'package:drift/drift.dart';

class Alarms extends Table {
  // UUID v4
  TextColumn get id => text()();

  TextColumn get name => text()();

  // Hora de inicio: 0-23
  IntColumn get startHour => integer().named('start_hour')();

  // Minuto de inicio: 0-59
  IntColumn get startMinute => integer().named('start_minute')();

  // Cada cuántos minutos se repite durante el día
  IntColumn get intervalMinutes => integer().named('interval_minutes')();

  // JSON bool[7]: [Lun, Mar, Mié, Jue, Vie, Sáb, Dom]
  // Ejemplo: '[true,true,true,true,true,false,false]' = días laborales
  TextColumn get weekdaysJson => text().named('weekdays_json')();

  // JSON array de categorías incluidas
  // Ejemplo: '["neck","shoulders","eyes"]'
  TextColumn get categoriesJson => text().named('categories_json')();

  // true = activa, false = pausada
  BoolColumn get isEnabled =>
      boolean().named('is_enabled').withDefault(const Constant(true))();

  // ID único para flutter_local_notifications
  IntColumn get notificationId =>
      integer().named('notification_id').unique()();

  IntColumn get createdAt => integer().named('created_at')();

  @override
  Set<Column> get primaryKey => {id};
}