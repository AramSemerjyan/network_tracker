/// StorageType values.
enum StorageType {
  /// Stores requests in memory for the current app session only.
  local,

  /// Stores requests in persistent SQLite storage across app restarts.
  persistent,
}
