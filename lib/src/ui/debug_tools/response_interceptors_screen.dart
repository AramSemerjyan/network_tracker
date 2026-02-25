import 'package:flutter/material.dart';
import 'package:network_tracker/src/model/network_request.dart';
import 'package:network_tracker/src/model/response_modification.dart';
import 'package:network_tracker/src/services/network_request_service.dart';
import 'package:network_tracker/src/services/request_status.dart';
import 'package:network_tracker/src/ui/common/readable_theme_colors.dart';
import 'package:network_tracker/src/ui/response_modify_screen/network_modify_response_screen.dart';

/// Screen listing all saved response interceptors/modifications.
class ResponseInterceptorsScreen extends StatefulWidget {
  /// Creates a [ResponseInterceptorsScreen] instance.
  const ResponseInterceptorsScreen({super.key});

  @override
  State<ResponseInterceptorsScreen> createState() =>
      _ResponseInterceptorsScreenState();
}

class _ResponseInterceptorsScreenState
    extends State<ResponseInterceptorsScreen> {
  final _service = NetworkRequestService.instance;
  List<ResponseModificationEntry> _entries = const [];

  @override
  void initState() {
    super.initState();
    _refreshEntries();
  }

  void _refreshEntries() {
    if (!mounted) return;
    setState(() {
      _entries = _service.getAllResponseModifications();
    });
  }

  NetworkRequest _buildRequestFromEntry(ResponseModificationEntry entry) {
    final now = DateTime.now();
    return NetworkRequest(
      id: 'interceptor_${entry.method.value}_${entry.baseUrl}_${entry.path}_$now',
      path: entry.path,
      baseUrl: entry.baseUrl,
      method: entry.method,
      startDate: now,
      endDate: now,
      status: RequestStatus.completed,
      responseData: entry.modification.responseData,
      statusCode: entry.modification.statusCode,
      responseHeaders: entry.modification.headers == null
          ? null
          : Map<String, dynamic>.from(entry.modification.headers!),
      isModified: true,
    );
  }

  Future<void> _openInterceptor(ResponseModificationEntry entry) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NetworkModifyResponseScreen(
          originalRequest: _buildRequestFromEntry(entry),
        ),
      ),
    );

    if (result is Map) {
      final delayMs = result['delayMs'];
      final headersRaw = result['headers'];

      final modification = ResponseModification(
        statusCode: result['statusCode'] as int?,
        responseData: result['responseData'],
        headers: headersRaw is Map
            ? headersRaw.map((k, v) => MapEntry(k.toString(), v.toString()))
            : null,
        delay: delayMs is int ? Duration(milliseconds: delayMs) : null,
      );

      _service.setResponseModification(
        baseUrl: entry.baseUrl,
        path: entry.path,
        method: entry.method,
        modification: modification,
      );
    }

    _refreshEntries();
  }

  Widget _buildInterceptorTile(ResponseModificationEntry entry) {
    final delay = entry.modification.delay?.inMilliseconds;
    final subtitle =
        delay != null ? '${entry.baseUrl}\nDelay: ${delay}ms' : entry.baseUrl;

    return ListTile(
      title: Text('${entry.method.value} ${entry.path}'),
      subtitle: Text(subtitle),
      isThreeLine: delay != null,
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _openInterceptor(entry),
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
          title: Text('Response Interceptors (${_entries.length})'),
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
        ),
        body: _entries.isEmpty
            ? const Center(child: Text('No response interceptors yet'))
            : ListView.separated(
                itemCount: _entries.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, index) {
                  return _buildInterceptorTile(_entries[index]);
                },
              ),
      ),
    );
  }
}
