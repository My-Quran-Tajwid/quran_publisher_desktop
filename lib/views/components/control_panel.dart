import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:toastification/toastification.dart';

import '../../database/app_database.dart';
import '../../database/mydb.dart';
import '../../model/quran_enums.dart';
import '../../providers/quran_selection_provider.dart';
import 'kalimah_preview_widget.dart';
import 'preview_control_card.dart';

/// The control panel widget containing all the settings and options
/// for the mushaf preview and text preview.
class ControlPanel extends ConsumerStatefulWidget {
  const ControlPanel({super.key});

  @override
  ConsumerState<ControlPanel> createState() => _ControlPanelState();
}

class _ControlPanelState extends ConsumerState<ControlPanel> {
  late final Future<List<SurahItem>> _surahListFuture;
  late final TextEditingController _fromAyatController;
  late final TextEditingController _toAyatController;

  @override
  void initState() {
    super.initState();
    _surahListFuture = MyDb.instance.database.getAllSurah();
    _fromAyatController = TextEditingController(
      text: ref.read(fromAyatProvider).toString(),
    );
    _toAyatController = TextEditingController(
      text: ref.read(toAyatProvider).toString(),
    );
  }

  @override
  void dispose() {
    _fromAyatController.dispose();
    _toAyatController.dispose();
    super.dispose();
  }

  Future<int?> _getTotalAyatInSurah(int surahNumber) {
    return MyDb.instance.database.getTotalAyatInSurah(surahNumber);
  }

  void _setFromSurah(int? newFromSurah) async {
    if (newFromSurah == null) return;
    final fromSurah = ref.read(fromSurahProvider);
    final toSurah = ref.read(toSurahProvider);
    if (newFromSurah == fromSurah) return;

    if (newFromSurah > toSurah) {
      ref.read(toSurahProvider.notifier).value = newFromSurah;
    }
    ref.read(fromSurahProvider.notifier).value = newFromSurah;

    final totalAyat = await _getTotalAyatInSurah(newFromSurah);
    final fromAyat = ref.read(fromAyatProvider);
    if (totalAyat != null && fromAyat > totalAyat) {
      ref.read(fromAyatProvider.notifier).value = totalAyat;
      _fromAyatController.text = totalAyat.toString();
    }
  }

  void _setFromAyat(String value, int forSurahNumber) async {
    if (value.isEmpty) return;
    final newFromAyat = int.tryParse(value);
    if (newFromAyat == null) return;
    final fromAyat = ref.read(fromAyatProvider);
    if (newFromAyat == fromAyat) return;

    final totalAyat = await _getTotalAyatInSurah(forSurahNumber);
    if (totalAyat != null && newFromAyat > totalAyat) {
      ref.read(fromAyatProvider.notifier).value = totalAyat;
      _fromAyatController.text = totalAyat.toString();
      return;
    }
    ref.read(fromAyatProvider.notifier).value = newFromAyat;

    final fromSurah = ref.read(fromSurahProvider);
    final toSurah = ref.read(toSurahProvider);
    final toAyat = ref.read(toAyatProvider);
    if (fromSurah == toSurah && newFromAyat > toAyat) {
      ref.read(toAyatProvider.notifier).value = newFromAyat;
      _toAyatController.text = newFromAyat.toString();
    }
  }

  void _setToAyat(String value, int forSurahNumber) async {
    if (value.isEmpty) return;
    final newToAyat = int.tryParse(value);
    if (newToAyat == null) return;
    final toAyat = ref.read(toAyatProvider);
    if (newToAyat == toAyat) return;

    final totalAyat = await _getTotalAyatInSurah(forSurahNumber);
    if (totalAyat != null && newToAyat > totalAyat) {
      ref.read(toAyatProvider.notifier).value = totalAyat;
      _toAyatController.text = totalAyat.toString();
    } else {
      ref.read(toAyatProvider.notifier).value = newToAyat;
    }

    final fromSurah = ref.read(fromSurahProvider);
    final toSurah = ref.read(toSurahProvider);
    final fromAyat = ref.read(fromAyatProvider);
    final updatedToAyat = ref.read(toAyatProvider);
    if (fromSurah == toSurah && updatedToAyat < fromAyat) {
      ref.read(fromAyatProvider.notifier).value = updatedToAyat;
      _fromAyatController.text = updatedToAyat.toString();
    }
  }

