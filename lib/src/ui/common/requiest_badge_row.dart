import 'package:flutter/widgets.dart';
import 'package:network_tracker/src/model/network_request.dart';

import 'repeat_request_badge.dart';

/// Row of badges describing request modifiers (repeated/modified).
class RequestBadgeRow extends StatelessWidget {
  /// Request whose badge states are rendered.
  final NetworkRequest request;

  /// Creates a [RequestBadgeRow] instance.
  const RequestBadgeRow({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 5,
      children: [
        if (request.isRepeated ?? false)
          RequestBadge(config: RequestBadgeConfig.repeated()),
        if (request.isModified ?? false)
          RequestBadge(config: RequestBadgeConfig.modified()),
      ],
    );
  }
}
