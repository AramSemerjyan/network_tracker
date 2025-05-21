import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../ui/debug_tools/models/speed_throttle.dart';

enum SharedPrefsKeys {
  throttle('network_throttle_key');

  final String key;

  const SharedPrefsKeys(this.key);
}

class SharedPrefsService {
  Future<void> setThrottle(SpeedThrottle throttle) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(throttle.toJson());
    await prefs.setString(SharedPrefsKeys.throttle.key, jsonString);
  }

  Future<SpeedThrottle?> loadThrottle() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(SharedPrefsKeys.throttle.key);

    if (jsonString == null) return null;

    try {
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return SpeedThrottle.fromJson(jsonMap);
    } catch (_) {
      return null; // fallback on corruption
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(SharedPrefsKeys.throttle.key);
  }
}
