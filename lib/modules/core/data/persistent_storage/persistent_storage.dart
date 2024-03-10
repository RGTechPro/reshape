import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/persistent_storage/persistent_storage.dart';

class AppPersistentStorageImpl implements AppStorage {
  @override
  Future<void> storeBool<T>({
    required String key,
    required bool data,
  }) async {
    final database = await _obtainOrCreateDatabase();

      await database.setBool(key, data);
    
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
