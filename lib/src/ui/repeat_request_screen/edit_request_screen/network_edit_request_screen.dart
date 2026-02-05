import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:network_tracker/src/ui/repeat_request_screen/edit_request_screen/network_edit_request_screen_vm.dart';

import '../../../model/network_request.dart';
import '../../../model/network_request_method.dart';
import '../../common/gradient_button.dart';

class NetworkEditRequestScreen extends StatefulWidget {
  final NetworkRequest originalRequest;

  const NetworkEditRequestScreen({super.key, required this.originalRequest});

  @override
  State<NetworkEditRequestScreen> createState() =>
      _NetworkEditRequestScreenState();
}

class _NetworkEditRequestScreenState extends State<NetworkEditRequestScreen> {
  late final _vm = NetworkRequestEditScreenVM();

  late TextEditingController _pathController;
  late TextEditingController _bodyController;
  late NetworkRequestMethod _method;
  late Map<String, String> _headers;
  late Map<String, dynamic> _queryParams;

  @override
  void initState() {
    super.initState();
    final r = widget.originalRequest;
    _pathController = TextEditingController(text: r.path);
    _bodyController =
        TextEditingController(text: r.requestData?.toString() ?? '');
    _method = r.method;
    _headers = Map<String, String>.from(r.headers ?? {})
      ..remove('content-length');
    _queryParams = Map<String, dynamic>.from(r.queryParameters ?? {});
  }

  void _sendRequest() async {
    dynamic parsedBody;
    if (_bodyController.text.trim().isNotEmpty) {
      try {
        parsedBody = convertLooseJsonToMap(_bodyController.text);
        if (parsedBody is! Map<String, dynamic>) {
          throw const FormatException('Expected a JSON object');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid JSON body')),
        );
        return;
      }
    }

    final modified = widget.originalRequest.copyWith(
      path: _pathController.text,
      method: _method,
      headers: _headers,
      queryParameters: _queryParams,
      requestData: parsedBody,
    );

    _vm.send(modified);
  }

  Map<String, dynamic>? convertLooseJsonToMap(String input) {
    try {
      // Add double quotes to keys and string values
      final corrected = input
          .replaceAllMapped(
        RegExp(r'(\w+)\s*:'),
        (match) => '"${match[1]}":',
      )
          .replaceAllMapped(
        RegExp(r':\s*([^"{\[\d][^,\]}]*)'),
        (match) {
          final value = match[1]?.trim();
          // If it's a number or already quoted, keep it
          if (value == null) return match[0]!;
          if (RegExp(r'^-?\d+(\.\d+)?$').hasMatch(value)) {
            return ': $value';
          }
          return ': "${value.replaceAll('"', '\\"')}"';
        },
      );

      return Map<String, dynamic>.from(jsonDecode(corrected));
    } catch (e) {
      return null;
    }
  }

  Widget _buildKeyValueEditor(
    Map<String, dynamic> map,
    void Function(void Function()) onChanged, {
    required String label,
  }) {
    final keys = map.keys.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        ...List.generate(keys.length, (i) {
          final k = keys[i];
          return Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: k,
                  decoration: const InputDecoration(labelText: 'Key'),
                  onChanged: (val) => onChanged(() {
                    final value = map.remove(k);
                    map[val] = value!;
                  }),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  initialValue: map[k].toString(),
                  decoration: const InputDecoration(labelText: 'Value'),
                  onChanged: (val) => onChanged(() {
                    map[k] = val;
                  }),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => onChanged(() => map.remove(k)),
              ),
            ],
          );
        }),
        TextButton.icon(
          onPressed: () => onChanged(() => map[''] = ''),
          icon: const Icon(Icons.add),
          label: const Text("Add"),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text("Edit & Repeat"),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // Path
            TextFormField(
              controller: _pathController,
              decoration: const InputDecoration(labelText: "Path"),
            ),
            const SizedBox(height: 12),

            // Method dropdown
            DropdownButtonFormField<NetworkRequestMethod>(
              initialValue: _method,
              items: NetworkRequestMethod.values
                  .map((m) => DropdownMenuItem(
                        value: m,
                        child: Text(m.value),
                      ))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _method = val);
              },
              decoration: const InputDecoration(labelText: "Method"),
            ),

            const SizedBox(height: 16),

            _buildKeyValueEditor(
              _queryParams,
              setState,
              label: "Query Parameters",
            ),

            const SizedBox(height: 16),

            _buildKeyValueEditor(
              _headers,
              setState,
              label: "Headers",
            ),

            const SizedBox(height: 16),

            // Body
            TextFormField(
              controller: _bodyController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: "Body (raw)",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),
            GradientButton.icon(
              onPressed: _sendRequest,
              icon: Icons.send,
              label: const Text("Send"),
            )
          ],
        ),
      ),
    );
  }
}
