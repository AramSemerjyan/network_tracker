/// Represents the status of a network request during its lifecycle.
enum RequestStatus {
  /// Request is created but not yet sent.
  pending('⏳'),

  /// Request has been sent but not yet completed.
  sent('✉️'),

  /// Request completed successfully and received a valid response.
  completed('✅'),

  /// Request failed with an error or bad response.
  failed('❌'),

  /// Request was cancelled before completion.
  cancelled('🚫');

  /// Emoji symbol associated with the status.
  final String symbol;

  /// Creates a new [RequestStatus] with an associated [symbol].
  const RequestStatus(this.symbol);
}
