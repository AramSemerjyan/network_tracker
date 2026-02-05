import 'package:flutter/material.dart';

import 'json_preview_tile.dart';

class ExpandableJsonSection extends StatelessWidget {
  final String title;
  final double maxHeight;
  final VoidCallback onAdd;
  final dynamic jsonView;
  final Widget editor;

  const ExpandableJsonSection({
    super.key,
    required this.title,
    required this.maxHeight,
    required this.onAdd,
    required this.jsonView,
    required this.editor,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Row(
        children: [
          Text(title),
          const Spacer(),
          IconButton(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            tooltip: 'Add key/value',
          ),
        ],
      ),
      childrenPadding: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: SingleChildScrollView(
            child: Column(
              children: [
                JsonPreviewTile(jsonView: jsonView),
                const SizedBox(height: 8),
                editor,
              ],
            ),
          ),
        ),
      ],
    );
  }
}