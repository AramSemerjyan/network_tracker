enum PresetGroupType { status, custom }

class ResponsePreset {
  final String label;
  final int? statusCode;
  final String? body;
  final Map<String, String>? headers;
  final Duration? delay;
  final PresetGroupType group;
  const ResponsePreset({
    required this.label,
    required this.group,
    this.statusCode,
    this.body,
    this.headers,
    this.delay,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ResponsePreset &&
        other.label == label &&
        other.statusCode == statusCode &&
        other.body == body &&
        other.group == group &&
        _mapEquals(other.headers, headers) &&
        other.delay == delay;
  }

  @override
  int get hashCode => Object.hash(
        label,
        statusCode,
        body,
        group,
        _mapHash(headers),
        delay,
      );

  static bool _mapEquals(
    Map<String, String>? a,
    Map<String, String>? b,
  ) {
    if (identical(a, b)) return true;
    if (a == null || b == null) return a == b;
    if (a.length != b.length) return false;
    for (final entry in a.entries) {
      if (b[entry.key] != entry.value) return false;
    }
    return true;
  }

  static int _mapHash(Map<String, String>? map) {
    if (map == null) return 0;
    var hash = 0;
    for (final entry in map.entries) {
      hash = Object.hash(hash, entry.key, entry.value);
    }
    return hash;
  }
}
