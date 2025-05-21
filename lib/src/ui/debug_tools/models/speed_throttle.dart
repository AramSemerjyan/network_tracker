class SpeedThrottle {
  final String name;
  final int? value;

  SpeedThrottle({
    required this.name,
    this.value,
  });

  factory SpeedThrottle.unlimited() {
    return SpeedThrottle(name: 'Unlimited');
  }

  factory SpeedThrottle.throttle3G() {
    return SpeedThrottle(
      name: '3G (~750 Kbps)',
      value: 750 * 1024 ~/ 8,
    );
  }

  factory SpeedThrottle.throttle2G() {
    return SpeedThrottle(
      name: '2G (~250 Kbps)',
      value: 250 * 1024 ~/ 8,
    );
  }

  factory SpeedThrottle.throttleEdge() {
    return SpeedThrottle(
      name: 'Edge (~100 Kbps)',
      value: 100 * 1024 ~/ 8,
    );
  }

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

  Map<String, dynamic> toJson() => {
        'name': name,
        'value': value,
      };

  factory SpeedThrottle.fromJson(Map<String, dynamic> json) => SpeedThrottle(
        name: json['name'] as String,
        value: json['value'] as int?,
      );
}
