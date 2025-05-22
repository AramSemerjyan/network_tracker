import 'package:flutter/material.dart';
import 'package:json_view/json_view.dart';
import 'package:network_tracker/src/services/speed_test/speet_test_file.dart';
import 'package:network_tracker/src/ui/common/loading_label/loadin_label.dart';
import 'package:network_tracker/src/ui/debug_tools/debug_tools_screen_vm.dart';

import '../common/loading_label/loading_state.dart';

class DebugToolsScreen extends StatefulWidget {
  const DebugToolsScreen({super.key});

  @override
  State<DebugToolsScreen> createState() => _DebugToolsScreenState();
}

class _DebugToolsScreenState extends State<DebugToolsScreen> {
  late final DebugToolsScreenVM _vm = DebugToolsScreenVM();

  void _runSpeedTest() async {
    _vm.testSpeed();
  }

  void _fetchExternalIP() async {
    _vm.fetchExternalIp();
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
            subtitle = Text('Run to test download speed');
          case LoadingProgressState.inProgress:
            subtitle = LoadingLabel();
          case LoadingProgressState.completed:
            subtitle = Text('Download speed: ${state.result}');
        }

        return _buildRow(
          const Text('Internet Speed Test'),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(child: subtitle),
              ValueListenableBuilder(
                valueListenable: _vm.selectedSpeedTestFile,
                builder: (_, selectedFile, __) {
                  return DropdownButton<SpeedTestFile>(
                    value: selectedFile,
                    icon: const Icon(Icons.arrow_drop_down),
                    onChanged: (value) {
                      if (value != null) {
                        _vm.selectedSpeedTestFile.value = value;
                      }
                    },
                    items: _vm.speedTestFiles.map((file) {
                      return DropdownMenuItem<SpeedTestFile>(
                        value: file,
                        child: Text(
                          file.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
          state.loadingProgress,
          _runSpeedTest,
        );
      },
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
            return _buildExternalIpRow();
          },
          separatorBuilder: (_, __) => const Divider(),
          itemCount: 2,
        ),
      ),
    );
  }
}
