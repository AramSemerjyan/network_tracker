import 'dart:async';

import 'package:flutter/material.dart';

/// Animated text label used while an operation is in progress.
class LoadingLabel extends StatefulWidget {
  /// Prefix text shown before animated dots.
  final String title;

  /// Creates a [LoadingLabel] instance.
  const LoadingLabel({super.key, this.title = 'Running'});

  @override
  State<LoadingLabel> createState() => _LoadingLabelState();
}

class _LoadingLabelState extends State<LoadingLabel> {
  int _dotCount = 1;
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        _dotCount = _dotCount % 3 + 1; // Cycle from 1 to 3
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text('${widget.title}${'.' * _dotCount}');
  }
}
