import 'package:flutter/material.dart';

class RequestBadgeConfig {
  final String title;
  final Color color;

  RequestBadgeConfig({
    required this.title,
    required this.color,
  });

  factory RequestBadgeConfig.repeated() {
    return RequestBadgeConfig(
      title: 'Repeated',
      color: Colors.orange.shade300,
    );
  }

  factory RequestBadgeConfig.modified() {
    return RequestBadgeConfig(
      title: 'Modified',
      color: Colors.purple.shade300,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: config.color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        config.title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
