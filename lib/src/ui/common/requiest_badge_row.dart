import 'package:flutter/widgets.dart';
import 'package:network_tracker/src/model/network_request.dart';

import 'repeat_request_badge.dart';

class RequestBadgeRow extends StatelessWidget {
  final NetworkRequest request;
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