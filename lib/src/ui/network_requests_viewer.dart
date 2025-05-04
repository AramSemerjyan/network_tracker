import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:network_tracker/src/model/network_request.dart';
import 'package:network_tracker/src/model/network_reuqest_filter.dart';
import 'package:network_tracker/src/ui/filter/filter_bar.dart';

import '../services/network_request_service.dart';
import 'request_details_screen.dart';

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
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
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
  late final storage = NetworkRequestService.instance.storage;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  NetworkRequestFilter _filter = NetworkRequestFilter();

  final ValueNotifier<bool> _showSearchBar = ValueNotifier(false);
  final ValueNotifier<bool> _showFilterBar = ValueNotifier(false);

  final _focusNode = FocusNode();

  List<List<NetworkRequest>> get _filteredRequests {
    final List<List<NetworkRequest>> filteredRequests = [];
    List<String> allPaths = storage.getTrackedPaths();

    if (_searchQuery.isNotEmpty) {
      allPaths = allPaths
          .where(
              (path) => path.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    for (var p in allPaths) {
      List<NetworkRequest> requests = storage.getRequestsByPath(p);

      final method = _filter.method;
      if (method != null) {
        requests = requests.where((r) => r.method == method).toList();
      }

      final status = _filter.status;
      if (status != null) {
        requests = requests.where((r) => r.status == status).toList();
      }

      filteredRequests.add(requests);
    }

    return filteredRequests;
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
    _showSearchBar.value = !_showSearchBar.value;
    setState(() {
      if (!_showSearchBar.value) {
        _searchQuery = '';
        _searchController.clear();
      }
      _focusNode.requestFocus();
    });
  }

  void _onFilterTap() {
    _showFilterBar.value = !_showFilterBar.value;
  }

  void _onFilterChanged(NetworkRequestFilter filter) {
    setState(() {
      _filter = filter;
    });
  }

  void _clearFilter() {
    setState(() => _filter = NetworkRequestFilter());
  }

  Widget _buildSearchBar() {
    return ValueListenableBuilder<bool>(
      valueListenable: _showSearchBar,
      builder: (c, v, w) {
        if (v) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              TextField(
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
            ],
          );
        }

        return Container();
      },
    );
  }

  Widget _buildFilterBar() {
    return ValueListenableBuilder<bool>(
      valueListenable: _showFilterBar,
      builder: (c, v, w) {
        if (v) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              FilterBar(
                filter: _filter,
                onChange: _onFilterChanged,
                onClear: _clearFilter,
              )
            ],
          );
        }

        return Container();
      },
    );
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
          ValueListenableBuilder(
            valueListenable: _showSearchBar,
            builder: (c, v, w) {
              return IconButton(
                icon: Icon(v ? Icons.close : Icons.search),
                tooltip: v ? 'Hide search' : 'Show search',
                onPressed: _onSearchTap,
              );
            },
          ),
          ValueListenableBuilder(
            valueListenable: _showFilterBar,
            builder: (c, v, w) {
              return IconButton(
                onPressed: _onFilterTap,
                icon: Icon(
                  v ? Icons.filter_alt_off : Icons.filter_alt,
                ),
              );
            },
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
          _buildSearchBar(),
          _buildFilterBar(),
          const SizedBox(height: 10),
          Expanded(
            child: _filteredRequests.isEmpty
                ? const Center(child: Text('No matching requests'))
                : ListView.separated(
                    itemCount: _filteredRequests.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final requests = _filteredRequests[index];
                      final path = requests.first.path;

                      // final path = _filteredPaths[index];
                      // final requests = storage.getRequestsByPath(path);
                      return ListTile(
                        title: Text(path),
                        trailing: Text('${requests.length} requests'),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RequestDetailsScreen(
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
