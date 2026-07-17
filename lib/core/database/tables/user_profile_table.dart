import 'package:drift/drift.dart';

class UserProfile extends Table {
  // Siempre 1. Solo existe un perfil por dispositivo.
  IntColumn get id => integer().withDefault(const Constant(1))();

  TextColumn get name =>
      text().withDefault(const Constant('Profesional'))();

  // developer | designer | admin | student | other
  TextColumn get jobRole => text().named('job_role').nullable()();

  // Meta diaria de minutos activos. Por defecto: 15 minutos
  IntColumn get dailyGoalMinutes =>
      integer().named('daily_goal_minutes').withDefault(const Constant(15))();

  // false = mostrar onboarding, true = ya completado
  BoolColumn get onboardingDone =>
      boolean().named('onboarding_done').withDefault(const Constant(false))();

  // dark | light | system
  TextColumn get theme => text().withDefault(const Constant('dark'))();

  IntColumn get createdAt => integer().named('created_at')();

  IntColumn get updatedAt => integer().named('updated_at')();

  @override
  Set<Column> get primaryKey => {id};
}