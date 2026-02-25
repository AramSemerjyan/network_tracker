/// Bandwidth preset used to throttle repeated requests.
class SpeedThrottle {
  /// Display name shown in the throttle selector.
  final String name;

  /// Max bytes-per-second limit. `null` means no throttling.
  final int? value;

  /// Creates a [SpeedThrottle] instance.
  SpeedThrottle({
    required this.name,
    this.value,
  });

  /// Preset with no bandwidth limits.
  factory SpeedThrottle.unlimited() {
    return SpeedThrottle(name: 'Unlimited');
  }

  /// Preset approximating 3G throughput.
  factory SpeedThrottle.throttle3G() {
    return SpeedThrottle(
      name: '3G (~750 Kbps)',
      value: 750 * 1024 ~/ 8,
    );
  }

  /// Preset approximating 2G throughput.
  factory SpeedThrottle.throttle2G() {
    return SpeedThrottle(
      name: '2G (~250 Kbps)',
      value: 250 * 1024 ~/ 8,
    );
  }

  /// Preset approximating EDGE throughput.
  factory SpeedThrottle.throttleEdge() {
    return SpeedThrottle(
      name: 'Edge (~100 Kbps)',
      value: 100 * 1024 ~/ 8,
    );
  }

  /// All built-in throttle presets.
  static List<SpeedThrottle> allCases() => [
        SpeedThrottle.unlimited(),
        SpeedThrottle.throttle3G(),
        SpeedThrottle.throttle2G(),
        SpeedThrottle.throttleEdge(),
      ];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpeedThrottle &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          value == other.value;

  @override
  int get hashCode => name.hashCode ^ value.hashCode;

  /// Serializes this throttle preset to JSON.
  Map<String, dynamic> toJson() => {
        'name': name,
        'value': value,
      };

  /// Deserializes a throttle preset from JSON.
  factory SpeedThrottle.fromJson(Map<String, dynamic> json) => SpeedThrottle(
        name: json['name'] as String,
        value: json['value'] as int?,
      );
}
