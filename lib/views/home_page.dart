import 'package:bidi/bidi.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:toastification/toastification.dart';

import '../database/app_database.dart';
import '../database/mydb.dart';
import '../model/manuscript_string.dart';
import 'components/app_title_widget.dart';
import 'components/kalimah_preview_widget.dart';
import 'components/mushaf_page_view.dart';
import 'components/preview_control_card.dart';

enum TajwidOptions {
  noTajwid('No Tajwid'),
  tajwidKdn('With Tajwid (KDN)');

  final String label;
  const TajwidOptions(this.label);
}

enum PreviewType {
  justText('Text'),
  mushafPage('Mushaf Page');

  final String label;
  const PreviewType(this.label);
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<SurahItem>> _surahListFuture;
  late TextEditingController _fromAyatController;
  late TextEditingController _toAyatController;

  // TODO: Default to Tajwid KDN after the fonts is ready
  TajwidOptions _selectedTajwidOption = TajwidOptions.noTajwid;

  // Set default to surah al fatihah
  int fromSurah = 1;
  int fromAyat = 1;
  int toSurah = 1;
  int toAyat = 7;

  // TODO: Rethink about the use of font size, seems betters to use TextScaling.
  // We may use this if we starte support RichText copy/paste
  double _previewFontSize = 28;
  double _previewSpacing = 1;
  PreviewType _previewType = PreviewType.justText;

  @override
  void initState() {
    super.initState();

    _surahListFuture = MyDb.instance.database.getAllSurah();
    _fromAyatController = TextEditingController(text: fromAyat.toString());
    _toAyatController = TextEditingController(text: toAyat.toString());
  }

  Future<int?> _getTotalAyatInSurah(int surahNumber) async {
    final db = MyDb.instance.database;
    return await db.getTotalAyatInSurah(surahNumber);
  }

  /// Get the font family name based on the tajwid options
  String _getFontFamily(String fontName, TajwidOptions tajwidOptions) {
    // Skip other font that doesn't have coloured version eg QCF4_QBSML
    if (!fontName.startsWith('QCF4_Hafs')) {
      return fontName;
    }

    // For normal font (without color), use the original font name
    if (tajwidOptions != TajwidOptions.tajwidKdn) {
      return fontName;
    }

    // Add suffix _COLOR to the font name for colored version
    return '${fontName}_COLOR';
  }

  void _setFromSurah(newFromSurah) async {
    if (newFromSurah == null) return;
    if (newFromSurah == fromSurah) return;
    if (newFromSurah > toSurah) {
      setState(() => toSurah = newFromSurah);
    }

    // Sets the value
    setState(() => fromSurah = newFromSurah);

    // Update its ayat number value. If the max ayat in the surah is less than the current fromAyat, set it to max ayat
    // in the surah
    final totalAyat = await _getTotalAyatInSurah(fromSurah);
    if (totalAyat != null && fromAyat > totalAyat) {
      setState(() => fromAyat = totalAyat);
      _fromAyatController.text = totalAyat.toString();
    }
  }

  void _setFromAyat(String value, int forSurahNumber) async {
    if (value.isEmpty) return;
    final newfromAyat = int.tryParse(value);
    if (newfromAyat == null) return;
    if (newfromAyat == fromAyat) return;

    // Check if the new fromAyat is greater than the total ayat in the surah
    final totalAyat = await _getTotalAyatInSurah(forSurahNumber);
    if (totalAyat != null && newfromAyat > totalAyat) {
      setState(() => fromAyat = totalAyat);
      _fromAyatController.text = totalAyat.toString();
      return;
    } else {
      // Sets the value
      setState(() => fromAyat = newfromAyat);
    }

    // If both surah are the same, ensure that toAyat is not less than newfromAyat
    if (fromSurah == toSurah && newfromAyat > toAyat) {
      setState(() => toAyat = newfromAyat);
      _toAyatController.text = toAyat.toString();
    }
  }

