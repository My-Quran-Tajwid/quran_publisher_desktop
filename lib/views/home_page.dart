import 'package:bidi/bidi.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/mydb.dart';
import '../model/manuscript_string.dart';
import '../model/quran_enums.dart';
import '../providers/quran_selection_provider.dart';
import 'components/app_title_widget.dart';
import 'components/control_panel.dart';
import 'components/mushaf_page_view.dart';

/// Returns the font family name, appending `_COLOR` when tajwid colouring is
/// enabled. Fonts without a coloured version (e.g. QCF4_QBSML) are returned
/// unchanged.
String _getFontFamily(String fontName, TajwidOptions tajwidOptions) {
  if (!fontName.startsWith('QCF4_Hafs')) return fontName;
  if (tajwidOptions != TajwidOptions.tajwidKdn) return fontName;
  return '${fontName}_COLOR';
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final previewType = ref.watch(previewTypeProvider);

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: AppTitleWidget(),
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(child: const ControlPanel()),
                  ),
                  if (previewType == PreviewType.mushafPage)
                    const Expanded(child: MushafPageView())
                  else
                    const Expanded(child: _QuranTextPreview()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuranTextPreview extends ConsumerWidget {
  const _QuranTextPreview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fromSurah = ref.watch(fromSurahProvider);
    final fromAyat = ref.watch(fromAyatProvider);
    final toSurah = ref.watch(toSurahProvider);
    final toAyat = ref.watch(toAyatProvider);
    final previewFontSize = ref.watch(previewFontSizeProvider);
    final previewSpacing = ref.watch(previewSpacingProvider);
    final tajwidOption = ref.watch(tajwidOptionProvider);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: FutureBuilder(
            future: MyDb.instance.database.getManuscriptString(
              surahStart: fromSurah,
              ayatStart: fromAyat,
              surahEnd: toSurah,
              ayatEnd: toAyat,
            ),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              }

              if (!snapshot.hasData) {
                return const LinearProgressIndicator();
              }

              // Group text by font name, then build a widget per group
              final groupedByFontName =
                  groupBy(snapshot.data!, (ManuscriptString ms) => ms.fontName);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ...groupedByFontName.entries.map(
                    (e) => Builder(
                      builder: (context) {
                        final sb = StringBuffer();
                        for (var element in e.value) {
                          sb.write(element.text);
                        }
                        final fontFamily = _getFontFamily(e.key, tajwidOption);

                        // Use bidi to ensure text is laid out correctly
                        // (setting RTL alone is not enough)
                        final bidiText = BidiString.fromLogical(sb.toString());

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              fontFamily,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black26,
                              ),
                            ),
                            ...bidiText.paragraphs.map(
                              (p) => Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Wrap(
                                  runSpacing: 8,
                                  spacing: previewSpacing,
                                  children: p.bidiText
                                      .map(
                                        (e) => Tooltip(
                                          message: e.toString(),
                                          child: InkWell(
                                            onTap: () {
                                              Clipboard.setData(ClipboardData(
                                                text: String.fromCharCode(e),
                                              ));
                                            },
                                            child: Text(
                                              String.fromCharCode(e),
                                              style: TextStyle(
                                                fontFamily: fontFamily,
                                                fontSize: previewFontSize,
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
    );
  }
}
