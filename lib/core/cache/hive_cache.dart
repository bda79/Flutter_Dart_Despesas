import 'package:hive/hive.dart';

class HiveCache {
  static const String boxName = "app_cache";

  static Future<Box> _box() async {
    return await Hive.openBox(boxName);
  }

  static Future<void> set(String key, dynamic value) async {
    final box = await _box();
    await box.put(key, value);
  }

  static Future<T?> get<T>(String key) async {
    final box = await _box();
    return box.get(key) as T?;
  }

  static Future<void> delete(String key) async {
    final box = await _box();
    await box.delete(key);
  }

  static Future<void> clear() async {
    final box = await _box();
    await box.clear();
  }
}
