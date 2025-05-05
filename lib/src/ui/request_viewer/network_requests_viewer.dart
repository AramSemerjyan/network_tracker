import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:network_tracker/src/model/network_request.dart';
import 'package:network_tracker/src/ui/filter/filter_bar.dart';
import 'package:network_tracker/src/ui/repeat_request_screen/network_repeat_request_screen.dart';
import 'package:network_tracker/src/ui/request_viewer/network_request_viewer_vm.dart';

import '../request_details_screen/request_details_screen.dart';

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
  final _vm = NetworkRequestViewerVM();
  final TextEditingController _searchController = TextEditingController();

  final ValueNotifier<bool> _showSearchBar = ValueNotifier(false);
  final ValueNotifier<bool> _showFilterBar = ValueNotifier(false);

  final _focusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _vm.dispose();
    super.dispose();
  }

  void _onSearchTap() {
    _showSearchBar.value = !_showSearchBar.value;
    _focusNode.requestFocus();
  }

  void _onFilterTap() {
    _showFilterBar.value = !_showFilterBar.value;
  }

  void _clearSearchText() {
    _searchController.text = '';
    _vm.clearSearchText();
  }

  void _moveToDetails(String path) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RequestDetailsScreen(path: path),
      ),
    );
  }

  void _moveToRepeat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NetworkRepeatRequestScreen(),
      ),
    );
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
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _focusNode,
                      onChanged: _vm.search,
                      decoration: InputDecoration(
                        hintText: 'Search by path...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        prefixIcon: const Icon(Icons.search),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: _clearSearchText,
                    child: Text(
                      'Clear',
                    ),
                  ),
                ],
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
              ValueListenableBuilder(
                valueListenable: _vm.filterNotifier,
                builder: (c, v, w) {
                  return FilterBar(
                    filter: v,
                    onChange: _vm.onFilterChanged,
                    onClear: _vm.clearFilter,
                  );
                },
              )
            ],
          );
        }

        return Container();
      },
    );
  }

  Widget _buildEmptyState() {
    return const Center(child: Text('No matching requests'));
  }

  Widget _buildList(List<List<NetworkRequest>> list) {
    return ListView.separated(
      itemCount: list.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final requests = list[index];
        final path = requests.first.path;

        return ListTile(
          title: Text(path),
          trailing: Text('${requests.length} requests'),
          onTap: () => _moveToDetails(path),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Center(child: const Text('Requests')),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        leading: CloseButton(),
        actions: [
          IconButton(
            onPressed: _moveToRepeat,
            icon: Icon(Icons.repeat),
          ),
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
          Row(
            children: [
              const Spacer(),
              InkWell(
                onTap: () {
                  Clipboard.setData(
                      ClipboardData(text: _vm.storageService.baseUrl));
                },
                child: Icon(
                  Icons.copy,
                  size: 15,
                ),
              ),
              const SizedBox(width: 5),
              const Text('Base URL:'),
              const Spacer(),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              _vm.storageService.baseUrl,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          _buildSearchBar(),
          _buildFilterBar(),
          const SizedBox(height: 10),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: _vm.filteredRequestsNotifier,
              builder: (c, f, w) {
                return f.isEmpty ? _buildEmptyState() : _buildList(f);
              },
            ),
          ),
        ],
      ),
    );
  }
}
