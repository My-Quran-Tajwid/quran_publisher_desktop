/// The tajwid options enum.
enum TajwidOptions {
  noTajwid('No Tajwid'),
  tajwidKdn('With Tajwid (KDN)');

  final String label;
  const TajwidOptions(this.label);
}

/// The mushaf preview type enum.
enum PreviewType {
  justText('Text'),
  mushafPage('Mushaf Page');

  final String label;
  const PreviewType(this.label);
}
