import 'dart:convert';

import 'package:flutter/material.dart';

import '../../model/network_request.dart';
import '../../services/request_status.dart';
import 'expandable_json_section.dart';
import 'expandable_presets_section.dart';
import 'reponse_preset.dart';

const List<ResponsePreset> kStatusPresets = [
  ResponsePreset(
      label: '200 OK',
      group: PresetGroupType.status,
      statusCode: 200,
      requestStatus: RequestStatus.completed,
      body: '{"message": "Success"}'),
  ResponsePreset(
      label: '400 Bad Request',
      group: PresetGroupType.status,
      statusCode: 400,
      requestStatus: RequestStatus.failed,
      body: '{"error": "Bad Request"}'),
  ResponsePreset(
      label: '401 Unauthorized',
      group: PresetGroupType.status,
      statusCode: 401,
      requestStatus: RequestStatus.failed,
      body: '{"error": "Unauthorized"}'),
  ResponsePreset(
      label: '403 Forbidden',
      group: PresetGroupType.status,
      statusCode: 403,
      requestStatus: RequestStatus.failed,
      body: '{"error": "Forbidden"}'),
  ResponsePreset(
      label: '404 Not Found',
      group: PresetGroupType.status,
      statusCode: 404,
      requestStatus: RequestStatus.failed,
      body: '{"error": "Not Found"}'),
  ResponsePreset(
      label: '500 Internal Error',
      group: PresetGroupType.status,
      statusCode: 500,
      requestStatus: RequestStatus.failed,
      body: '{"error": "Internal Server Error"}'),
];

const List<ResponsePreset> kCustomPresets = [];

class NetworkModifyResponseScreen extends StatefulWidget {
  final NetworkRequest originalRequest;

  const NetworkModifyResponseScreen({
    super.key,
    required this.originalRequest,
  });

  @override
  State<NetworkModifyResponseScreen> createState() =>
      _NetworkModifyResponseScreenState();
}

