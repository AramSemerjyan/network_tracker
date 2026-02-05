import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:network_tracker/src/model/response_modification.dart';
import 'package:network_tracker/src/services/network_request_service.dart';

import '../../model/network_request.dart';
import '../repeat_request_screen/edit_request_screen/network_edit_request_screen.dart';
import '../response_modify_screen/network_modify_response_screen.dart';
import 'repeat_request_button_vm.dart';

enum _ActionType {
  repeat,
  editRequest,
  copyCurl,
  modifyResponse,
}

class RequestActionsButton extends StatefulWidget {
  final bool shouldEditFirst;
  final NetworkRequest request;

  const RequestActionsButton({
    super.key,
    required this.request,
    this.shouldEditFirst = false,
  });

  @override
  State<RequestActionsButton> createState() => _RequestActionsButtonState();
}

class _RequestActionsButtonState extends State<RequestActionsButton> {
  final _vm = RepeatRequestButtonVM();

  void _moveToEdit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            NetworkEditRequestScreen(originalRequest: widget.request),
      ),
    );
  }

  Future<void> _moveToModifyResponse() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            NetworkModifyResponseScreen(originalRequest: widget.request),
      ),
    );

    if (result is! Map) return;

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

    NetworkRequestService.instance.setResponseModification(
      baseUrl: widget.request.baseUrl,
      path: widget.request.path,
      method: widget.request.method,
      modification: modification,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Response modification saved')),
      );
    }
  }

  void _copyCURL() {
    final curl = widget.request.toCurl();
    Clipboard.setData(ClipboardData(text: curl));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied cURL to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Check if the current Dio client has NetworkTrackerInterceptor
    final repeatService = NetworkRequestService.instance.repeatRequestService;
    final dio = repeatService.clients[widget.request.baseUrl];
    final hasInterceptor = dio?.interceptors.any((i) =>
            i.runtimeType.toString() ==
            'NetworkTrackerRequestModifierInterceptor') ??
        false;

    return PopupMenuButton<_ActionType>(
      icon: Container(
        padding: const EdgeInsets.only(left: 8),
        child: Icon(Icons.more_vert, size: 25),
      ),
      onSelected: (action) {
        switch (action) {
          case _ActionType.repeat:
            if (widget.shouldEditFirst) {
              _moveToEdit();
            } else {
              _vm.repeat(widget.request);
            }
            break;
          case _ActionType.editRequest:
            _moveToEdit();
            break;
          case _ActionType.modifyResponse:
            _moveToModifyResponse();
            break;
          case _ActionType.copyCurl:
            _copyCURL();
            break;
        }
      },
      itemBuilder: (context) {
        final items = <PopupMenuEntry<_ActionType>>[
          PopupMenuItem(
            value: _ActionType.repeat,
            child: Row(
              children: const [
                Icon(Icons.repeat, size: 20),
                SizedBox(width: 8),
                Text('Repeat Request'),
              ],
            ),
          ),
          PopupMenuItem(
            value: _ActionType.editRequest,
            child: Row(
              children: const [
                Icon(Icons.edit, size: 20),
                SizedBox(width: 8),
                Text('Edit Request'),
              ],
            ),
          ),
        ];
        if (hasInterceptor) {
          items.add(
            PopupMenuItem(
              value: _ActionType.modifyResponse,
              child: Row(
                children: const [
                  Icon(Icons.edit_note, size: 20),
                  SizedBox(width: 8),
                  Text('Intercept Response'),
                ],
              ),
            ),
          );
        }
        items.add(
          PopupMenuItem(
            value: _ActionType.copyCurl,
            child: Row(
              children: const [
                Icon(Icons.terminal, size: 20),
                SizedBox(width: 8),
                Text('Copy cURL'),
              ],
            ),
          ),
        );
        return items;
      },
    );
  }
}