  Future<void> _copyToClipboard() async {
    final db = MyDb.instance.database;
    final fromSurah = ref.read(fromSurahProvider);
    final fromAyat = ref.read(fromAyatProvider);
    final toSurah = ref.read(toSurahProvider);
    final toAyat = ref.read(toAyatProvider);

    final result = await db.getManuscriptString(
      surahStart: fromSurah,
      ayatStart: fromAyat,
      surahEnd: toSurah,
      ayatEnd: toAyat,
    );

    final sb = StringBuffer();
    for (var element in result) {
      sb.write(element.text);
    }

    // Added RIGHT-TO-LEFT OVERRIDE (RLO) to ensure pasted text will start at the right
    // See https://imgur.com/a/pQi21dy for the difference with & without RLO
    final data = '\u202E${sb.toString().replaceAll('', ' ')}';
    await Clipboard.setData(ClipboardData(text: data));

    if (!mounted) return;
    toastification.show(
      context: context,
      type: ToastificationType.success,
      style: ToastificationStyle.flat,
      title: const Text('Ayat range copied'),
      alignment: Alignment.bottomLeft,
      autoCloseDuration: const Duration(seconds: 2),
      pauseOnHover: false,
      applyBlurEffect: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tajwidOption = ref.watch(tajwidOptionProvider);
    final fromSurah = ref.watch(fromSurahProvider);
    final fromAyat = ref.watch(fromAyatProvider);
    final toSurah = ref.watch(toSurahProvider);
    final toAyat = ref.watch(toAyatProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // ── Mushaf Settings ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Mushaf Settings',
                    style: Theme.of(context).textTheme.titleMedium),
                const Gap(8),
                Row(
                  children: [
                    const Text('Mushaf:'),
                    const Gap(4),
                    const Text(
                      'Hafs',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    const Gap(24),
                    const Text('Tajwid Option:'),
                    const Gap(4),
                    DropdownButton<TajwidOptions>(
                      items: const [
                        DropdownMenuItem(
                          value: TajwidOptions.noTajwid,
                          child: Text('No Tajwid'),
                        ),
                        DropdownMenuItem(
                          value: TajwidOptions.tajwidKdn,
                          child: Text('With Tajwid (KDN)'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        ref.read(tajwidOptionProvider.notifier).value = value;
                      },
                      value: tajwidOption,
                    ),
                  ],
                ),
                // TODO: Remove this warning after the fonts is ready
                if (tajwidOption == TajwidOptions.tajwidKdn)
                  const Text(
                    'Warning: Tajwid font is experimental and in early stage of development. You might encounter missing glyphs.',
                    style: TextStyle(color: Colors.deepOrange),
                  ),
              ],
            ),
          ),
          const Gap(12),
          // ── Copy Range ───────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Copy Range',
                    style: Theme.of(context).textTheme.titleMedium),
                const Gap(12),
                const Text('From'),
                Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: FutureBuilder(
                        future: _surahListFuture,
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Text(snapshot.error.toString());
                          }
                          if (!snapshot.hasData) {
                            return const LinearProgressIndicator();
                          }
                          return DropdownButtonFormField<int>(
                            isExpanded: true,
                            decoration: const InputDecoration(
                              hintText: 'Surah',
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              for (var surah in snapshot.data!)
                                DropdownMenuItem(
                                  value: surah.surahNo,
                                  child: Text(
                                      '${surah.surahNo}. ${surah.namaEnglish} - ${surah.namaArab}'),
                                ),
                            ],
                            onChanged: (value) => _setFromSurah(value),
                            initialValue: fromSurah,
                          );
                        },
                      ),
                    ),
                    const Gap(8),
                    Expanded(
                      flex: 2,
                      child: FutureBuilder(
                        future: _getTotalAyatInSurah(fromSurah),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Text(snapshot.error.toString());
                          }
                          if (!snapshot.hasData) {
                            return const LinearProgressIndicator();
                          }
                          return Focus(
                            onFocusChange: (hasFocus) {
                              if (!hasFocus) {
                                _setFromAyat(
                                    _fromAyatController.text, fromSurah);
                              }
                            },
                            child: TextFormField(
                              controller: _fromAyatController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                labelText: 'Ayat',
                                hintText: '1 - ${snapshot.data}',
                              ),
                              onFieldSubmitted: (value) =>
                                  _setFromAyat(value, fromSurah),
                            ),
                          );
                        },
                      ),
                    ),
                    const Gap(8),
                    Expanded(
                      flex: 3,
                      child: KalimahPreviewWidget(
                        surahNumber: fromSurah,
                        ayatNumber: fromAyat,
                        kalimahPreview: KalimahPreview.showFirst,
                      ),
                    ),
                  ],
                ),
                const Gap(8),
                const Text('To'),
                Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: FutureBuilder(
                        future: _surahListFuture,
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Text(snapshot.error.toString());
                          }
                          if (!snapshot.hasData) {
                            return const LinearProgressIndicator();
                          }
                          return DropdownButtonFormField<int>(
                            isExpanded: true,
                            decoration: const InputDecoration(
                              hintText: 'Surah',
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              for (var surah in snapshot.data!)
                                DropdownMenuItem(
                                  value: surah.surahNo,
                                  child: Text(
                                      '${surah.surahNo}. ${surah.namaEnglish} - ${surah.namaArab}'),
                                ),
                            ],
                            onChanged: (value) {
                              if (value == null) return;
                              if (value == toSurah) return;
                              ref.read(toSurahProvider.notifier).value = value;
                            },
                            initialValue: toSurah,
                          );
                        },
                      ),
                    ),
                    const Gap(8),
                    Expanded(
                      flex: 2,
                      child: FutureBuilder(
                        future: _getTotalAyatInSurah(toSurah),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Text(snapshot.error.toString());
                          }
                          if (!snapshot.hasData) {
                            return const LinearProgressIndicator();
                          }
                          return Focus(
                            onFocusChange: (hasFocus) {
                              if (!hasFocus) {
                                _setToAyat(_toAyatController.text, toSurah);
                              }
                            },
                            child: TextFormField(
                              controller: _toAyatController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                labelText: 'Ayat',
                                hintText: '1 - ${snapshot.data}',
                              ),
                              onFieldSubmitted: (value) =>
                                  _setToAyat(value, toSurah),
                            ),
                          );
                        },
                      ),
                    ),
                    const Gap(8),
                    Expanded(
                      flex: 3,
                      child: KalimahPreviewWidget(
                        surahNumber: toSurah,
                        ayatNumber: toAyat,
                        kalimahPreview: KalimahPreview.showLast,
                      ),
                    ),
                  ],
                ),
                const Gap(12),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _copyToClipboard,
                      child: const Text('Copy'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Gap(12),
          // ── Preview Settings ─────────────────────────────────────────
          const PreviewControlCard(),
        ],
      ),
    );
  }
}
