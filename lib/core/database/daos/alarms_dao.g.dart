// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alarms_dao.dart';

// ignore_for_file: type=lint
mixin _$AlarmsDaoMixin on DatabaseAccessor<AppDatabase> {
  $AlarmsTable get alarms => attachedDatabase.alarms;
  AlarmsDaoManager get managers => AlarmsDaoManager(this);
}

class AlarmsDaoManager {
  final _$AlarmsDaoMixin _db;
  AlarmsDaoManager(this._db);
  $$AlarmsTableTableManager get alarms =>
      $$AlarmsTableTableManager(_db.attachedDatabase, _db.alarms);
}
