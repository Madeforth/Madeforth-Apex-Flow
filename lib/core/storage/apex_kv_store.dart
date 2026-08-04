import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Minimal local-first key-value store.
/// Centralizes persistence so we can swap implementation later (Isar/Hive/etc.)
abstract final class ApexKvStore {
  static Box? _box;
  static bool _useFallback = false;

  static Future<void> init({bool useFallback = false}) async {
    if (_box != null || _useFallback) return;
    _useFallback = useFallback;
    if (_useFallback) {
      return;
    }
    try {
      await Hive.initFlutter();
      _box = await Hive.openBox('apex_config');
    } catch (_) {
      _useFallback = true;
    }
  }

  static Future<String?> getString(String key) async {
    if (_useFallback || _box == null) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    }
    return _box!.get(key) as String?;
  }

  static Future<void> setString(String key, String value) async {
    if (_useFallback || _box == null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
      return;
    }
    await _box!.put(key, value);
  }

  static Future<bool?> getBool(String key) async {
    if (_useFallback || _box == null) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(key);
    }
    return _box!.get(key) as bool?;
  }

  static Future<void> setBool(String key, bool value) async {
    if (_useFallback || _box == null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
      return;
    }
    await _box!.put(key, value);
  }

  static Future<List<String>?> getStringList(String key) async {
    if (_useFallback || _box == null) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(key);
    }
    final raw = _box!.get(key);
    if (raw == null) return null;
    return (raw as List).cast<String>();
  }

  static Future<void> setStringList(String key, List<String> value) async {
    if (_useFallback || _box == null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(key, value);
      return;
    }
    await _box!.put(key, value);
  }

  static Future<void> remove(String key) async {
    if (_useFallback || _box == null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
      return;
    }
    await _box!.delete(key);
  }
}
