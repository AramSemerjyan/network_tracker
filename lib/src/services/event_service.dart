import 'dart:async';

/// Publishes internal events emitted by network-tracker flows.
class EventService {
  /// Emits after a repeat/edit request has been sent.
  final onRepeatRequestDone = StreamController<void>.broadcast();
}
