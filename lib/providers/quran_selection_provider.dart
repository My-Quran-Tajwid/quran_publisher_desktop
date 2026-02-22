import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/quran_enums.dart';

// ── Tajwid selection ──────────────────────────────────────────────────────────

class TajwidOptionNotifier extends Notifier<TajwidOptions> {
  @override
  TajwidOptions build() => TajwidOptions.noTajwid;

  set value(TajwidOptions v) => state = v;
}

final tajwidOptionProvider =
    NotifierProvider<TajwidOptionNotifier, TajwidOptions>(
  TajwidOptionNotifier.new,
);

// ── Copy range — From ─────────────────────────────────────────────────────────

class FromSurahNotifier extends Notifier<int> {
  @override
  int build() => 1;

  set value(int v) => state = v;
}

class FromAyatNotifier extends Notifier<int> {
  @override
  int build() => 1;

  set value(int v) => state = v;
}

final fromSurahProvider =
    NotifierProvider<FromSurahNotifier, int>(FromSurahNotifier.new);
final fromAyatProvider =
    NotifierProvider<FromAyatNotifier, int>(FromAyatNotifier.new);

// ── Copy range — To ───────────────────────────────────────────────────────────

class ToSurahNotifier extends Notifier<int> {
  @override
  int build() => 1;

  set value(int v) => state = v;
}

class ToAyatNotifier extends Notifier<int> {
  @override
  int build() => 7;

  set value(int v) => state = v;
}

final toSurahProvider =
    NotifierProvider<ToSurahNotifier, int>(ToSurahNotifier.new);
final toAyatProvider =
    NotifierProvider<ToAyatNotifier, int>(ToAyatNotifier.new);

// ── Preview display settings ──────────────────────────────────────────────────

class PreviewFontSizeNotifier extends Notifier<double> {
  @override
  double build() => 28.0;

  set value(double v) => state = v;
}

class PreviewSpacingNotifier extends Notifier<double> {
  @override
  double build() => 1.0;

  set value(double v) => state = v;
}

class PreviewTypeNotifier extends Notifier<PreviewType> {
  @override
  PreviewType build() => PreviewType.justText;

  set value(PreviewType v) => state = v;
}

final previewFontSizeProvider =
    NotifierProvider<PreviewFontSizeNotifier, double>(
  PreviewFontSizeNotifier.new,
);
final previewSpacingProvider = NotifierProvider<PreviewSpacingNotifier, double>(
  PreviewSpacingNotifier.new,
);
final previewTypeProvider = NotifierProvider<PreviewTypeNotifier, PreviewType>(
  PreviewTypeNotifier.new,
);
