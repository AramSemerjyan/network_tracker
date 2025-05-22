import 'package:flutter/material.dart';
import 'package:json_view/json_view.dart';
import 'package:network_tracker/src/ui/common/repeat_request_badge.dart';
import 'package:network_tracker/src/ui/common/repeat_request_button.dart';

import '../../model/network_request.dart';
import 'request_data_details_screen_vm.dart';

class RequestDataDetailsScreen extends StatefulWidget {
  final NetworkRequest request;

  const RequestDataDetailsScreen({super.key, required this.request});

  @override
  State<RequestDataDetailsScreen> createState() =>
      _RequestDataDetailsScreenState();
}

class _RequestDataDetailsScreenState extends State<RequestDataDetailsScreen> {
  late final _vm = RequestDataDetailsScreenVM(widget.request);

  Widget _buildBody() {
    final response = widget.request.responseData;

    if (response is List || response is Map) {
      return JsonView(
        json: response,
        padding: const EdgeInsets.only(bottom: 40),
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
      );
    }

    return Text(response.toString());
  }

  Widget _buildBadgesRow(NetworkRequest request) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        spacing: 5,
        children: [
          if (request.isRepeated ?? false)
            RequestBadge(config: RequestBadgeConfig.repeated()),
          if (request.isThrottled ?? false)
            RequestBadge(config: RequestBadgeConfig.throttled()),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.request.method.value} - ${widget.request.startDate}',
          style: const TextStyle(fontSize: 14),
        ),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        actions: [
          RepeatRequestButton(request: widget.request),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBadgesRow(widget.request),
              if (widget.request.requestData != null)
                ListTile(
                  title: const Text('Request Data:'),
                  subtitle: JsonView(
                    json: widget.request.requestData,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                  ),
                ),
              if (widget.request.queryParameters?.isNotEmpty ?? false)
                ListTile(
                  title: const Text('Request Parameters:'),
                  subtitle: JsonView(
                    json: widget.request.queryParameters,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                  ),
                ),
              if (widget.request.headers?.isNotEmpty ?? false)
                ListTile(
                  title: const Text('Request Headers:'),
                  subtitle: JsonView(
                    json: widget.request.headers,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                  ),
                ),
              if (widget.request.duration != null)
                ListTile(
                  title: const Text('Duration:'),
                  subtitle: Text(
                    '${widget.request.duration?.inMilliseconds}ms',
                  ),
                ),
              if (widget.request.dioError?.error != null)
                ListTile(
                  title: const Text('Error:'),
                  subtitle: Text('${widget.request.dioError?.error}'),
                ),
              if (widget.request.dioError?.message != null)
                ListTile(
                  title: const Text('Error message:'),
                  subtitle: Text('${widget.request.dioError?.message}'),
                ),
              if (widget.request.responseData != null)
                ListTile(
                  title: Row(
                    children: [
                      const Text('Response data:'),
                      const Spacer(),
                      IconButton(
                        onPressed: _vm.shareRequest,
                        icon: const Icon(Icons.save_alt),
                      )
                    ],
                  ),
                  subtitle: _buildBody(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
