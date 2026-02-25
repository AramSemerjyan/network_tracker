/// SharedPrefsKeys values.
enum SharedPrefsKeys {
  /// Key used to persist the selected network throttle preset.
  throttle('network_throttle_key');

  /// Raw key string stored in SharedPreferences.
  final String key;

  const SharedPrefsKeys(this.key);
}

/// SharedPrefsService.
class SharedPrefsService {
  /// Clears values saved by this package from SharedPreferences.
  Future<void> clear() async {}
}
