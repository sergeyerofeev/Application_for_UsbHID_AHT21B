import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'i_data_base.dart';

class MyStorage implements IDataBase {
  final SharedPreferences _prefs;

  const MyStorage(this._prefs);

  @override
  Future<T?> get<T>(String key) async {
    // Получаем сохранённый объект
    if (_sameTypes<T, List<Map<String, dynamic>>>()) {
      // Сначала по ключу получим массив строк
      List<String>? list = _prefs.getStringList(key);
      if (list == null || list.isEmpty) {
        return null;
      }
      // Каждую строку массива преобразуем в Map<String, dynamic>
      return list.map((entry) => jsonDecode(entry)).toList() as T;
    }

    if (_sameTypes<T, double>()) {
      return _prefs.getDouble(key) as T?;
    }

    // В методе get мы получаем либо объект User, либо int, иначе String
    return _prefs.getString(key) as T?;
  }

  @override
  Future<void> set<T>(String key, T value) async {
    // Сохраняем List<Map<String, dynamic>>
    if (_sameTypes<T, List<Map<String, dynamic>>>()) {
      if ((value as List<Map<String, dynamic>>).isEmpty) {
        // Сначала проверим существует ли запись с переданным ключом
        if (_prefs.containsKey(key)) {
          _prefs.remove(key);
        }
        return;
      }
      // Сначала преобразуем List<Map<String, dynamic>> в List<String>
      final list = value.map((entry) => jsonEncode(entry)).toList();
      // Сохраняем в storage как List<String>
      await _prefs.setStringList(key, list);
      return;
    }

    if (_sameTypes<T, double>()) {
      await _prefs.setDouble(key, value as double);
      return;
    }

    // Если это не объект User и не int, значит получаем строку
    await _prefs.setString(key, value as String);
  }

  @override
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  bool _sameTypes<S, V>() {
    void func<X extends S>() {}
    return func is void Function<X extends V>();
  }
}
