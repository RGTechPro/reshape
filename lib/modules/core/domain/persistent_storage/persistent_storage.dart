import 'package:reshape/modules/core/data/persistent_storage/persistent_storage.dart';

abstract class AppStorage {
  factory AppStorage.persistentStorage() => AppPersistentStorageImpl();

  Future<void> storeBool<T>({
    required String key,
    required bool data,
  });

  Future<bool?> retrieveBool<T>({
    required String key,
  });
}
