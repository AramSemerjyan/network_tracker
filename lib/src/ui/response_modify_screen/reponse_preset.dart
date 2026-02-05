import '../../services/request_status.dart';

/// The group type for a response preset.
///
/// - [status]: Presets for HTTP status codes (e.g., 200 OK, 404 Not Found)
/// - [custom]: User-defined or custom presets
enum PresetGroupType {
  /// Presets for HTTP status codes (e.g., 200 OK, 404 Not Found)
  status,

  /// User-defined or custom presets
  custom,
}

/// Model for a response preset (status or custom) used in the modify response UI.
///
/// A [ResponsePreset] represents a quick-fill option for modifying a network response,
/// such as a status code, body, headers, delay, and request status.
class ResponsePreset {
  /// The label to display for this preset (e.g., '200 OK').
  final String label;

  /// The HTTP status code for this preset.
  final int? statusCode;

  /// The response body for this preset (as a string).
  final String? body;

  /// The headers for this preset.
  final Map<String, String>? headers;

  /// The artificial delay to apply for this preset.
  final Duration? delay;

  /// The group type (status/custom).
  final PresetGroupType group;

  /// The request status (completed/failed/etc) for this preset.
  final RequestStatus? requestStatus;

  /// Creates a [ResponsePreset].
  const ResponsePreset({
    required this.label,
    required this.group,
    this.statusCode,
    this.body,
    this.headers,
    this.delay,
    this.requestStatus,
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
        other.delay == delay &&
        other.requestStatus == requestStatus;
  }

  @override
  int get hashCode => Object.hash(
        label,
        statusCode,
        body,
        group,
        _mapHash(headers),
        delay,
        requestStatus,
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
