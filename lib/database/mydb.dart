import 'dart:developer';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

import 'app_database.dart';

/// Access a singleton instance of the app database
/// Always use this class than directly referencing to [AppDatabase]
/// Example:
/// ```dart
/// final db = MyDb.instance.database;
/// db.getSurahTranslations();
/// ```
///
class MyDb {
  static final MyDb _db = MyDb._internal();
  MyDb._internal();
  static MyDb get instance => _db;
  static AppDatabase? _database;

  void init() {
    _database = AppDatabase(openConnection());
  }

  AppDatabase get database {
    if (_database == null) {
      throw "Database is not init. Please use MyDb.init() before calling getting database";
    }

    return _database!;
  }

  LazyDatabase openConnection() {
    // the LazyDatabase util lets us find the right location for the file async.
    return LazyDatabase(() async {
      // put the database file, called db.sqlite here, into the documents folder
      // for your app.
      final dbFolder = await getApplicationSupportDirectory();
      final file = File(p.join(dbFolder.path, 'mydb.db'));

      log('DB is stored in ${file.path}');

      // Extract the pre-populated database file from assets
      // NOTE: Don't check for !await file.exists(), because then the db will not
      // get updated when the app is updated. Until we found a better solution,
      // this will work.
      final blob = await rootBundle.load('assets/database/mydb.sqlite');
      final buffer = blob.buffer;
      await file.writeAsBytes(
          buffer.asUint8List(blob.offsetInBytes, blob.lengthInBytes));

      // Also work around limitations on old Android versions
      if (Platform.isAndroid) {
        await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
      }

      // Make sqlite3 pick a more suitable location for temporary files - the
      // one from the system may be inaccessible due to sandboxing.
      final cachebase = (await getTemporaryDirectory()).path;
      // We can't access /tmp on Android, which sqlite3 would try by default.
      // Explicitly tell it about the correct temporary directory.
      sqlite3.tempDirectory = cachebase;

      return NativeDatabase.createInBackground(file);
    });
  }
}
