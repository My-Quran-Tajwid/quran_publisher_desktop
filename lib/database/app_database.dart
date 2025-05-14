import 'package:drift/drift.dart';

import '../model/manuscript_string.dart';
import 'db_tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  HafsSuraItems,
  HafsWordItems,
  SurahItems,
  JuzukItems,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.queryExecutor);

  @override
  int get schemaVersion => 1;

  /// Get list of surah
  Future<List<SurahItem>> getAllSurah() => select(surahItems).get();

  Future<int?> getTotalAyatInSurah(int surahNumber) async {
    final surahItem = await (select(surahItems)
          ..where((tbl) => tbl.surahNo.equals(surahNumber)))
        .getSingleOrNull();

    return surahItem?.bilanganAyat;
  }

  /// Retrieves the first [JuzukItem] whose page number by the given
  /// [pageNumber].
  Future<JuzukItem> getJuzukForPage(int pageNumber) async {
    final juzs = await (select(juzukItems)
          ..orderBy([
            (t) => OrderingTerm(expression: t.page, mode: OrderingMode.desc)
          ])
          ..where((tbl) => tbl.page.isSmallerOrEqualValue(pageNumber)))
        .get();

    return juzs.first;
  }

  Future<(List<int> codePoints, String fontName)> getCodePointsForAyat({
    required int surahNumber,
    required int ayatNumber,
  }) async {
    final rows = await (select(hafsWordItems)
          ..where((tbl) =>
              tbl.surah.equals(surahNumber) & tbl.verse.equals(ayatNumber)))
        .get();

    final codePoints = <int>[];

    for (final row in rows) {
      codePoints.add(row.fontCode);
    }

    return (codePoints, rows.first.fontName);
  }

  /// Retrieves manuscript strings from the database for a specified range of verses.
  ///
  /// Fetches Quranic text with font information for the given surah and ayat range.
  ///
  /// Parameters:
  /// - [surahStart]: The starting surah number (must be positive)
  /// - [ayatStart]: The starting ayat (verse) number (must be positive)
  /// - [surahEnd]: Optional ending surah number. If not provided, defaults to [surahStart]
  /// - [ayatEnd]: Optional ending ayat number. If not provided, defaults to [ayatStart]
  ///
  /// Returns a [Future<List<ManuscriptString>>] containing the manuscript strings for
  /// each verse in the specified range, with appropriate font and text information.
  ///
  /// The verses are returned in order by surah, ayat, and word number.
  ///
  /// Throws [ArgumentError] if:
  /// - Surah or ayat numbers are less than 1
  /// - The ending range comes before the starting range
  Future<List<ManuscriptString>> getManuscriptString({
    required int surahStart,
    required int ayatStart,
    int? surahEnd,
    int? ayatEnd,
  }) async {
    // Validate input parameters
    if (surahStart < 1 || ayatStart < 1) {
      throw ArgumentError('Surah and Ayat numbers must be positive');
    }

    // If end parameters are not provided, set them equal to start parameters
    surahEnd ??= surahStart;
    ayatEnd ??= ayatStart;

    // Validate range
    if (surahEnd < surahStart ||
        (surahEnd == surahStart && ayatEnd < ayatStart)) {
      throw ArgumentError('End range cannot be before start range');
    }

    // Query using Drift
    final rows = await (select(hafsWordItems)
          ..where((tbl) {
            // Case 1: Start and end are in the same surah
            if (surahStart == surahEnd) {
              return tbl.surah.equals(surahStart) &
                  tbl.verse.isBiggerOrEqualValue(ayatStart) &
                  tbl.verse.isSmallerOrEqualValue(ayatEnd!);
            }

            // Case 2: Start and end are in different surahs
            return (
                // First surah: from ayatStart to end of surah
                (tbl.surah.equals(surahStart) &
                        tbl.verse.isBiggerOrEqualValue(ayatStart)) |
                    // Middle surahs: all ayats
                    (tbl.surah.isBiggerThanValue(surahStart) &
                        tbl.surah.isSmallerThanValue(surahEnd!)) |
                    // Last surah: from beginning to ayatEnd
                    (tbl.surah.equals(surahEnd) &
                        tbl.verse.isSmallerOrEqualValue(ayatEnd!)));
          })
          ..orderBy([
            (tbl) => OrderingTerm(expression: tbl.surah),
            (tbl) => OrderingTerm(expression: tbl.verse),
            (tbl) => OrderingTerm(expression: tbl.wordNum),
          ]))
        .get();

    String currentKey = '';
    String currentFontName = '';
    List<int> fontCodePoints = [];
    Map<String, ManuscriptString> result = {};

    for (var row in rows) {
      String key = '${row.surah}:${row.verse}';

      // Make the key unique for QCF4_QBSML font
      if (row.fontName == 'QCF4_QBSML') key += ':b';

      // If we've moved to a new verse, save the previous one
      if (currentKey != '' && currentKey != key) {
        result[currentKey] = ManuscriptString(
          text: String.fromCharCodes(fontCodePoints),
          fontName: currentFontName,
        );
        fontCodePoints.clear();
      }

      // Update current key and font name
      currentKey = key;
      currentFontName = row.fontName;

      fontCodePoints.add(row.fontCode);
    }

    // Don't forget to add the last verse
    if (currentKey != '') {
      result[currentKey] = ManuscriptString(
        text: String.fromCharCodes(fontCodePoints),
        fontName: currentFontName,
      );
    }

    return result.values.toList();
  }

  /// Retrieves manuscript strings for all verses on a specified page.
  ///
  /// Fetches Quranic text with font information for every verse present on the given page number.
  ///
  /// Parameters:
  /// - [pageNumber]: The page number to retrieve verses for.
  ///
  /// Returns a [Future<List<ManuscriptString>>] containing the manuscript strings for
  /// each verse on the specified page, with appropriate font and text information.
  Future<List<ManuscriptString>> getManuscriptStringByPage(
      int pageNumber) async {
    // Query using Drift
    final rows = await (select(hafsWordItems)
          ..where((tbl) {
            return tbl.pageNo.equals(pageNumber);
          }))
        .get();

    String currentKey = '';
    String currentFontName = '';
    List<int> fontCodePoints = [];
    Map<String, ManuscriptString> result = {};

    for (var row in rows) {
      String key = '${row.surah}:${row.verse}';

      // Make the key unique for QCF4_QBSML font
      if (row.fontName == 'QCF4_QBSML') key += ':b';

      // If we've moved to a new verse, save the previous one
      if (currentKey != '' && currentKey != key) {
        result[currentKey] = ManuscriptString(
          text: String.fromCharCodes(fontCodePoints),
          fontName: currentFontName,
        );
        fontCodePoints.clear();
      }

      // Update current key and font name
      currentKey = key;
      currentFontName = row.fontName;

      fontCodePoints.add(row.fontCode);
    }

    // Don't forget to add the last verse
    if (currentKey != '') {
      result[currentKey] = ManuscriptString(
        text: String.fromCharCodes(fontCodePoints),
        fontName: currentFontName,
      );
    }

    return result.values.toList();
  }
}
