import 'package:flutter/material.dart';
import 'package:json_view/json_view.dart';

/// A widget that displays a preview of JSON data in an expandable tile.
///
/// Uses the [json_view] package to render JSON objects and arrays.
class JsonPreviewTile extends StatelessWidget {
  /// The JSON data to preview.
  final dynamic jsonView;

  /// Creates a [JsonPreviewTile].
  const JsonPreviewTile({super.key, required this.jsonView});

  /// Builds the expandable preview for the provided JSON data.
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