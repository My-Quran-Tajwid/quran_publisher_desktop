import 'package:flutter/services.dart';

class RuntimeFontLoader {
  /// Cache to store loaded font families
  static final Map<String, FontLoader> _fontLoaderCache = {};

  /// Load and register a font from assets at runtime
  /// Returns the font family name that can be used in TextStyle
  static Future<String> loadFont({
    required String assetPath,
    String? fontFamily,
  }) async {
    try {
      // Use asset path as font family name if not provided
      fontFamily ??= assetPath.split('/').last.replaceAll('.ttf', '');

      // Check if font is already loaded
      if (_fontLoaderCache.containsKey(fontFamily)) {
        return fontFamily;
      }

      // Load font file from assets
      final ByteData fontData = await rootBundle.load(assetPath);

      // Create FontLoader instance
      final FontLoader loader = FontLoader(fontFamily)
        ..addFont(Future.value(fontData));

      // Load the font
      await loader.load();

      // Cache the loader
      _fontLoaderCache[fontFamily] = loader;

      return fontFamily;
    } catch (e) {
      throw Exception('Failed to load font: $e');
    }
  }

  /// Clear cached font loaders
  static void clearCache() {
    _fontLoaderCache.clear();
  }
}
