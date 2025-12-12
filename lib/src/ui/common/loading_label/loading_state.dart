enum LoadingProgressState {
  idle,
  inProgress,
  inProgressStoppable,
  completed,
  error,
}

class LoadingState<T> {
  final LoadingProgressState loadingProgress;
  final T? result;
  final Object? error;
  final StackTrace? stackTrace;

  LoadingState({
    this.loadingProgress = LoadingProgressState.idle,
    this.result,
    this.error,
    this.stackTrace,
  });
}
