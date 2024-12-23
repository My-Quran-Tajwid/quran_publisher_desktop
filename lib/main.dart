import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'database/mydb.dart';
import 'utils/runtime_font_loader.dart';
import 'views/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  MyDb.instance.init();

  _loadHafsOriginalFonts();
  _loadHafsColouredFonts();

  runApp(const MyApp());
}

Future<void> _loadHafsOriginalFonts() async {
  log('Start loading hafs original fonts');
  for (var i = 1; i <= 47; i++) {
    final index = i.toString().padLeft(2, '0');
    await RuntimeFontLoader.loadFont(
      assetPath: 'fonts/hafs-qcf4/original/QCF4_Hafs_${index}_W.ttf',
      fontFamily: 'QCF4_Hafs_${index}_W',
    );
  }
  log('Finish loading hafs original fonts');
}

Future<void> _loadHafsColouredFonts() async {
  log('Start loading hafs original fonts');
  await RuntimeFontLoader.loadFont(
    assetPath: 'fonts/hafs-qcf4/color/QCF4_Hafs_01_W_COLOR-Regular.ttf',
    fontFamily: 'QCF4_Hafs_01_W_COLOR',
  );
  // for (var i = 1; i <= 47; i++) {
  //   final index = i.toString().padLeft(2, '0');
  //   await RuntimeFontLoader.loadFont(
  //     assetPath: 'fonts/hafs-qcf4/color/QCF4_Hafs_${index}_W.ttf',
  //     fontFamily: 'QCF4_Hafs_${index}_W',
  //   );
  // }
  log('Finish loading hafs original fonts');
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
