import 'package:drift/drift.dart';

// Scheme adapted from Quran Mushaf Publisher app database structure
class HafsWordItems extends Table {
  @override
  String get tableName => 'Hafs_Word';
  IntColumn get id => integer().autoIncrement().named('ID')();
  IntColumn get surah => integer().named('Sura')();
  IntColumn get verse => integer().named('Verse')();
  IntColumn get pageNo => integer().named('PageNo')();
  IntColumn get lineNo => integer().named('LineNo')();
  IntColumn get wordNum => integer().named('WordNum')();
  TextColumn get wordText => text().named('WordText')();
  TextColumn get fontName => text().named('FontName')();
  IntColumn get fontCode => integer().named('FontCode')();
  IntColumn get type => integer().named('Type')();
  TextColumn get fontUnicode => text().named('FontUniCode')();
}

// Scheme adapted from Quran Mushaf Publisher app database structure
class HafsSuraItems extends Table {
  @override
  String get tableName => 'Hafs_Sura';
  IntColumn get id => integer().autoIncrement().named('ID')();
  TextColumn get name => text().named('Name')();
  TextColumn get place => text().named('Place')();
  IntColumn get verseCount => integer().named('VerseCount')();
  IntColumn get pageNo => integer().named('PageNo')();
}

// From Smart Quran app
class SurahItems extends Table {
  @override
  String get tableName => 'surahs';
  IntColumn get surahNo => integer().named('no_surah')();
  IntColumn get bilanganAyat => integer().named('bilangan_ayat')();
  IntColumn get mukaSurat => integer().named('muka_surat')();
  IntColumn get juzuk => integer().named('juzuk')();
  TextColumn get namaArab => text().named('nama_arab')();
  TextColumn get namaMelayu => text().named('nama_melayu')();
  TextColumn get namaEnglish => text().named('nama_english')();
  TextColumn get maksudMelayu => text().named('maksud_melayu')();
  TextColumn get maksudEnglish => text().named('maksud_english')();
  TextColumn get tempatTurun => text().named('tempat_diturunkan')();
}

// Imported from Smart Quran app
class JuzukItems extends Table {
  @override
  String get tableName => 'JuzList';
  IntColumn get juzuk => integer().named('juz')();
  IntColumn get hizb => integer().named('hizb')();
  IntColumn get fraction => integer().named('fraction')();
  IntColumn get surah => integer().named('surah')();
  IntColumn get ayat => integer().named('verse')();
  IntColumn get page => integer().named('page')();
  TextColumn get verseText => text().named('verse_text')();
}

// Imported from Smart Quran app (pages table)
class PageItems extends Table {
  @override
  String get tableName => 'PagesList';
  IntColumn get page => integer().named('page')();
  IntColumn get surah => integer().named('surah')();
  IntColumn get ayat => integer().named('ayat')();
}
