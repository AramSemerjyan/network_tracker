import 'package:flutter/material.dart';

import 'network_modify_response_screen.dart';
import 'reponse_preset.dart';

class ExpandablePresetsSection extends StatefulWidget {
  final ValueNotifier<List<ResponsePreset>> availablePresets;
  final void Function(ResponsePreset) onSelect;
  const ExpandablePresetsSection({
    super.key,
    required this.availablePresets,
    required this.onSelect,
  });

  @override
  State<ExpandablePresetsSection> createState() =>
      ExpandablePresetsSectionState();
}

class ExpandablePresetsSectionState extends State<ExpandablePresetsSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<ResponsePreset>>(
      valueListenable: widget.availablePresets,
      builder: (context, availablePresets, _) {
        final statusPresets = availablePresets
            .where((p) => p.group == PresetGroupType.status)
            .toList();
        final customPresets = availablePresets
            .where((p) => p.group == PresetGroupType.custom)
            .toList();
        return ExpansionTile(
          title:
              Text('Presets', style: Theme.of(context).textTheme.titleMedium),
          initiallyExpanded: false,
          onExpansionChanged: (v) => setState(() => _expanded = v),
          childrenPadding: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
          children: [
            if (statusPresets.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Status codes',
                    style: Theme.of(context).textTheme.bodySmall,
                  )
                ],
              ),
              SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: statusPresets.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final preset = statusPresets[i];
                    return ActionChip(
                      label: Text(preset.label),
                      onPressed: () => widget.onSelect(preset),
                      disabledColor: Colors.grey.shade300,
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
            if (customPresets.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 2),
                child: Text('Custom',
                    style: Theme.of(context).textTheme.bodySmall),
              ),
              SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: customPresets.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final preset = customPresets[i];
                    return ActionChip(
                      label: Text(preset.label),
                      onPressed: () => widget.onSelect(preset),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ],
        );
      },
    );
  }
}
