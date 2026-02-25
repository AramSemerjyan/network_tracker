import 'package:flutter/material.dart';
import 'package:network_tracker/src/ui/common/readable_theme_colors.dart';
import 'package:network_tracker/src/ui/common/request_actions_botton.dart';
import 'package:network_tracker/src/ui/request_details_screen/request_details_screen_vm.dart';

import '../../model/network_request.dart';
import '../common/requiest_badge_row.dart';
import '../filter/filter_bar.dart';
import '../request_data_details_screen/request_data_details_screen.dart';

class RequestDetailsScreen extends StatefulWidget {
  final String path;
  final String baseUrl;

  const RequestDetailsScreen({
    super.key,
    required this.path,
    required this.baseUrl,
  });

  @override
  State<RequestDetailsScreen> createState() => _RequestDetailsScreenState();
}

class _RequestDetailsScreenState extends State<RequestDetailsScreen> {
  late final _vm = RequestDetailsScreenVM(widget.baseUrl, widget.path);

  final ValueNotifier<bool> _showFilterBar = ValueNotifier(false);

  String _formatDate(DateTime date) {
    // Format as yyyy-MM-dd HH:mm:ss
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    final h = date.hour.toString().padLeft(2, '0');
    final min = date.minute.toString().padLeft(2, '0');
    final s = date.second.toString().padLeft(2, '0');
    return '$y-$m-$d $h:$min:$s';
  }

  void _moveToDetails(NetworkRequest request) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RequestDataDetailsScreen(
          request: request,
        ),
      ),
    );
  }

  void _onFilterTap() {
    _showFilterBar.value = !_showFilterBar.value;
  }

  Widget _buildValueRow(String title, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$title: ',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        Text(value),
      ],
    );
  }

  Widget _buildList(List<NetworkRequest> list) {
    return ListView.separated(
      itemCount: list.length,
      separatorBuilder: (_, __) => const Divider(
        indent: 16,
        endIndent: 16,
      ),
      itemBuilder: (context, index) {
        final request = list[index];
        return ListTile(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              RequestBadgeRow(request: request),
              Text(
                '${request.method.value} ${request.method.symbol} - ${_formatDate(request.startDate)}',
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              _buildValueRow(
                'Status',
                '${request.status.symbol} ${request.statusCode} ${request.status.name}',
              ),
              if (request.duration != null)
                _buildValueRow(
                  'Duration',
                  '${request.duration?.inMilliseconds}ms',
                ),
              _buildValueRow(
                'Size req/res',
                '${request.requestSizeString}/${request.responseSizeString}',
              ),
            ],
          ),
          trailing: RequestActionsButton(request: request),
          onTap: () => _moveToDetails(request),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return const Center(child: Text('No matching requests'));
  }

  Widget _buildFilterBar() {
    return ValueListenableBuilder<bool>(
      valueListenable: _showFilterBar,
      builder: (c, v, w) {
        if (v) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                ValueListenableBuilder(
                  valueListenable: _vm.filterNotifier,
                  builder: (c, v, w) {
                    return FilterBar(
                      filter: v,
                      shouldShowRepeated: true,
                      onChange: _vm.onFilterChanged,
                      onClear: _vm.clearFilter,
                    );
                  },
                )
              ],
            ),
          );
        }

        return Container();
      },
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
          title: Text(widget.path),
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          actions: [
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
            _buildFilterBar(),
            const SizedBox(height: 10),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: _vm.requestsNotifier,
                builder: (c, v, w) {
                  return v.isEmpty ? _buildEmptyState() : _buildList(v);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
