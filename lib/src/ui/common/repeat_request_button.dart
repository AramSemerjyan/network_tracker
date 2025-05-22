import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../model/network_request.dart';
import '../repeat_request_screen/edit_request_screen/network_edit_request_screen.dart';
import 'repeat_request_button_vm.dart';

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

  void _copyCURL() {
    final curl = widget.request.toCurl();
    Clipboard.setData(ClipboardData(text: curl));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied cURL to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onLongPress: _moveToEdit,
          child: IconButton(
            icon: const Icon(Icons.repeat),
            onPressed: () {
              if (widget.shouldEditFirst) {
                _moveToEdit();
              } else {
                _vm.repeat(widget.request);
              }
            },
          ),
        ),
        IconButton(
          icon: const Icon(Icons.terminal),
          onPressed: _copyCURL,
        ),
      ],
    );
  }
}
