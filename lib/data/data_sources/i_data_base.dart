/// Абстрактный интерфейс хранилища
abstract class IDataBase {
  Future<T?> get<T>(String key);

  Future<void> set<T>(String key, T value);

  Future<void> remove(String key);
}
