import 'package:flutter/material.dart';
import 'package:network_tracker/src/ui/repeat_request_screen/network_repeat_request_screen_vm.dart';

import '../../model/network_request.dart';

class NetworkRepeatRequestScreen extends StatefulWidget {
  const NetworkRepeatRequestScreen({super.key});

  @override
  State<NetworkRepeatRequestScreen> createState() =>
      _NetworkRepeatRequestScreenState();
}

class _NetworkRepeatRequestScreenState
    extends State<NetworkRepeatRequestScreen> {
  late final _vm = NetworkRepeatRequestScreenVM();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Repeat Network Request')),
      body: ValueListenableBuilder<List<NetworkRequest>>(
        valueListenable: _vm.availableRequestsNotifier,
        builder: (_, requests, __) {
          if (requests.isEmpty) {
            return const Center(child: Text('No requests available'));
          }

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (_, index) {
              final req = requests[index];
              return ListTile(
                title: Text('${req.method.value} ${req.path}'),
                trailing: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _vm.repeatRequest(req),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
