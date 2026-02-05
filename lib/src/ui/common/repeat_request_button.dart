import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

class RepeatRequestButton extends StatefulWidget {
  final bool shouldEditFirst;
  final NetworkRequest request;

  const RepeatRequestButton({
    super.key,
    required this.request,
    this.shouldEditFirst = false,
  });

  @override
  State<RepeatRequestButton> createState() => _RepeatRequestButtonState();
}

class _RepeatRequestButtonState extends State<RepeatRequestButton> {
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

  void _moveToModifyResponse() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            NetworkModifyResponseScreen(originalRequest: widget.request),
      ),
    );
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
    return PopupMenuButton<_ActionType>(
      icon: Container(
        padding: const EdgeInsets.all(12), // Increase tap area
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.more_vert, size: 28),
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
      itemBuilder: (context) => [
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
        PopupMenuItem(
          value: _ActionType.modifyResponse,
          child: Row(
            children: const [
              Icon(Icons.edit_note, size: 20),
              SizedBox(width: 8),
              Text('Modify Response'),
            ],
          ),
        ),
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
      ],
    );
  }
}
