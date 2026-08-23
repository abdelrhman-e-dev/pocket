import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';

class UserProfileRepository {
  UserProfileRepository(this._database);

  final AppDatabase _database;

  Stream<UserProfile?> watchProfile() {
    return (_database.select(
      _database.userProfiles,
    )..where((profile) => profile.id.equals(1))).watchSingleOrNull();
  }

  Future<UserProfile?> getProfile() {
    return (_database.select(
      _database.userProfiles,
    )..where((profile) => profile.id.equals(1))).getSingleOrNull();
  }

  Future<void> saveName(String value) async {
    final name = value.trim();
    if (name.isEmpty) {
      throw ArgumentError('Name cannot be empty');
    }

    final now = DateTime.now();
    final existing = await getProfile();
    if (existing == null) {
      await _database
          .into(_database.userProfiles)
          .insert(
            UserProfilesCompanion.insert(
              id: const Value(1),
              name: Value(name),
              createdAt: now,
              updatedAt: now,
            ),
          );
      return;
    }

    await (_database.update(_database.userProfiles)
          ..where((profile) => profile.id.equals(1)))
        .write(UserProfilesCompanion(name: Value(name), updatedAt: Value(now)));
  }
}
