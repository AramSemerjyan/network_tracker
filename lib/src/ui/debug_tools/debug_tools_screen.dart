import 'package:flutter/material.dart';
import 'package:network_tracker/network_tracker.dart';
import 'package:network_tracker/src/ui/common/loadin_label.dart';
import 'package:network_tracker/src/ui/debug_tools/debug_tools_screen_vm.dart';

import '../../interpreter/throttle_interceptor.dart';

class DebugToolsScreen extends StatefulWidget {
  const DebugToolsScreen({super.key});

  @override
  State<DebugToolsScreen> createState() => _DebugToolsScreenState();
}

class _DebugToolsScreenState extends State<DebugToolsScreen> {
  late final DebugToolsScreenVM _vm = DebugToolsScreenVM();

  String? _selectedThrottle;

  final Map<String, int?> throttlingValues = {
    'Unlimited': null,
    '3G (~750 Kbps)': 750 * 1024 ~/ 8,
    '2G (~250 Kbps)': 250 * 1024 ~/ 8,
    'Edge (~100 Kbps)': 100 * 1024 ~/ 8,
  };

  List<String> get throttlingOptions => throttlingValues.keys.toList();

  bool get hasCustomClients =>
      NetworkRequestService.instance.repeatRequestService.clients.isNotEmpty;

  void _runSpeedTest() async {
    _vm.testSpeed();
  }

  void _applyThrottling(String value) {
    setState(() {
      _selectedThrottle = value;
    });

    final limit = throttlingValues[value];

    for (final dio
        in NetworkRequestService.instance.repeatRequestService.clients.values) {
      dio.interceptors.removeWhere((i) => i is ThrottleInterceptor);
      if (limit != null) {
        dio.interceptors.add(ThrottleInterceptor(limit));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final throttleDisabled = !hasCustomClients;

    return Scaffold(
      appBar: AppBar(title: const Text('Debug Tools')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ValueListenableBuilder(
              valueListenable: _vm.speedTestState,
              builder: (_, state, __) {
                Widget subtitle;

                switch (state.progressState) {
                  case SpeedTestProgressState.idle:
                    subtitle = Text(
                        'Tap to test download speed\n(${_vm.testFileName} is used for test)');
                  case SpeedTestProgressState.inProgress:
                    subtitle = LoadingLabel();
                  case SpeedTestProgressState.completed:
                    subtitle = Text('Download speed: ${state.result}');
                }

                return ListTile(
                  title: const Text('Internet Speed Test'),
                  subtitle: subtitle,
                  trailing: ElevatedButton(
                    onPressed:
                        state.progressState == SpeedTestProgressState.inProgress
                            ? null
                            : _runSpeedTest,
                    child: const Text('Run'),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Throttle Network Speed (App Only)'),
              subtitle: Text(throttleDisabled
                  ? 'Connect a custom Dio client to enable'
                  : 'Simulate limited speed conditions'),
              trailing: DropdownButton<String>(
                value: _selectedThrottle ?? throttlingOptions.first,
                items: throttlingOptions
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: throttleDisabled
                    ? null
                    : (value) {
                        if (value != null) {
                          _applyThrottling(value);
                        }
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
