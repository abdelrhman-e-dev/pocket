import 'package:flutter_test/flutter_test.dart';
import 'package:pocket/core/database/app_database.dart';

void main() {
  test(
    'database migration strategy is defined to preserve user data during upgrades',
    () async {
      final db = AppDatabase();

      expect(db.schemaVersion, 2);
      expect(db.migration.onCreate, isNotNull);
      expect(db.migration.onUpgrade, isNotNull);

      final profile = await db.select(db.userProfiles).getSingle();
      expect(profile.id, 1);
      expect(profile.name, isNull);

      await db.close();
    },
  );
}
