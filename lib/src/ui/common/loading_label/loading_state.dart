enum LoadingProgressState {
  idle,
  inProgress,
  completed,
}

class LoadingState<T> {
  final LoadingProgressState loadingProgress;
  final T? result;

  LoadingState({
    this.loadingProgress = LoadingProgressState.idle,
    this.result,
  });
}
