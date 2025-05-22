import 'package:flutter/material.dart';
import 'package:json_view/json_view.dart';
import 'package:network_tracker/src/ui/common/loading_label/loadin_label.dart';
import 'package:network_tracker/src/ui/debug_tools/debug_tools_screen_vm.dart';
import 'package:network_tracker/src/ui/debug_tools/models/speed_throttle.dart';

import '../common/loading_label/loading_state.dart';

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

  void _runSpeedTest() async {
    _vm.testSpeed();
  }

  void _fetchExternalIP() async {
    _vm.fetchExternalIp();
  }

  void _applyThrottling(SpeedThrottle throttle) {
    _vm.selectThrottle(throttle);
  }

  Widget _buildRow(Widget title, Widget subtitle, LoadingProgressState state,
      VoidCallback onTap) {
    return ListTile(
      title: Row(
        children: [
          Expanded(child: title),
          ElevatedButton(
            onPressed: state == LoadingProgressState.inProgress ? null : onTap,
            child: const Text('Run'),
          )
        ],
      ),
      subtitle: subtitle,
    );
  }

  Widget _buildSpeedTestRow() {
    return ValueListenableBuilder(
      valueListenable: _vm.speedTestState,
      builder: (_, state, __) {
        Widget subtitle;

        switch (state.loadingProgress) {
          case LoadingProgressState.idle:
            subtitle = Text(
                'Run to test download speed\n(${_vm.testFileName} is used for test)');
          case LoadingProgressState.inProgress:
            subtitle = LoadingLabel();
          case LoadingProgressState.completed:
            subtitle = Text('Download speed: ${state.result}');
        }

        return _buildRow(
          const Text('Internet Speed Test'),
          subtitle,
          state.loadingProgress,
          _runSpeedTest,
        );
      },
    );
  }

  Widget _buildThrottleRow() {
    final throttleDisabled = !_vm.hasClient;

    return ListTile(
      title: const Text('Throttle Network Speed (App Only)'),
      subtitle: Text(throttleDisabled
          ? 'Connect a custom Dio client to enable'
          : 'Simulate limited speed conditions'),
      trailing: ValueListenableBuilder(
        valueListenable: _vm.selectedThrottle,
        builder: (_, selectedThrottle, __) {
          return DropdownButton<SpeedThrottle>(
            value: selectedThrottle,
            items: _vm.throttleOptions
                .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                .toList(),
            onChanged: throttleDisabled
                ? null
                : (value) {
                    if (value != null) {
                      _applyThrottling(value);
                    }
                  },
          );
        },
      ),
    );
  }

  Widget _buildExternalIpRow() {
    return ValueListenableBuilder(
      valueListenable: _vm.networkInfoState,
      builder: (_, state, __) {
        Widget subtitle;

        switch (state.loadingProgress) {
          case LoadingProgressState.idle:
            subtitle = Text('Run to get IP info');
          case LoadingProgressState.inProgress:
            subtitle = LoadingLabel();
          case LoadingProgressState.completed:
            subtitle = JsonView(
              json: state.result,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
            );
        }

        return _buildRow(
          Row(
            children: [
              Expanded(child: const Text('IP Info')),
              if (state.result != null)
                IconButton(
                  onPressed: _vm.shareNetworkInfo,
                  icon: const Icon(Icons.save_alt),
                ),
            ],
          ),
          subtitle,
          state.loadingProgress,
          _fetchExternalIP,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Tools'),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.separated(
          itemBuilder: (_, i) {
            if (i == 0) return _buildSpeedTestRow();
            if (i == 1) return _buildExternalIpRow();
          },
          separatorBuilder: (_, __) => const Divider(),
          itemCount: 2,
        ),
      ),
    );
  }
}
