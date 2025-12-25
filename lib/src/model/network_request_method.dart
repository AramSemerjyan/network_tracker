/// Enumeration of standard HTTP request methods.
///
/// Each method represents a different type of HTTP operation:
/// - **GET**: Retrieve data from a server
/// - **POST**: Submit data to create a new resource
/// - **PUT**: Update/replace an existing resource
/// - **DELETE**: Remove a resource
/// - **PATCH**: Partially modify a resource
/// - **HEAD**: Retrieve headers only (no body)
/// - **OPTIONS**: Query available communication options
///
/// Example usage:
/// ```dart
/// final method = NetworkRequestMethod.get;
/// print(method.value); // "GET"
/// print(method.symbol); // "🔽"
///
/// // Parse from string
/// final parsed = NetworkRequestMethod.fromString('POST');
/// ```
enum NetworkRequestMethod {
  /// HTTP GET method - retrieves data without modifying server state
  get("GET"),

  /// HTTP POST method - creates new resources
  post("POST"),

  /// HTTP PUT method - replaces entire resources
  put("PUT"),

  /// HTTP DELETE method - removes resources
  delete("DELETE"),

  /// HTTP PATCH method - partially updates resources
  patch("PATCH"),

  /// HTTP HEAD method - retrieves headers only
  head("HEAD"),

  /// HTTP OPTIONS method - queries supported methods
  options("OPTIONS");

  /// The uppercase string representation of the HTTP method (e.g., "GET", "POST").
  final String value;

  const NetworkRequestMethod(this.value);

  /// Parses an HTTP method string into a [NetworkRequestMethod] enum value.
  ///
  /// The comparison is case-insensitive, so "get", "GET", and "Get" all
  /// resolve to [NetworkRequestMethod.get].
  ///
  /// Throws a [FormatException] if the provided [value] doesn't match
  /// any known HTTP method.
  ///
  /// Example:
  /// ```dart
  /// final method = NetworkRequestMethod.fromString('post');
  /// print(method); // NetworkRequestMethod.post
  ///
  /// // Throws FormatException
  /// NetworkRequestMethod.fromString('INVALID');
  /// ```
  static NetworkRequestMethod fromString(String value) {
    return NetworkRequestMethod.values.firstWhere(
      (e) => e.value.toUpperCase() == value.toUpperCase(),
      orElse: () => throw FormatException('Invalid HTTP method: $value'),
    );
  }

  /// Returns an emoji symbol representing the HTTP method.
  ///
  /// These symbols provide a visual representation for UI display:
  /// - GET: 🔽 (download/retrieve)
  /// - POST: 🔼 (upload/create)
  /// - PUT: ♻️ (replace/update)
  /// - DELETE: 🗑 (remove)
  /// - PATCH: 🧩 (partial update)
  /// - HEAD: 📌 (metadata only)
  /// - OPTIONS: ⚙️ (configuration)
  String get symbol {
    switch (this) {
      case NetworkRequestMethod.get:
        return "🔽";
      case NetworkRequestMethod.post:
        return "🔼";
      case NetworkRequestMethod.put:
        return "♻️";
      case NetworkRequestMethod.delete:
        return "🗑";
      case NetworkRequestMethod.patch:
        return "🧩";
      case NetworkRequestMethod.head:
        return "📌";
      case NetworkRequestMethod.options:
        return "⚙️";
    }
  }
}
