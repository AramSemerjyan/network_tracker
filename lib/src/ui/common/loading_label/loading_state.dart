/// LoadingProgressState values.
enum LoadingProgressState {
  /// No work is currently running.
  idle,

  /// A non-cancelable operation is running.
  inProgress,

  /// A cancelable operation is running.
  inProgressStoppable,

  /// Operation finished successfully.
  completed,

  /// Operation failed.
  error,
}

/// Generic container describing operation progress, result, and error.
class LoadingState<T> {
  /// Current loading phase.
  final LoadingProgressState loadingProgress;

  /// Optional successful result payload.
  final T? result;

  /// Optional error object when [loadingProgress] is [LoadingProgressState.error].
  final Object? error;

  /// Optional stack trace associated with [error].
  final StackTrace? stackTrace;

  /// Creates a [LoadingState] instance.
  LoadingState({
    this.loadingProgress = LoadingProgressState.idle,
    this.result,
    this.error,
    this.stackTrace,
  });
}
