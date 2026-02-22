import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../model/quran_enums.dart';
import '../../providers/quran_selection_provider.dart';

class PreviewControlCard extends ConsumerStatefulWidget {
  const PreviewControlCard({super.key});

  @override
  ConsumerState<PreviewControlCard> createState() => _PreviewControlCardState();
}

class _PreviewControlCardState extends ConsumerState<PreviewControlCard> {
  final TextEditingController fontSizeController = TextEditingController();
  final TextEditingController spacingValueController = TextEditingController();
  double? selectedFontSize;

  @override
  Widget build(BuildContext context) {
    final previewType = ref.watch(previewTypeProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Preview Settings',
              style: Theme.of(context).textTheme.titleMedium),
          const Gap(12),
          Row(
            children: [
              const Text('Preview Type:'),
              const Gap(4),
              DropdownButton<PreviewType>(
                items: PreviewType.values
                    .map((previewType) => DropdownMenuItem(
                          value: previewType,
                          child: Text(previewType.label),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  ref.read(previewTypeProvider.notifier).value = value;
                },
                value: previewType,
              ),
            ],
          ),
          const Gap(12),
          Row(
            children: [
              DropdownMenu<double>(
                initialSelection: 28.0,
                controller: fontSizeController,
                label: const Text('Font Size'),
                onSelected: (double? newValue) {
                  if (newValue == null) return;
                  setState(() {
                    selectedFontSize = newValue;
                  });
                  ref.read(previewFontSizeProvider.notifier).value = newValue;
                },
                dropdownMenuEntries: [
                  24.0,
                  28.0,
                  32.0,
                  36.0,
                  40.0,
                  44.0,
                  48.0,
                  52.0,
                  68.0,
                  72.0,
                  78.0
                ].map<DropdownMenuEntry<double>>((double fontSize) {
                  return DropdownMenuEntry<double>(
                    value: fontSize,
                    label: fontSize.toStringAsFixed(0),
                  );
                }).toList(),
              ),
              const Gap(8),
              DropdownMenu<double>(
                initialSelection: 1.0,
                controller: spacingValueController,
                label: const Text('Spacing'),
                onSelected: (double? newValue) {
                  if (newValue == null) return;
                  setState(() {
                    selectedFontSize = newValue;
                  });
                  ref.read(previewSpacingProvider.notifier).value = newValue;
                },
                dropdownMenuEntries: [
                  1.0,
                  2.0,
                  3.0,
                  4.0,
                  5.0,
                  6.0,
                  7.0,
                  8.0,
                  10.0,
                  12.0,
                  14.0,
                  16.0,
                  18.0,
                  20.0
                ].map<DropdownMenuEntry<double>>((double spacing) {
                  return DropdownMenuEntry<double>(
                    value: spacing,
                    label: spacing.toStringAsFixed(0),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
