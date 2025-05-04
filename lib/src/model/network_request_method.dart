/// Represents standard HTTP request methods.
enum NetworkRequestMethod {
  get("GET"),
  post("POST"),
  put("PUT"),
  delete("DELETE"),
  patch("PATCH"),
  head("HEAD"),
  options("OPTIONS");

  /// The string representation of the HTTP method.
  final String value;

  const NetworkRequestMethod(this.value);

  /// Returns the [HttpMethod] enum matching the provided [value] string (case-insensitive).
  ///
  /// Throws a [FormatException] if the method is not found.
  static NetworkRequestMethod fromString(String value) {
    return NetworkRequestMethod.values.firstWhere(
      (e) => e.value.toUpperCase() == value.toUpperCase(),
      orElse: () => throw FormatException('Invalid HTTP method: $value'),
    );
  }
}
