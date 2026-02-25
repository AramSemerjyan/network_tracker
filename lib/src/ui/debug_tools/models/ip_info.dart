/// Combined local/external IP information used by debug tools.
class NetworkInfo {
  /// External IP API payload (ISP, country, region, etc.).
  final Map<String, dynamic>? externalInfo;

  /// Local device IP on the active network.
  final String? localIP;

  /// Creates a [NetworkInfo] instance.
  NetworkInfo({
    this.externalInfo,
    this.localIP,
  });
}
