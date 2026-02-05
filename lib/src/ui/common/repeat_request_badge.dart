import 'package:flutter/material.dart';

enum RequestBadgeKind { repeated, modified }

class RequestBadgeConfig {
  final String title;
  final RequestBadgeKind kind;

  RequestBadgeConfig({
    required this.title,
    required this.kind,
  });

  factory RequestBadgeConfig.repeated() {
    return RequestBadgeConfig(
      title: 'Repeated',
      kind: RequestBadgeKind.repeated,
    );
  }

  factory RequestBadgeConfig.modified() {
    return RequestBadgeConfig(
      title: 'Modified',
      kind: RequestBadgeKind.modified,
    );
  }
}

class RequestBadge extends StatelessWidget {
  final RequestBadgeConfig config;

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
