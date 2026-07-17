import 'package:drift/native.dart';
import 'package:drift/drift.dart';
import '../app_database.dart';

/// Crea una BD en memoria para tests unitarios.
/// No persiste datos entre tests — cada test arranca con BD limpia.
///
/// Uso en tests:
///   late AppDatabase db;
///   setUp(() => db = createTestDatabase());
///   tearDown(() => db.close());
AppDatabase createTestDatabase() {
  return AppDatabase.forTesting(
    DatabaseConnection(NativeDatabase.memory()),
  );
}