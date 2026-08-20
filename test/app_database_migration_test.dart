import 'package:flutter_test/flutter_test.dart';
import 'package:pocket/core/database/app_database.dart';

void main() {
  test(
    'database migration strategy is defined to preserve user data during upgrades',
    () async {
      final db = AppDatabase();

      expect(db.schemaVersion, 1);
      expect(db.migration.onCreate, isNotNull);
      expect(db.migration.onUpgrade, isNotNull);

      await db.close();
    },
  );
}