class _NetworkModifyResponseScreenState
    extends State<NetworkModifyResponseScreen> {
  static const double _jsonSectionMaxHeight = 300;

  late final ValueNotifier<Set<ResponsePreset>> _selectedPresets;
  late final ValueNotifier<List<ResponsePreset>> _availablePresets;
  late final TextEditingController _headersController;
  late final TextEditingController _delayController;
  late final TextEditingController _statusController;
  late final TextEditingController _bodyController;

  @override
  void initState() {
    super.initState();
    final r = widget.originalRequest;
    _statusController =
        TextEditingController(text: r.statusCode?.toString() ?? '');
    // _statusController.addListener(_onStatusCodeChanged);
    _bodyController = TextEditingController(text: _formatBody(r.responseData));
    _headersController =
        TextEditingController(text: _formatHeaders(r.responseHeaders));
    _delayController = TextEditingController();
    _availablePresets = ValueNotifier<List<ResponsePreset>>(
        List<ResponsePreset>.from([...kStatusPresets, ...kCustomPresets]));
    _selectedPresets = ValueNotifier<Set<ResponsePreset>>({});
  }

  @override
  void dispose() {
    // _statusController.removeListener(_onStatusCodeChanged);
    _statusController.dispose();
    _bodyController.dispose();
    _headersController.dispose();
    _delayController.dispose();
    _availablePresets.dispose();
    _selectedPresets.dispose();
    super.dispose();
  }

  void _onStatusCodeChanged() {
    // If a status preset is selected, remove it if user edits status code
    final selected = List<ResponsePreset>.from(_selectedPresets.value);
    final statusPreset =
        selected.where((p) => p.group == PresetGroupType.status).toList();
    if (statusPreset.isNotEmpty) {
      for (final preset in statusPreset) {
        _removePreset(preset);
      }
    }
  }

  void _selectPreset(ResponsePreset preset) {
    final selected = Set<ResponsePreset>.from(_selectedPresets.value);
    final available = List<ResponsePreset>.from(_availablePresets.value);
    // Prevent multiple status presets
    if (preset.group == PresetGroupType.status) {
      final existingStatus =
          selected.where((p) => p.group == PresetGroupType.status).toList();
      for (final item in existingStatus) {
        selected.remove(item);
        if (!available.contains(item)) {
          available.add(item);
        }
      }
    }
    selected.add(preset);
    _selectedPresets.value = selected;
    _availablePresets.value = available;
    // Apply preset values to fields
    _statusController.text = preset.statusCode?.toString() ?? '';
    if (preset.body != null) _bodyController.text = preset.body!;
    if (preset.headers != null) {
      _headersController.text = jsonEncode(preset.headers);
    }
    if (preset.delay != null) {
      _delayController.text = preset.delay!.inMilliseconds.toString();
    }
  }

  void _removePreset(ResponsePreset preset) {
    final selected = Set<ResponsePreset>.from(_selectedPresets.value);
    selected.remove(preset);
    _selectedPresets.value = selected;
  }

  String _formatBody(dynamic body) {
    if (body == null) return '';
    if (body is Map || body is List) {
      return const JsonEncoder.withIndent('  ').convert(body);
    }
    return body.toString();
  }

  String _formatHeaders(Map<String, dynamic>? headers) {
    if (headers == null || headers.isEmpty) return '';
    return const JsonEncoder.withIndent('  ').convert(headers);
  }

  dynamic _tryDecodeJson(String raw) {
    if (raw.trim().isEmpty) return null;
    try {
      return jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> _ensureJsonMap(String raw) {
    final decoded = _tryDecodeJson(raw);
    if (decoded is Map) {
      return decoded.map((k, v) => MapEntry(k.toString(), v));
    }
    return <String, dynamic>{};
  }

  void _addJsonEntry({
    required String title,
    required TextEditingController controller,
  }) {
    final existing = _tryDecodeJson(controller.text);
    if (controller.text.trim().isNotEmpty && existing is! Map) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$title is not a JSON object')),
      );
      return;
    }
    final map = _ensureJsonMap(controller.text);
    // Add empty key-value pair
    map[""] = "";
    controller.text = const JsonEncoder.withIndent('  ').convert(map);
    setState(() {});
  }

  void _applyChanges() {
    final statusText = _statusController.text.trim();
    int? statusCode;
    if (statusText.isNotEmpty) {
      statusCode = int.tryParse(statusText);
      if (statusCode == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid status code')),
        );
        return;
      }
    }

    dynamic responseData;
    final rawBody = _bodyController.text.trim();
    if (rawBody.isNotEmpty) {
      try {
        responseData = jsonDecode(rawBody);
      } catch (_) {
        responseData = rawBody;
      }
    }

    Map<String, String>? headers;
    final headersText = _headersController.text.trim();
    if (headersText.isNotEmpty) {
      try {
        final decoded = jsonDecode(headersText);
        if (decoded is Map) {
          headers = decoded.map((k, v) => MapEntry(k.toString(), v.toString()));
        }
      } catch (_) {
        // ignore invalid headers
      }
    }

    int? delayMs;
    final delayText = _delayController.text.trim();
    if (delayText.isNotEmpty) {
      delayMs = int.tryParse(delayText);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Response modification prepared')),
    );

    Navigator.pop(context, {
      'statusCode': statusCode,
      'responseData': responseData,
      'headers': headers,
      'delayMs': delayMs,
      'presets': _selectedPresets.value.map((e) => e.label).toList(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final bodyJson = _tryDecodeJson(_bodyController.text);
    final headersJson = _tryDecodeJson(_headersController.text);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Modify Response'),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // Presets section (expandable)
            ExpandablePresetsSection(
              availablePresets: _availablePresets,
              onSelect: _selectPreset,
            ),
            const SizedBox(height: 8),
            // Selected presets wrap
            ValueListenableBuilder<Set<ResponsePreset>>(
                valueListenable: _selectedPresets,
                builder: (context, selectedPresets, _) {
                  return selectedPresets.isNotEmpty
                      ? Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: selectedPresets
                              .map((preset) => Chip(
                                    label: Text(preset.label),
                                    onDeleted: () => _removePreset(preset),
                                  ))
                              .toList(),
                        )
                      : const SizedBox.shrink();
                }),
            ValueListenableBuilder<Set<ResponsePreset>>(
              valueListenable: _selectedPresets,
              builder: (context, selectedPresets, _) =>
                  selectedPresets.isNotEmpty
                      ? const SizedBox(height: 16)
                      : const SizedBox.shrink(),
            ),
            Text(
              '${widget.originalRequest.method.value} ${widget.originalRequest.path}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _statusController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Status code',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) {
                _onStatusCodeChanged();
              },
            ),
            const SizedBox(height: 16),
            ExpandableJsonSection(
              title: 'Response body',
              maxHeight: _jsonSectionMaxHeight,
              onAdd: () => _addJsonEntry(
                title: 'response body',
                controller: _bodyController,
              ),
              jsonView: bodyJson,
              editor: TextFormField(
                controller: _bodyController,
                minLines: 4,
                maxLines: 8,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'JSON or text',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ExpandableJsonSection(
              title: 'Headers',
              maxHeight: _jsonSectionMaxHeight,
              onAdd: () => _addJsonEntry(
                title: 'header',
                controller: _headersController,
              ),
              jsonView: headersJson,
              editor: TextFormField(
                controller: _headersController,
                minLines: 3,
                maxLines: 6,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'JSON',
                  border: OutlineInputBorder(),
                  hintText: '{"X-Debug": "QA"}',
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Delay (ms)',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _delayController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Delay (ms)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _applyChanges,
              icon: const Icon(Icons.check),
              label: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }
}
