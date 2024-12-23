import 'package:flutter/material.dart';

import '../../database/mydb.dart';
import '../home_page.dart';

/// Which one to show in an ayat, first one or last one.
enum KalimahPreview { showFirst, showLast }

/// Preview single kalimah from given ayat
class KalimahPreviewWidget extends StatelessWidget {
  const KalimahPreviewWidget({
    super.key,
    required this.surahNumber,
    required this.ayatNumber,
    required this.tajwidOption,
    this.kalimahPreview = KalimahPreview.showFirst,
  });

  final int surahNumber;
  final int ayatNumber;
  final TajwidOptions tajwidOption;
  final KalimahPreview? kalimahPreview;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white70,
      ),
      height: 45,
      child: FutureBuilder(
        future: MyDb.instance.database.getCodePointsForAyat(
            surahNumber: surahNumber, ayatNumber: ayatNumber),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }

          if (!snapshot.hasData) {
            return const LinearProgressIndicator();
          }

          final text = kalimahPreview == KalimahPreview.showFirst
              ? snapshot.data!.$1.first
              : snapshot.data!.$1.last;

          return Center(
            child: Text(
              String.fromCharCode(text),
              style: TextStyle(
                fontFamily: tajwidOption == TajwidOptions.tajwidKdn
                    ? '${snapshot.data!.$2}_COLOR'
                    : snapshot.data!.$2,
                fontSize: 24,
              ),
              textAlign: TextAlign.center,
            ),
          );
        },
      ),
    );
  }
}
