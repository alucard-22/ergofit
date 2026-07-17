import 'package:drift/drift.dart';

class Exercises extends Table {
  TextColumn get id => text()();

  TextColumn get name => text()();

  TextColumn get description => text()();

  TextColumn get stepsJson => text().named('steps_json')();

  TextColumn get benefit => text()();

  // neck | shoulders | back | eyes | wrists | legs | breathing
  TextColumn get category => text()();

  // easy | medium | hard
  TextColumn get difficulty => text()();

  // seated | standing | both
  TextColumn get position => text()();

  IntColumn get durationSeconds => integer().named('duration_seconds')();

  BoolColumn get hasAiCoach =>
      boolean().named('has_ai_coach').withDefault(const Constant(false))();

  TextColumn get emoji => text()();

  TextColumn get animationAsset =>
      text().named('animation_asset').nullable()();

  IntColumn get createdAt => integer().named('created_at')();

  @override
  Set<Column> get primaryKey => {id};
}