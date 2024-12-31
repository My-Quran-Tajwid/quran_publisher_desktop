import 'package:bidi/bidi.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../home_page.dart';

class MushafPageView extends StatelessWidget {
  const MushafPageView({super.key, required this.tajwidOption});

  final TajwidOptions tajwidOption;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildQuranPage('J1', 's2',
          '                                                                                                                                         '),
    );
  }

  Widget buildQuranPage(String juzuk, String surah, String text) {
    final bidiText = BidiString.fromLogical(text.replaceAll(' ', ''));
    return Container(
      width: 618,
      height: 837,
      decoration: BoxDecoration(
        color: const Color(0xFFE9FAFF),
        image: const DecorationImage(
          image: AssetImage('assets/images/Quran-Frame.png'),
          fit: BoxFit.contain,
        ),
        border:
            Border(left: BorderSide(color: Colors.grey.shade300, width: 0.5)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            height: 65,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 70),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    juzuk,
                    style: const TextStyle(
                        inherit: false,
                        fontFamily: 'QCF4_Surah_Juzuk_Mudah',
                        fontSize: 40,
                        color: Colors.black),
                  ),
                  Text(
                    surah,
                    style: const TextStyle(
                        inherit: false,
                        fontFamily: 'QCF4_Surah_Juzuk_Mudah',
                        fontSize: 40,
                        color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
          Gap(50),
          // Body
          Row(
            children: [
              const Gap(90),
              Directionality(
                textDirection: TextDirection.rtl,
                child: Expanded(
                  // child: Text(
                  //   text,
                  //   textAlign: TextAlign.center,
                  //   style: TextStyle(
                  //     fontFamily: 'QCF4_Hafs_01_W_COLOR',
                  //     fontSize: 25.4,
                  //     height: 1.8,
                  //   ),
                  // ),
                  child: Wrap(
                    runSpacing: 9,
                    alignment: WrapAlignment.center,
                    spacing: 1,
                    children: bidiText.paragraphs.first.bidiText
                        .map(
                          (e) => Text(
                            String.fromCharCode(e),
                            style: TextStyle(
                              fontFamily:
                                  tajwidOption == TajwidOptions.tajwidKdn
                                      ? 'QCF4_Hafs_01_W_COLOR'
                                      : 'QCF4_Hafs_01_W',
                              fontSize: 25.4,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
              const Gap(90),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
