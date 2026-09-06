import 'package:drift/drift.dart';

abstract class Migration {
  final int version;
  Migration(this.version);

  Future<void> up(Migrator m, GeneratedDatabase db);
  Future<void> down(Migrator m, GeneratedDatabase db);
}
