import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:network_tracker/src/model/network_request.dart';
import 'package:network_tracker/src/ui/common/readable_theme_colors.dart';
import 'package:network_tracker/src/ui/debug_tools/debug_tools_screen.dart';
import 'package:network_tracker/src/ui/filter/filter_bar.dart';
import 'package:network_tracker/src/ui/repeat_request_screen/network_repeat_request_screen.dart';
import 'package:network_tracker/src/ui/request_viewer/network_request_viewer_vm.dart';

import '../common/connection_status_view/connection_status_view.dart';
import '../request_details_screen/request_details_screen.dart';

enum _RequestsMenuAction {
  debugTools,
  repeatRequest,
  toggleSearch,
  toggleFilter,
  clearAll,
}

class NetworkRequestsViewer extends StatefulWidget {
  static void showPage({
    required BuildContext context,
  }) {
    final scheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      barrierColor: scheme.scrim.withValues(alpha: 0.5),
      backgroundColor: Colors.transparent,
      builder: (c) {
        final backgroundColor = ReadableThemeColors.resolveBackground(c);
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
              color: backgroundColor,
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
        builder: (_) => RequestDetailsScreen(
          path: path,
          baseUrl: _vm.selectedBaseUrl.value,
        ),
      ),
    );
  }

  void _moveToRepeat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NetworkRepeatRequestScreen(
          baseUrl: _vm.selectedBaseUrl.value,
        ),
      ),
    );
  }

  void _moveToDebugTools() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DebugToolsScreen(),
      ),
    );
  }

  void _onMenuAction(_RequestsMenuAction action) {
    switch (action) {
      case _RequestsMenuAction.debugTools:
        _moveToDebugTools();
        break;
      case _RequestsMenuAction.repeatRequest:
        _moveToRepeat();
        break;
      case _RequestsMenuAction.toggleSearch:
        _onSearchTap();
        break;
      case _RequestsMenuAction.toggleFilter:
        _onFilterTap();
        break;
      case _RequestsMenuAction.clearAll:
        _vm.clearRequestsList();
    }
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
        final backgroundColor = ReadableThemeColors.resolveBackground(context);
        final foregroundColor =
            ReadableThemeColors.resolveForeground(context, backgroundColor);
        final secondaryColor =
            ReadableThemeColors.resolveMutedForeground(foregroundColor);
        final requests = list[index];
        final path = requests.first.path;

        return ListTile(
          title: Text(
            path,
            style: TextStyle(color: foregroundColor),
          ),
          trailing: Text(
            '${requests.length} requests',
            style: TextStyle(color: secondaryColor),
          ),
          onTap: () => _moveToDetails(path),
        );
      },
    );
  }

  PopupMenuItem<_RequestsMenuAction> _buildMenuItem({
    required _RequestsMenuAction value,
    required IconData icon,
    required String label,
    required Color foregroundColor,
  }) {
    return PopupMenuItem<_RequestsMenuAction>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: foregroundColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(color: foregroundColor),
          ),
        ],
      ),
    );
  }

  Widget _buildBaseUrlRow() {
    final backgroundColor = ReadableThemeColors.resolveBackground(context);
    final foregroundColor =
        ReadableThemeColors.resolveForeground(context, backgroundColor);

    return ValueListenableBuilder<String>(
      valueListenable: _vm.selectedBaseUrl,
      builder: (context, selected, _) {
        return Column(
          children: [
            Row(
              children: [
                const Spacer(),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: selected));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Base URL copied to clipboard')),
                    );
                  },
                  child: const Icon(Icons.copy, size: 15),
                ),
                const SizedBox(width: 5),
                const Text('Base URL:'),
                const Spacer(),
              ],
            ),
            FutureBuilder(
              future: _vm.storageService.getUrls(),
              builder: (c, f) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: selected,
                    dropdownColor: backgroundColor,
                    style: TextStyle(color: foregroundColor),
                    icon: const Icon(Icons.arrow_drop_down),
                    onChanged: (value) {
                      if (value != null) {
                        _vm.selectedBaseUrl.value = value;
                      }
                    },
                    items: (f.data ?? []).map((url) {
                      return DropdownMenuItem<String>(
                        value: url,
                        child: Text(
                          url,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: foregroundColor,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenTheme = ReadableThemeColors.screenTheme(context);
    final backgroundColor = screenTheme.scaffoldBackgroundColor;
    final foregroundColor =
        ReadableThemeColors.resolveForeground(context, backgroundColor);
    return Theme(
      data: screenTheme,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: Center(child: const Text('Requests')),
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          leading: CloseButton(),
          actions: [
            PopupMenuButton<_RequestsMenuAction>(
              color: backgroundColor,
              icon: Icon(Icons.more_vert, color: foregroundColor),
              onSelected: _onMenuAction,
              itemBuilder: (context) {
                final showSearch = _showSearchBar.value;
                final showFilter = _showFilterBar.value;
                return [
                  _buildMenuItem(
                    value: _RequestsMenuAction.debugTools,
                    icon: Icons.bug_report,
                    label: 'Debug tools',
                    foregroundColor: foregroundColor,
                  ),
                  _buildMenuItem(
                    value: _RequestsMenuAction.repeatRequest,
                    icon: Icons.repeat,
                    label: 'Repeat request',
                    foregroundColor: foregroundColor,
                  ),
                  _buildMenuItem(
                    value: _RequestsMenuAction.toggleSearch,
                    icon: showSearch ? Icons.close : Icons.search,
                    label: showSearch ? 'Hide search' : 'Show search',
                    foregroundColor: foregroundColor,
                  ),
                  _buildMenuItem(
                    value: _RequestsMenuAction.toggleFilter,
                    icon: showFilter ? Icons.filter_alt_off : Icons.filter_alt,
                    label: showFilter ? 'Hide filters' : 'Show filters',
                    foregroundColor: foregroundColor,
                  ),
                  _buildMenuItem(
                    value: _RequestsMenuAction.clearAll,
                    icon: Icons.delete_forever,
                    label: 'Clear requests',
                    foregroundColor: foregroundColor,
                  ),
                ];
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 8),
                _buildBaseUrlRow(),
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
            Positioned(
              bottom: 8,
              right: 8,
              child: ConnectionStatusView(),
            ),
          ],
        ),
      ),
    );
  }
}
