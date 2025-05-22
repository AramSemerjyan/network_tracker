enum SharedPrefsKeys {
  throttle('network_throttle_key');

  final String key;

  const SharedPrefsKeys(this.key);
}

class SharedPrefsService {
  Future<void> clear() async {}
}
