enum SpeedTestProgressState {
  idle,
  inProgress,
  completed,
}

class SpeedTestState {
  final SpeedTestProgressState progressState;
  final String? result;

  SpeedTestState({
    this.progressState = SpeedTestProgressState.idle,
    this.result,
  });
}
