import 'package:flutter/material.dart';
import 'package:network_tracker/src/model/network_request.dart';
import 'package:network_tracker/src/ui/common/repeat_request_button_vm.dart';

import '../repeat_request_screen/edit_request_screen/network_edit_request_screen.dart';

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

  void _moveToEdit(NetworkRequest request) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NetworkEditRequestScreen(originalRequest: request),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _moveToEdit(widget.request),
      child: IconButton(
        icon: const Icon(Icons.send),
        onPressed: () {
          if (widget.shouldEditFirst) {
            _moveToEdit(widget.request);
          } else {
            _vm.repeat(widget.request);
          }
        },
      ),
    );
  }
}
