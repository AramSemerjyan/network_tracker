/// Represents a downloadable file used for internet speed testing.
///
/// Each [SpeedTestFile] includes a [name] for display purposes and a [urlString]
/// pointing to a test file hosted online.
///
/// Use predefined factories like [SpeedTestFile.pdf100Mb] or [SpeedTestFile.zip70Mb]
/// to get commonly used test files with known sizes.
class SpeedTestFile {
  /// Display name of the test file (e.g. "PDF 100Mb").
  final String name;

  /// Direct URL to the downloadable test file.
  final String urlString;

  /// Creates a [SpeedTestFile] with the given [name] and [urlString].
  const SpeedTestFile({
    required this.name,
    required this.urlString,
  });

  /// Returns a test file representing a 250MB ZIP archive.
  factory SpeedTestFile.zip250Mb() {
    return SpeedTestFile(
      name: 'Zip 250Mb',
      urlString: 'https://link.testfile.org/250MB',
    );
  }

  /// Returns a test file representing a 100MB PDF.
  factory SpeedTestFile.pdf100Mb() {
    return SpeedTestFile(
      name: 'PDF 100Mb',
      urlString: 'https://link.testfile.org/PDF100MB',
    );
  }

  /// Returns a test file representing a 70MB ZIP archive.
  factory SpeedTestFile.zip70Mb() {
    return SpeedTestFile(
      name: 'Zip 70Mb',
      urlString: 'https://link.testfile.org/70MB',
    );
  }

  /// Returns a test file representing a 30MB ZIP archive.
  factory SpeedTestFile.zip30Mb() {
    return SpeedTestFile(
      name: 'Zip 30Mb',
      urlString: 'https://link.testfile.org/30MB',
    );
  }

  static List<SpeedTestFile> all() => [
        SpeedTestFile.zip30Mb(),
        SpeedTestFile.zip70Mb(),
        SpeedTestFile.pdf100Mb(),
        SpeedTestFile.zip250Mb(),
      ];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpeedTestFile &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          urlString == other.urlString;

  @override
  int get hashCode => name.hashCode ^ urlString.hashCode;
}
