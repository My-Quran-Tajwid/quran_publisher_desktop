import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../database/mydb.dart';
import '../../model/manuscript_string.dart';
import '../home_page.dart';

/// Display Quran by page as per physical mushaf
class MushafPageView extends StatefulWidget {
  const MushafPageView({super.key, required this.tajwidOption});

  final TajwidOptions tajwidOption;

  @override
  State<MushafPageView> createState() => _MushafPageViewState();
}

class _MushafPageViewState extends State<MushafPageView> {
  final db = MyDb.instance.database;
  final FocusNode focusNode = FocusNode();
  late final TextEditingController pageController;

  int currentPage = 1;

  void _updatePage(int page) {
    if (page < 1 || page > 604) {
      return;
    }

    // if same page, do nothing
    if (currentPage == page) {
      return;
    }

    setState(() {
      currentPage = page;
    });

    pageController.text = currentPage.toString();
  }

  @override
  void initState() {
    super.initState();

    pageController = TextEditingController(text: currentPage.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9FAFF),
      body: Column(
        children: [
          Container(
            width: 618,
            height: 837,
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage('assets/images/Quran-Frame.png'),
                fit: BoxFit.contain,
              ),
              border: Border(
                  left: BorderSide(color: Colors.grey.shade300, width: 0.5)),
            ),
            child: Column(
              children: [
                // Header
                SizedBox(
                  height: 65,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 70),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'J1',
                          style: const TextStyle(
                              inherit: false,
                              fontFamily: 'QCF4_Surah_Juzuk_Mudah',
                              fontSize: 40,
                              color: Colors.black),
                        ),
                        Text(
                          's2',
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
                // Top gap
                const Gap(40),
                // Body
                Row(
                  children: [
                    // Left gap
                    const Gap(90),
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: FutureBuilder<List<ManuscriptString>>(
                          future: db.getManuscriptStringByPage(currentPage),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (snapshot.hasError) {
                              return Center(
                                child: Text('Error: ${snapshot.error}'),
                              );
                            }
                            final quranText = snapshot.data!;
                            return Expanded(
                              child: Text.rich(
                                TextSpan(
                                  // the magic sauce; the RTL overrides
                                  // See https://unicode-explorer.com/c/202E
                                  text: '\u202e',
                                  style: const TextStyle(color: Colors.black),
                                  children: <InlineSpan>[
                                    for (var i = 0; i < quranText.length; i++)
                                      TextSpan(
                                        text: quranText[i].text,
                                        style: TextStyle(
                                          fontFamily: widget.tajwidOption ==
                                                  TajwidOptions.tajwidKdn
                                              ? '${quranText[i].fontName}_COLOR'
                                              : quranText[i].fontName,
                                          fontSize: 25.4,
                                          height: 1.8,
                                          color: Colors.black,
                                        ),
                                      ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }),
                    ),
                    // Right gap
                    const Gap(100),
                  ],
                ),
                // bottom gap
                Gap(10),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                TextButton.icon(
                  onPressed: () {
                    _updatePage(currentPage - 1);
                  },
                  icon: const Icon(Icons.navigate_before_outlined),
                  label: const Text('Previous Page'),
                ),
                Spacer(),
                // The page number input
                SizedBox(
                  width: 90,
                  child: Focus(
                    onFocusChange: (hasFocus) {
                      if (!hasFocus) {
                        _updatePage(int.parse(pageController.text));
                      }
                    },
                    child: TextFormField(
                      controller: pageController,
                      focusNode: focusNode,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter page';
                        }
                        final page = int.tryParse(value);
                        if (page == null || page < 1 || page > 604) {
                          return 'Invalid';
                        }
                        return null;
                      },
                      autovalidateMode: AutovalidateMode.always,
                      textAlign: TextAlign.center,
                      maxLength: 3,
                      decoration: const InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 8,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onEditingComplete: () {
                        _updatePage(int.parse(pageController.text));
                        focusNode.unfocus();
                      },
                    ),
                  ),
                ),
                Spacer(),
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: TextButton.icon(
                    onPressed: () {
                      _updatePage(currentPage + 1);
                    },
                    // The directionality widget will mirror the icon, so we used
                    // the 'before' icon despite it supposed to be 'next'
                    icon: const Icon(Icons.navigate_before_outlined),
                    label: const Text('Next Page'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
