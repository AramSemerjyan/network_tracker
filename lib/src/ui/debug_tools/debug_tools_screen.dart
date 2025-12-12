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
            child: Text(state == LoadingProgressState.inProgressStoppable
                ? 'Stop'
                : 'Run'),
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
            break;
          case LoadingProgressState.inProgressStoppable:
          case LoadingProgressState.inProgress:
            subtitle = LoadingLabel();
            break;
          case LoadingProgressState.completed:
            subtitle = Text('Download speed: ${state.result}');
            break;
          case LoadingProgressState.error:
            subtitle = Text('Error: ${state.error}');
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              file.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              file.urlString,
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
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
            break;
          case LoadingProgressState.inProgressStoppable:
          case LoadingProgressState.inProgress:
            subtitle = LoadingLabel();
            break;
          case LoadingProgressState.completed:
            subtitle = JsonView(
              json: state.result,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
            );
            break;
          case LoadingProgressState.error:
            subtitle = Text('Error: ${state.error}');
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

  Widget _buildPingRow() {
    return ValueListenableBuilder(
      valueListenable: _vm.pingState,
      builder: (_, state, __) {
        Widget subtitle;

        switch (state.loadingProgress) {
          case LoadingProgressState.idle:
            subtitle = Text('Run to ping host');
            break;
          case LoadingProgressState.inProgressStoppable:
          case LoadingProgressState.inProgress:
            subtitle = LoadingLabel();
            break;
          case LoadingProgressState.completed:
            subtitle = Text('Ping completed');
            break;
          case LoadingProgressState.error:
            subtitle = Text('Error: ${state.error}');
        }

        return _buildRow(
          const Text('Ping Host'),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(child: subtitle),
              const SizedBox(height: 8),
              ValueListenableBuilder(
                  valueListenable: _vm.allHosts,
                  builder: (_, hosts, __) {
                    if (hosts.isEmpty) {
                      return SizedBox.shrink();
                    }

                    return ValueListenableBuilder(
                      valueListenable: _vm.selectedPingUrl,
                      builder: (_, selectedUrl, __) {
                        final selected = hosts.contains(selectedUrl)
                            ? selectedUrl
                            : hosts.first;

                        return DropdownButton<String>(
                          value: selected,
                          hint: const Text('Select from recent URLs'),
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down),
                          onChanged: (value) {
                            if (value != null) {
                              _vm.selectedPingUrl.value = value;
                            }
                          },
                          items: hosts.map((url) {
                            return DropdownMenuItem<String>(
                              value: url,
                              child: Text(
                                url,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                        );
                      },
                    );
                  }),
              const SizedBox(height: 8),
              ValueListenableBuilder(
                valueListenable: _vm.selectedPingUrl,
                builder: (_, selectedUrl, __) {
                  return TextField(
                    decoration: const InputDecoration(
                      hintText: 'Enter host to ping (e.g., google.com)',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    controller: TextEditingController(text: selectedUrl)
                      ..selection =
                          TextSelection.collapsed(offset: selectedUrl.length),
                    onChanged: (value) {
                      _vm.selectedPingUrl.value = value;
                    },
                  );
                },
              ),
              ValueListenableBuilder(
                valueListenable: _vm.pingResults,
                builder: (_, result, __) {
                  return SizedBox(
                    height: 200,
                    child: ListView(
                      children: result.map((r) {
                        return Text(r.error != null
                            ? 'Error: ${r.error}'
                            : 'from ${r.response?.ip ?? 'unknown'}: time=${r.response?.time?.inMilliseconds ?? 'N/A'} ms: ');
                      }).toList(),
                    ),
                  );
                },
              ),
            ],
          ),
          state.loadingProgress,
          _vm.pingHost,
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
        child: SingleChildScrollView(
          child: Column(
            spacing: 16,
            children: [
              _buildSpeedTestRow(),
              Divider(height: 1),
              _buildExternalIpRow(),
              Divider(height: 1),
              _buildPingRow(),
            ],
          ),
        ),
      ),
    );
  }
}
