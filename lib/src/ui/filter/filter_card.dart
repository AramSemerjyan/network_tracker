import 'package:flutter/material.dart';
import 'package:network_tracker/src/ui/common/readable_theme_colors.dart';

/// Reusable compact dropdown card used by request filters.
class FilterCard<T> extends StatelessWidget {
  /// Label shown before the selected value.
  final String title;

  /// Currently selected value. `null` means "Any".
  final T? value;

  /// Available options shown in the popup menu.
  final List<T> options;

  /// Converts an option into display text.
  final String Function(T) getLabel;

  /// Called when a new option (or clear) is selected.
  final ValueChanged<T?> onChanged;

  /// Creates a [FilterCard] instance.
  const FilterCard({
    super.key,
    required this.title,
    required this.value,
    required this.options,
    required this.getLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value != null;
    final scheme = Theme.of(context).colorScheme;
    final cardColor =
        isSelected ? scheme.primaryContainer : scheme.surfaceContainerHighest;
    final textColor = ReadableThemeColors.resolveForeground(context, cardColor);

    return Card(
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
              onTap: () async {
                final renderBox = context.findRenderObject() as RenderBox;
                final overlay =
                    Overlay.of(context).context.findRenderObject() as RenderBox;
                final position =
                    renderBox.localToGlobal(Offset.zero, ancestor: overlay);
                final size = renderBox.size;

                final selected = await showMenu<T>(
                  context: context,
                  position: RelativeRect.fromLTRB(
                    position.dx,
                    position.dy + size.height,
                    position.dx + size.width,
                    position.dy,
                  ),
                  items: options
                      .map((e) => PopupMenuItem<T>(
                            value: e,
                            child: Text(getLabel(e)),
                          ))
                      .toList(),
                );
                if (selected != null) {
                  onChanged(selected);
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$title: ',
                    style: TextStyle(
                      color: textColor,
                    ),
                  ),
                  Text(
                    value != null ? getLabel(value as T) : 'Any',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Icon(Icons.arrow_drop_down, color: textColor),
                ],
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 4),
              InkWell(
                onTap: () => onChanged(null),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.clear,
                    size: 18,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
