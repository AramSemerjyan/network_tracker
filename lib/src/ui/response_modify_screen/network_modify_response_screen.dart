import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:json_view/json_view.dart';

import '../../model/network_request.dart';

enum PresetGroupType { status, custom }

class ResponsePreset {
  final String label;
  final int? statusCode;
  final String? body;
  final Map<String, String>? headers;
  final Duration? delay;
  final PresetGroupType group;
  const ResponsePreset({
    required this.label,
    required this.group,
    this.statusCode,
    this.body,
    this.headers,
    this.delay,
  });
}

const List<ResponsePreset> kStatusPresets = [
  ResponsePreset(
      label: '200 OK',
      group: PresetGroupType.status,
      statusCode: 200,
      body: '{"message": "Success"}'),
  ResponsePreset(
      label: '400 Bad Request',
      group: PresetGroupType.status,
      statusCode: 400,
      body: '{"error": "Bad Request"}'),
  ResponsePreset(
      label: '401 Unauthorized',
      group: PresetGroupType.status,
      statusCode: 401,
      body: '{"error": "Unauthorized"}'),
  ResponsePreset(
      label: '403 Forbidden',
      group: PresetGroupType.status,
      statusCode: 403,
      body: '{"error": "Forbidden"}'),
  ResponsePreset(
      label: '404 Not Found',
      group: PresetGroupType.status,
      statusCode: 404,
      body: '{"error": "Not Found"}'),
  ResponsePreset(
      label: '500 Internal Error',
      group: PresetGroupType.status,
      statusCode: 500,
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

  late final ValueNotifier<List<ResponsePreset>> _selectedPresets;
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
    _bodyController = TextEditingController(text: _formatBody(r.responseData));
    _headersController =
        TextEditingController(text: _formatHeaders(r.responseHeaders));
    _delayController = TextEditingController();
    _availablePresets = ValueNotifier<List<ResponsePreset>>(
        List<ResponsePreset>.from([...kStatusPresets, ...kCustomPresets]));
    _selectedPresets = ValueNotifier<List<ResponsePreset>>([]);
  }

  @override
  void dispose() {
    _statusController.dispose();
    _bodyController.dispose();
    _headersController.dispose();
    _delayController.dispose();
    _availablePresets.dispose();
    _selectedPresets.dispose();
    super.dispose();
  }

  void _selectPreset(ResponsePreset preset) {
    final selected = List<ResponsePreset>.from(_selectedPresets.value);
    final available = List<ResponsePreset>.from(_availablePresets.value);
    selected.add(preset);
    available.remove(preset);
    _selectedPresets.value = selected;
    _availablePresets.value = available;
    // Apply preset values to fields
    _statusController.text = preset.statusCode.toString();
    if (preset.body != null) _bodyController.text = preset.body!;
    if (preset.headers != null) {
      _headersController.text = jsonEncode(preset.headers);
    }
    if (preset.delay != null) {
      _delayController.text = preset.delay!.inMilliseconds.toString();
    }
  }

  void _removePreset(ResponsePreset preset) {
    final selected = List<ResponsePreset>.from(_selectedPresets.value);
    final available = List<ResponsePreset>.from(_availablePresets.value);
    selected.remove(preset);
    available.add(preset);
    _selectedPresets.value = selected;
    _availablePresets.value = available;
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
            _ExpandablePresetsSection(
              availablePresets: _availablePresets,
              onSelect: _selectPreset,
            ),
            const SizedBox(height: 8),
            // Selected presets wrap
            ValueListenableBuilder<List<ResponsePreset>>(
              valueListenable: _selectedPresets,
              builder: (context, selectedPresets, _) =>
                  selectedPresets.isNotEmpty
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
                      : const SizedBox.shrink(),
            ),
            ValueListenableBuilder<List<ResponsePreset>>(
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
            ),
            const SizedBox(height: 16),
            _ExpandableJsonSection(
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
            _ExpandableJsonSection(
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

class _ExpandableJsonSection extends StatelessWidget {
  final String title;
  final double maxHeight;
  final VoidCallback onAdd;
  final dynamic jsonView;
  final Widget editor;

  const _ExpandableJsonSection({
    required this.title,
    required this.maxHeight,
    required this.onAdd,
    required this.jsonView,
    required this.editor,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Row(
        children: [
          Text(title),
          const Spacer(),
          IconButton(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            tooltip: 'Add key/value',
          ),
        ],
      ),
      childrenPadding: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _JsonPreviewTile(jsonView: jsonView),
                const SizedBox(height: 8),
                editor,
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _JsonPreviewTile extends StatelessWidget {
  final dynamic jsonView;

  const _JsonPreviewTile({required this.jsonView});

  @override
  Widget build(BuildContext context) {
    final canRenderJson = jsonView is Map || jsonView is List;

    return ExpansionTile(
      title: const Text('Preview JSON'),
      initiallyExpanded: false,
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 8),
      children: [
        if (canRenderJson)
          JsonView(
            json: jsonView,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
          )
        else
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Not a JSON object'),
          ),
      ],
    );
  }
}

class _ExpandablePresetsSection extends StatefulWidget {
  final ValueNotifier<List<ResponsePreset>> availablePresets;
  final void Function(ResponsePreset) onSelect;
  const _ExpandablePresetsSection({
    required this.availablePresets,
    required this.onSelect,
  });

  @override
  State<_ExpandablePresetsSection> createState() =>
      _ExpandablePresetsSectionState();
}

class _ExpandablePresetsSectionState extends State<_ExpandablePresetsSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text('Presets', style: Theme.of(context).textTheme.titleMedium),
      initiallyExpanded: false,
      onExpansionChanged: (v) => setState(() => _expanded = v),
      childrenPadding: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
      children: [
        ValueListenableBuilder<List<ResponsePreset>>(
          valueListenable: widget.availablePresets,
          builder: (context, availablePresets, _) {
            final statusPresets = availablePresets
                .where((p) => p.group == PresetGroupType.status)
                .toList();
            final customPresets = availablePresets
                .where((p) => p.group == PresetGroupType.custom)
                .toList();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (statusPresets.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 2),
                    child: Text('Status codes',
                        style: Theme.of(context).textTheme.bodySmall),
                  ),
                  SizedBox(
                    height: 48,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: statusPresets.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final preset = statusPresets[i];
                        return ActionChip(
                          label: Text(preset.label),
                          onPressed: () => widget.onSelect(preset),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                if (customPresets.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 2),
                    child: Text('Custom',
                        style: Theme.of(context).textTheme.bodySmall),
                  ),
                  SizedBox(
                    height: 48,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: customPresets.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final preset = customPresets[i];
                        return ActionChip(
                          label: Text(preset.label),
                          onPressed: () => widget.onSelect(preset),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}
