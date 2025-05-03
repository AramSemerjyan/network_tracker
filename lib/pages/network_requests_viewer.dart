import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:json_view/json_view.dart';
import 'package:network_tracker/services/network_request_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../services/network_request.dart';

class NetworkRequestsViewer extends StatefulWidget {
  static showPage({
    required BuildContext context,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      backgroundColor: Colors.transparent,
      builder: (c) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 90 / 100,
            minHeight: 200,
          ),
          child: Container(
            clipBehavior: Clip.hardEdge,
            padding: const EdgeInsets.fromLTRB(
              16,
              4,
              16,
              4,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                topLeft: Radius.circular(16),
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Flexible(child: NetworkRequestsViewer()),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  const NetworkRequestsViewer({
    super.key,
  });

  @override
  State<NetworkRequestsViewer> createState() => _NetworkRequestsViewerState();
}

class _NetworkRequestsViewerState extends State<NetworkRequestsViewer> {
  late final storage = NetworkRequestStorage.instance;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showSearchBar = false;

  final _focusNode = FocusNode();

  List<String> get _filteredPaths {
    final allPaths = storage.getTrackedPaths();
    if (_searchQuery.isEmpty) return allPaths;

    return allPaths
        .where(
            (path) => path.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _onSearchTap() {
    setState(() {
      _showSearchBar = !_showSearchBar;
      if (!_showSearchBar) {
        _searchQuery = '';
        _searchController.clear();
      }
      _focusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Network requests'),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(_showSearchBar ? Icons.close : Icons.search),
            tooltip: _showSearchBar ? 'Hide search' : 'Show search',
            onPressed: _onSearchTap,
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          const Text('Base URL:'),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: storage.baseUrl));
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                storage.baseUrl,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          if (_showSearchBar) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                onChanged: _search,
                decoration: InputDecoration(
                  hintText: 'Search by path...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Expanded(
            child: _filteredPaths.isEmpty
                ? const Center(child: Text('No matching requests'))
                : ListView.separated(
                    itemCount: _filteredPaths.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final path = _filteredPaths[index];
                      final requests = storage.getRequestsByPath(path);
                      return ListTile(
                        title: Text(path),
                        trailing: Text('${requests.length} requests'),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => _RequestDetailsScreen(
                              path: path,
                              requests: requests,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _RequestDetailsScreen extends StatelessWidget {
  final String path;
  final List<NetworkRequest> requests;

  const _RequestDetailsScreen({required this.path, required this.requests});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(path),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView.builder(
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final request = requests[index];
          return ListTile(
            title: Text('${request.method} - ${request.timestamp}'),
            subtitle:
                Text('Status: ${request.status.symbol} ${request.status}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => _RequestDataDetailsScreen(
                    request: request,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _RequestDataDetailsScreen extends StatelessWidget {
  final NetworkRequest request;

  const _RequestDataDetailsScreen({required this.request});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${request.method} - ${request.timestamp}',
          style: const TextStyle(fontSize: 14),
        ),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (request.requestData != null)
              ListTile(
                title: const Text('Request Data:'),
                subtitle: JsonView(
                  json: request.requestData,
                  shrinkWrap: true,
                ),
              ),
            if (request.queryParameters?.isNotEmpty ?? false)
              ListTile(
                title: const Text('Request Parameters:'),
                subtitle: JsonView(
                  json: request.queryParameters,
                  shrinkWrap: true,
                ),
              ),
            if (request.execTime != null)
              ListTile(
                title: const Text('Request time:'),
                subtitle: Text(
                  '${request.execTime!.millisecondsSinceEpoch / 1000.0}',
                ),
              ),
            if (request.error != null)
              ListTile(
                title: const Text('Error:'),
                subtitle: Text('${request.error}'),
              ),
            if (request.responseData != null)
              Expanded(
                child: ListTile(
                  title: Row(
                    children: [
                      const Text('Response data:'),
                      const Spacer(),
                      IconButton(
                        onPressed: () async {
                          try {
                            final tempDir = await getTemporaryDirectory();
                            final filePath =
                                '${tempDir.path}/${request.name}.json';
                            final jsonString = jsonEncode(request.responseData);
                            final file = File(filePath);
                            await file.writeAsString(jsonString);

                            await Share.shareXFiles([XFile(file.path)]);
                          } catch (e) {
                            if (kDebugMode) {
                              print("Error saving or sharing JSON file: $e");
                            }
                          }
                        },
                        icon: const Icon(Icons.save_alt),
                      )
                    ],
                  ),
                  subtitle: JsonView(
                    json: request.responseData,
                    padding: const EdgeInsets.only(bottom: 40),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
