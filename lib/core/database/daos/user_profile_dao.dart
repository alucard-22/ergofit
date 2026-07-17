import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/user_profile_table.dart';

part 'user_profile_dao.g.dart';

@DriftAccessor(tables: [UserProfile])
class UserProfileDao extends DatabaseAccessor<AppDatabase>
    with _$UserProfileDaoMixin {
  UserProfileDao(super.db);

  // ── Lecturas ──────────────────────────────────────────────────────────────

  /// Obtiene el perfil del usuario. Siempre retorna un valor.
  Future<UserProfileData?> getProfile() =>
      (select(userProfile)
        ..where((t) => t.id.equals(1)))
          .getSingleOrNull();

  /// Stream reactivo del perfil.
  Stream<UserProfileData?> watchProfile() =>
      (select(userProfile)
        ..where((t) => t.id.equals(1)))
          .watchSingleOrNull();

  // ── Escrituras ────────────────────────────────────────────────────────────

  /// Actualiza el nombre del usuario.
  Future<void> updateName(String name) =>
      (update(userProfile)..where((t) => t.id.equals(1))).write(
        UserProfileCompanion(
          name: Value(name),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );

  /// Actualiza el rol laboral.
  Future<void> updateJobRole(String role) =>
      (update(userProfile)..where((t) => t.id.equals(1))).write(
        UserProfileCompanion(
          jobRole: Value(role),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );

  /// Marca el onboarding como completado.
  Future<void> completeOnboarding() =>
      (update(userProfile)..where((t) => t.id.equals(1))).write(
        UserProfileCompanion(
          onboardingDone: const Value(true),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );

  /// Actualiza la meta diaria de minutos.
  Future<void> updateDailyGoal(int minutes) =>
      (update(userProfile)..where((t) => t.id.equals(1))).write(
        UserProfileCompanion(
          dailyGoalMinutes: Value(minutes),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );

  /// Cambia el tema de la app.
  Future<void> updateTheme(String theme) =>
      (update(userProfile)..where((t) => t.id.equals(1))).write(
        UserProfileCompanion(
          theme: Value(theme),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );

  /// Crea el perfil inicial. Solo se llama en el seed.
  Future<void> createInitial() =>
      into(userProfile).insertOnConflictUpdate(
        UserProfileCompanion.insert(
          createdAt: DateTime.now().millisecondsSinceEpoch,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );
}