import 'package:flutter/material.dart';

class FilterCard<T> extends StatelessWidget {
  final String title;
  final T? value;
  final List<T> options;
  final String Function(T) getLabel;
  final ValueChanged<T?> onChanged;

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

    return Card(
      color:
          isSelected ? scheme.primaryContainer : scheme.surfaceContainerHighest,
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
                      color: isSelected
                          ? scheme.onPrimaryContainer
                          : scheme.onSurface,
                    ),
                  ),
                  Text(
                    value != null ? getLabel(value as T) : 'Any',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? scheme.onPrimaryContainer
                          : scheme.onSurface,
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 4),
              InkWell(
                onTap: () => onChanged(null),
                borderRadius: BorderRadius.circular(20),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.clear, size: 18),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
