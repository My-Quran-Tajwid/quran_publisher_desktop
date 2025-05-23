import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'database/mydb.dart';
import 'utils/runtime_font_loader.dart';
import 'views/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  MyDb.instance.init();

  // Load both fonts on app startup, in case user doesn't have font installed
  _loadHafsOriginalFonts();
  _loadHafsColouredFonts();

  // Load QCF4_QBSML
  RuntimeFontLoader.loadFont(
      assetPath:
          'fonts/quran-fonts/fonts/King Fahd Complex/Original/QCF4_QBSML.ttf',
      fontFamily: 'QCF4_QBSML');

  runApp(const MyApp());
}

Future<void> _loadHafsOriginalFonts() async {
  log('Start loading hafs original fonts');
  for (var i = 1; i <= 47; i++) {
    final index = i.toString().padLeft(2, '0');
    await RuntimeFontLoader.loadFont(
      assetPath:
          'fonts/quran-fonts/fonts/King Fahd Complex/Original/Hafs-QCF4/QCF4_Hafs_${index}_W.ttf',
      fontFamily: 'QCF4_Hafs_${index}_W',
    );
  }
  log('Finish loading hafs original fonts');
}

Future<void> _loadHafsColouredFonts() async {
  log('Start loading hafs color fonts');
  // TODO: Update the limit number when new fonts is added
  for (var i = 1; i <= 47; i++) {
    final index = i.toString().padLeft(2, '0');
    try {
      await RuntimeFontLoader.loadFont(
        assetPath:
            'fonts/quran-fonts/fonts/King Fahd Complex/Hafs-QCF4-Colors/QCF4_Hafs_${index}_W_COLOR-Regular.ttf',
        fontFamily: 'QCF4_Hafs_${index}_W_COLOR',
      );
    } catch (e) {
      // Errors are expected because not all fonts are available yet
      log('Failed to load hafs color font for index $index');
    }
  }
  log('Finish loading hafs color fonts');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quran Publisher',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        textTheme: GoogleFonts.spaceGroteskTextTheme(),
      ),
      home: const HomePage(),
    );
  }
}