  void _setToAyat(String value, int forSurahNumber) async {
    if (value.isEmpty) return;
    final newToAyat = int.tryParse(value);
    if (newToAyat == null) return;
    if (newToAyat == toAyat) return;

    // Check if the new toAyat is greater than the total ayat in the surah
    final totalAyat = await _getTotalAyatInSurah(forSurahNumber);
    if (totalAyat != null && newToAyat > totalAyat) {
      setState(() => toAyat = totalAyat);
      _toAyatController.text = totalAyat.toString();
    } else {
      // Sets the value
      setState(() => toAyat = newToAyat);
    }

    // If both surah are the same, ensure that toAyat is not less than newfromAyat
    if (fromSurah == toSurah && toAyat < fromAyat) {
      setState(() => fromAyat = toAyat);
      _fromAyatController.text = fromAyat.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const AppTitleWidget(),
                    const Gap(24),
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
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 16),
                              ),
                              const Gap(24),
                              const Text('Tajwid Option:'),
                              const Gap(4),
                              DropdownButton(
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
                                onChanged: (TajwidOptions? value) {
                                  if (value == null) return;
                                  setState(() {
                                    _selectedTajwidOption = value;
                                  });
                                },
                                value: _selectedTajwidOption,
                              )
                            ],
                          ),
                          // TODO: Remove this warning after the fonts is ready
                          if (_selectedTajwidOption == TajwidOptions.tajwidKdn)
                            const Text(
                              'Warning: Tajwid font is experimental and in early stage of development. You might encounter missing glyphs.',
                              style: TextStyle(
                                color: Colors.deepOrange,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const Gap(12),
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

                                    return DropdownButtonFormField(
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
                                                  '${surah.surahNo}. ${surah.namaEnglish} - ${surah.namaArab}'))
                                      ],
                                      onChanged: (value) async =>
                                          _setFromSurah(value),
                                      value: fromSurah,
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
                                          _setFromAyat(_fromAyatController.text,
                                              fromSurah);
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
                                        onFieldSubmitted: (value) async =>
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
                                  tajwidOption: _selectedTajwidOption,
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

                                    return DropdownButtonFormField(
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
                                                  '${surah.surahNo}. ${surah.namaEnglish} - ${surah.namaArab}'))
                                      ],
                                      onChanged: (value) {
                                        if (value == null) return;
                                        if (value == toSurah) return;
                                        setState(() {
                                          toSurah = value;
                                        });
                                      },
                                      value: toSurah,
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
                                          _setToAyat(
                                              _toAyatController.text, toSurah);
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
                                        onFieldSubmitted: (value) async =>
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
                                  tajwidOption: _selectedTajwidOption,
                                  kalimahPreview: KalimahPreview.showLast,
                                ),
                              ),
                            ],
                          ),
                          const Gap(12),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  final db = MyDb.instance.database;

                                  final result = await db.getManuscriptString(
                                      surahStart: fromSurah,
                                      ayatStart: fromAyat,
                                      surahEnd: toSurah,
                                      ayatEnd: toAyat);

                                  final sb = StringBuffer();
                                  for (var element in result) {
                                    sb.write(element.text);
                                  }

                                  // Added RIGHT-TO-LEFT OVERRIDE (RLO) to ensure pasted text will start at the right
                                  // Here is the difference with & without RLO https://imgur.com/a/pQi21dy
                                  // Still need to set alignment RTL in ms word, but at least the text will not inverted
                                  // Added space so that the text would wrap to a new line
                                  final data =
                                      '\u202E${sb.toString().replaceAll('', ' ')}';

                                  await Clipboard.setData(
                                    ClipboardData(text: data),
                                  );

                                  toastification.show(
                                    context: context,
                                    type: ToastificationType.success,
                                    style: ToastificationStyle.flat,
                                    title: const Text("Ayat range copied"),
                                    alignment: Alignment.bottomLeft,
                                    autoCloseDuration:
                                        const Duration(seconds: 2),
                                    pauseOnHover: false,
                                    applyBlurEffect: true,
                                  );
                                },
                                child: const Text('Copy'),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    const Gap(12),
                    PreviewControlCard(
                      onFontSizeChanged: (fontSize) {
                        setState(() {
                          _previewFontSize = fontSize;
                        });
                      },
                      onSpacingChanged: (spacing) {
                        setState(() {
                          _previewSpacing = spacing;
                        });
                      },
                      previewType: _previewType,
                      onPreviewTypeChanged: (previewType) {
                        setState(() {
                          _previewType = previewType;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            if (_previewType == PreviewType.mushafPage)
              Expanded(
                  child: MushafPageView(
                tajwidOption: _selectedTajwidOption,
              ))
            else
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: FutureBuilder(
                        future: MyDb.instance.database.getManuscriptString(
                            surahStart: fromSurah,
                            ayatStart: fromAyat,
                            surahEnd: toSurah,
                            ayatEnd: toAyat),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Text(snapshot.error.toString());
                          }

                          if (!snapshot.hasData) {
                            return const LinearProgressIndicator();
                          }

                          // First, group the text according to the font name, then
                          // build a widget for each font name. After that, baru
                          // layout untuk the text itself
                          final groupedByFontName = groupBy(snapshot.data!,
                              (ManuscriptString ms) => ms.fontName);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ...groupedByFontName.entries.map(
                                (e) => Builder(
                                  builder: (context) {
                                    final StringBuffer sb = StringBuffer();
                                    for (var element in e.value) {
                                      sb.write(element.text);
                                    }
                                    final fontFamily = _getFontFamily(
                                        e.key, _selectedTajwidOption);

                                    // Use bidi to make sure text are lay out correctly (setting
                                    // up just RTL are not enough)
                                    final bidiText =
                                        BidiString.fromLogical(sb.toString());

                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Text(
                                          fontFamily,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black26),
                                        ),
                                        ...bidiText.paragraphs.map(
                                          (p) => Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Wrap(
                                              runSpacing: 8,
                                              spacing: _previewSpacing,
                                              children: p.bidiText
                                                  .map(
                                                    (e) => Tooltip(
                                                      message: e.toString(),
                                                      child: InkWell(
                                                        onTap: () {
                                                          Clipboard.setData(
                                                            ClipboardData(
                                                              text: String
                                                                  .fromCharCode(
                                                                      e),
                                                            ),
                                                          );
                                                        },
                                                        child: Text(
                                                          String.fromCharCode(
                                                              e),
                                                          style: TextStyle(
                                                            fontFamily:
                                                                fontFamily,
                                                            fontSize:
                                                                _previewFontSize,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                  .toList(),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
