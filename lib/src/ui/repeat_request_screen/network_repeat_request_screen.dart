import 'package:flutter/material.dart';
import 'package:network_tracker/src/ui/common/readable_theme_colors.dart';
import 'package:network_tracker/src/ui/repeat_request_screen/edit_request_screen/network_edit_request_screen.dart';
import 'package:network_tracker/src/ui/repeat_request_screen/network_repeat_request_screen_vm.dart';

import '../../model/network_request.dart';

class NetworkRepeatRequestScreen extends StatefulWidget {
  final String baseUrl;

  const NetworkRepeatRequestScreen({
    super.key,
    required this.baseUrl,
  });

  @override
  State<NetworkRepeatRequestScreen> createState() =>
      _NetworkRepeatRequestScreenState();
}

class _NetworkRepeatRequestScreenState
    extends State<NetworkRepeatRequestScreen> {
  late final _vm = NetworkRepeatRequestScreenVM(widget.baseUrl);

  void _moveToEdit(NetworkRequest request) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NetworkEditRequestScreen(originalRequest: request),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenTheme = ReadableThemeColors.screenTheme(context);
    return Theme(
      data: screenTheme,
      child: Scaffold(
        backgroundColor: screenTheme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Repeat Network Request'),
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
        ),
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
                  title: Text(
                      '${req.method.value} ${req.method.symbol} - ${req.path}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () => _moveToEdit(req),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
