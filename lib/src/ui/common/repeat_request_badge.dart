import 'package:flutter/material.dart';

/// Types of badges shown for tracked requests.
enum RequestBadgeKind {
  /// Badge for requests resent from the viewer.
  repeated,

  /// Badge for requests with modified/intercepted response.
  modified,
}

/// Configuration for a request badge label and style variant.
class RequestBadgeConfig {
  /// Badge text shown in the UI.
  final String title;

  /// Visual style kind for the badge.
  final RequestBadgeKind kind;

  /// Creates a [RequestBadgeConfig] instance.
  RequestBadgeConfig({
    required this.title,
    required this.kind,
  });

  /// Creates config for the "Repeated" badge.
  factory RequestBadgeConfig.repeated() {
    return RequestBadgeConfig(
      title: 'Repeated',
      kind: RequestBadgeKind.repeated,
    );
  }

  /// Creates config for the "Modified" badge.
  factory RequestBadgeConfig.modified() {
    return RequestBadgeConfig(
      title: 'Modified',
      kind: RequestBadgeKind.modified,
    );
  }
}

/// Small colored badge indicating special request state.
class RequestBadge extends StatelessWidget {
  /// Badge presentation config.
  final RequestBadgeConfig config;

  /// Creates a [RequestBadge] instance.
  const RequestBadge({
    super.key,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    late final Color backgroundColor;
    late final Color textColor;
    switch (config.kind) {
      case RequestBadgeKind.repeated:
        backgroundColor = scheme.secondaryContainer;
        textColor = scheme.onSecondaryContainer;
        break;
      case RequestBadgeKind.modified:
        backgroundColor = scheme.tertiaryContainer;
        textColor = scheme.onTertiaryContainer;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        config.title,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
