import 'package:shared_preferences/shared_preferences.dart';

class PreferencesStorageService {
  Future<SharedPreferences> getSharedPrefs() async {
    return await SharedPreferences.getInstance();
  }

  Future<T?> getValue<T>(String key) async {
    final prefs = await getSharedPrefs();

    switch (T) {
      case const (int):
        return prefs.getInt(key) as T?;

      case const (String):
        return prefs.getString(key) as T?;

      case const (bool):
        return prefs.getBool(key) as T?;

      default:
        throw UnimplementedError(
          'GET not implemented for type ${T.runtimeType}',
        );
    }
  }

  Future<bool> removeKey(String key) async {
    final prefs = await getSharedPrefs();
    return await prefs.remove(key);
  }

  Future<void> setKeyValue<T>(String key, T value) async {
    final prefs = await getSharedPrefs();

    switch (T) {
      case const (int):
        prefs.setInt(key, value as int);
        break;

      case const (String):
        prefs.setString(key, value as String);
        break;

      case const (bool):
        prefs.setBool(key, value as bool);
        break;

      default:
        throw UnimplementedError(
          'Set not implemented for type ${T.runtimeType}',
        );
    }
  }
}
