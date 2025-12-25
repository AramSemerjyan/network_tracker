/// Represents a downloadable file used for internet speed testing.
///
/// Each [SpeedTestFile] includes a [name] for display purposes and a [urlString]
/// pointing to a test file hosted online.
///
/// Use predefined factories like [SpeedTestFile.pdf100Mb] or [SpeedTestFile.zip70Mb]
/// to get commonly used test files with known sizes.
enum SpeedTestFile {
  /// Returns a test file representing a 50MB ZIP archive.
  zip50(
    name: 'Zip 50Mb',
    urlString: 'http://ipv4.download.thinkbroadband.com/50MB.zip',
  ),

  /// Returns a test file representing a 100MB ZIP archive.
  zip100(
    name: 'Zip 100Mb',
    urlString: 'http://ipv4.download.thinkbroadband.com/100MB.zip',
  ),

  /// Returns a test file representing a 200MB ZIP archive.
  zip200(
    name: 'Zip 200Mb',
    urlString: 'http://ipv4.download.thinkbroadband.com/200MB.zip',
  ),

  /// Returns a test file representing a 512MB ZIP archive.
  zip512(
    name: 'Zip 512Mb',
    urlString: 'http://ipv4.download.thinkbroadband.com/512MB.zip',
  );

  /// Display name of the test file (e.g. "PDF 100Mb").
  final String name;

  /// Direct URL to the downloadable test file.
  final String urlString;

  /// Creates a [SpeedTestFile] with the given [name] and [urlString].
  const SpeedTestFile({
    required this.name,
    required this.urlString,
  });
}
