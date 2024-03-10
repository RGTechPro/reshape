import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/persistent_storage/persistent_storage.dart';

class AppPersistentStorageImpl implements AppStorage {
  @override
  Future<void> storeBool<T>({
    required String key,
    required bool data,
    bool overwrite = false,
  }) async {
    final database = await _obtainOrCreateDatabase();

    if (data is String) {
      await database.setBool(key, data);
    }
  }

  @override
  Future<bool?> retrieveBool<T>({
    required String key,
  }) async {
    final database = await _obtainOrCreateDatabase();

    final retrievedData = database.getBool(key);

    return retrievedData;
  }

  Future<SharedPreferences> _obtainOrCreateDatabase() async {
    final sharedPreferences = await SharedPreferences.getInstance();

    return sharedPreferences;
  }
}
