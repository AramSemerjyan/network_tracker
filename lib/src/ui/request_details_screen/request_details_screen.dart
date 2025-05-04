import 'package:flutter/material.dart';
import 'package:network_tracker/src/ui/request_details_screen/request_details_screen_vm.dart';

import '../../model/network_request.dart';
import '../filter/filter_bar.dart';
import '../request_data_details_screen/request_data_details_screen.dart';

class RequestDetailsScreen extends StatefulWidget {
  final String path;
  final List<NetworkRequest> requests;

  const RequestDetailsScreen(
      {super.key, required this.path, required this.requests});

  @override
  State<RequestDetailsScreen> createState() => _RequestDetailsScreenState();
}

class _RequestDetailsScreenState extends State<RequestDetailsScreen> {
  late final _vm = RequestDetailsScreenVM(widget.requests);

  final ValueNotifier<bool> _showFilterBar = ValueNotifier(false);

  void _onFilterTap() {
    _showFilterBar.value = !_showFilterBar.value;
  }

  Widget _buildList(List<NetworkRequest> list) {
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        final request = list[index];
        return ListTile(
          title: Text('${request.method} - ${request.startDate}'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Status: ${request.status.symbol} ${request.status}'),
              if (request.duration != null)
                Text('Duration: ${request.duration?.inMilliseconds}ms')
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.send),
            onPressed: () => _vm.repeatRequest(request),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RequestDataDetailsScreen(
                  request: request,
                ),
              ),
            );
          },
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
    return Scaffold(
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
    );
  }
}
