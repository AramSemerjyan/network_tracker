import 'package:flutter/material.dart';
import 'package:json_view/json_view.dart';

class JsonPreviewTile extends StatelessWidget {
  final dynamic jsonView;

  const JsonPreviewTile({super.key, required this.jsonView});

  @override
  Widget build(BuildContext context) {
    final canRenderJson = jsonView is Map || jsonView is List;

    return ExpansionTile(
      title: const Text('Preview JSON'),
      initiallyExpanded: false,
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 8),
      children: [
        if (canRenderJson)
          JsonView(
            json: jsonView,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
          )
        else
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Not a JSON object'),
          ),
      ],
    );
  }
}