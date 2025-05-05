import 'package:flutter/material.dart';
import 'package:json_view/json_view.dart';
import 'package:network_tracker/src/ui/common/repeat_request_badge.dart';
import 'package:network_tracker/src/ui/common/repeat_request_button.dart';
import 'package:share_plus/share_plus.dart';

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.request.isRepeated ?? false)
              Padding(
                padding: EdgeInsets.only(left: 16),
                child: RepeatRequestBadge(),
              ),
            if (widget.request.requestData != null)
              ListTile(
                title: const Text('Request Data:'),
                subtitle: JsonView(
                  json: widget.request.requestData,
                  shrinkWrap: true,
                ),
              ),
            if (widget.request.queryParameters?.isNotEmpty ?? false)
              ListTile(
                title: const Text('Request Parameters:'),
                subtitle: JsonView(
                  json: widget.request.queryParameters,
                  shrinkWrap: true,
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
              Expanded(
                child: ListTile(
                  title: Row(
                    children: [
                      const Text('Response data:'),
                      const Spacer(),
                      IconButton(
                        onPressed: () async {
                          final path = await _vm.exportResponseData();

                          if (path != null) {
                            await Share.shareXFiles([XFile(path)]);
                          }
                        },
                        icon: const Icon(Icons.save_alt),
                      )
                    ],
                  ),
                  subtitle: JsonView(
                    json: widget.request.responseData,
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
