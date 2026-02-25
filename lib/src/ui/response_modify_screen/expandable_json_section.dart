import 'package:flutter/material.dart';

import 'json_preview_tile.dart';

/// A section widget that displays a JSON preview and an editor, expandable/collapsible.
///
/// Used for editing and previewing JSON data in a form-like UI.
class ExpandableJsonSection extends StatelessWidget {
  /// The title of the section.
  final String title;

  /// The maximum height for the JSON preview/editor area.
  final double maxHeight;

  /// Callback when the add button is pressed.
  final VoidCallback onAdd;

  /// The JSON data to preview.
  final dynamic jsonView;

  /// The editor widget for editing the JSON data.
  final Widget editor;

  /// Creates a [ExpandableJsonSection] instance.
  const ExpandableJsonSection({
    super.key,
    required this.title,
    required this.maxHeight,
    required this.onAdd,
    required this.jsonView,
    required this.editor,
  });

  /// Builds the expandable section with a preview and editor for JSON data.
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
