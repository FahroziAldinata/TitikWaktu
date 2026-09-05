import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../models/schedule.dart';
import '../models/history_log.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [Schedules, HistoryLogs],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File('${dbFolder.path}/titik_waktu.db');
    
    return NativeDatabase(file);
  });
}