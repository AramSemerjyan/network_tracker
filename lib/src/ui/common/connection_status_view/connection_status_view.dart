import 'package:flutter/material.dart';
import 'package:network_tracker/src/ui/common/connection_status_view/connection_status_view_vm.dart';

class ConnectionStatusView extends StatefulWidget {
  const ConnectionStatusView({super.key});

  @override
  State<ConnectionStatusView> createState() => _ConnectionStatusViewState();
}

class _ConnectionStatusViewState extends State<ConnectionStatusView> {
  late final ConnectionStatusViewVM _vm = ConnectionStatusViewVM();

  @override
  void dispose() {
    _vm.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _vm.onConnectionUpdate.stream,
      builder: (_, s) {
        final result = s.data;

        if (result == null) return Container();

        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: result.color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 5,
                children: [
                  Text(
                    result.title,
                    style: TextStyle(
                      color: result.tintColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Icon(result.icon, color: result.tintColor),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
