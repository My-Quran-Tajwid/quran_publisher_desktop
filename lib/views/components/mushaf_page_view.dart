import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../database/app_database.dart';
import '../../database/mydb.dart';
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

  /// Minimum dimensions required for proper rendering of the Mushaf page view.
  /// These values (850x620) are based on the physical layout and design constraints
  /// to ensure all elements fit and display correctly.
  static const int minMushafPageHeight = 850;
  static const int minMushafPageWidth = 620;

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
      body: Stack(
        children: [
          Column(
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
                      left:
                          BorderSide(color: Colors.grey.shade300, width: 0.5)),
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
                            FutureBuilder<JuzukItem>(
                                future: db.getJuzukForPage(currentPage),
                                builder: (context, snapshot) {
                                  return Text(
                                    snapshot.hasData
                                        ? 'J${snapshot.data!.juzuk}'
                                        : '...',
                                    style: const TextStyle(
                                        inherit: false,
                                        fontFamily: 'QCF4_Surah_Juzuk_Mudah',
                                        fontSize: 40,
                                        color: Colors.black),
                                  );
                                }),
                            FutureBuilder<SurahItem>(
                                future: db.getSurahForPage(currentPage),
                                builder: (context, snapshot) {
                                  return Text(
                                    snapshot.hasData
                                        ? 's${snapshot.data!.surahNo}'
                                        : '...',
                                    style: const TextStyle(
                                        inherit: false,
                                        fontFamily: 'QCF4_Surah_Juzuk_Mudah',
                                        fontSize: 40,
                                        color: Colors.black),
                                  );
                                }),
                          ],
                        ),
                      ),
                    ),
                    // Top gap
                    const Gap(32),
                    // Body
                    Row(
                      children: [
                        // Left gap
                        const Gap(94.5),
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: FutureBuilder<List<HafsWordItem>>(
                              future: db.getQuranTextByPage(currentPage),
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
                                      style:
                                          const TextStyle(color: Colors.black),

                                      children: <InlineSpan>[
                                        for (var i = 0;
                                            i < quranText.length;
                                            i++)
                                          if (quranText[i].type == 5)
                                            WidgetSpan(
                                                child: Container(
                                              alignment: Alignment.center,
                                              height: 45,
                                              width: 430,
                                              decoration: BoxDecoration(
                                                color: Color(0xff6e87cd)
                                                    .withValues(alpha: .2),
                                                border: Border.all(
                                                  color: Color(0xff6e87cd),
                                                  width: 3,
                                                ),
                                              ),
                                              child: Text(
                                                String.fromCharCode(
                                                    quranText[i].fontCode),
                                                style: TextStyle(
                                                  fontFamily:
                                                      quranText[i].fontName,
                                                  fontSize: 22.4,
                                                  height: 1.8,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ))
                                          else if (quranText[i].type == 4)
                                            WidgetSpan(
                                              child: SizedBox(
                                                width: double.infinity,
                                                child: Text(
                                                  String.fromCharCode(
                                                      quranText[i].fontCode),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontFamily: widget
                                                                .tajwidOption ==
                                                            TajwidOptions
                                                                .tajwidKdn
                                                        ? '${quranText[i].fontName}_COLOR'
                                                        : quranText[i].fontName,
                                                    fontSize: 25.4,
                                                    height: 1.8,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                            )
                                          else
                                            TextSpan(
                                              text: String.fromCharCode(
                                                  quranText[i].fontCode),
                                              style: TextStyle(
                                                fontFamily: widget
                                                            .tajwidOption ==
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
                                    textHeightBehavior: TextHeightBehavior(
                                      // this will shift the text slighly below. So TopGap can be
                                      // harmonize with this one.
                                      applyHeightToFirstAscent: false,
                                    ),
                                  ),
                                );
                              }),
                        ),
                        // Right gap
                        const Gap(94.5),
                      ],
                    ),
                    // bottom gap
                    Gap(10),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      style: IconButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: currentPage == 604
                          ? null
                          : () {
                              _updatePage(604);
                            },
                      tooltip: 'Go to last page',
                      icon: const Icon(Icons.skip_previous_outlined),
                    ),
                    TextButton.icon(
                      onPressed: currentPage == 604
                          ? null
                          : () {
                              _updatePage(currentPage + 1);
                            },
                      icon: const Icon(
                        Icons.navigate_before_outlined,
                        size: 24,
                      ),
                      label: const Text('Next Page'),
                    ),
                    const Spacer(),
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
                        onPressed: currentPage == 1
                            ? null
                            : () {
                                _updatePage(currentPage - 1);
                              },
                        // The directionality widget will mirror the icon, so we used
                        // the 'before' icon despite it supposed to be 'next'
                        icon: const Icon(
                          Icons.navigate_before_outlined,
                          size: 24,
                        ),
                        label: const Text('Previous Page'),
                      ),
                    ),
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: IconButton(
                        style: IconButton.styleFrom(
                          foregroundColor:
                              Theme.of(context).colorScheme.primary,
                        ),
                        onPressed: currentPage == 1
                            ? null
                            : () {
                                _updatePage(1);
                              },
                        tooltip: 'Go to first page',
                        icon: const Icon(Icons.skip_next_outlined),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Show warning when not enough space to render page
          LayoutBuilder(builder: (context, constraints) {
            if (constraints.maxWidth < minMushafPageWidth ||
                constraints.maxHeight < minMushafPageHeight) {
              return Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: Colors.yellow.withAlpha(40),
                ),
                child: Center(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Mushaf page view requires more space to render correctly. Please resize this window to make it bigger, or use the Text mode instead.',
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          }),
        ],
      ),
    );
  }
}
