import 'package:flutter/cupertino.dart';
import 'package:network_tracker/network_tracker.dart';
import 'package:network_tracker/src/services/speed_test/network_speed_test_service.dart';

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

class DebugToolsScreenVM {
  final NetworkSpeedTestServiceInterface _speedTestService =
      NetworkRequestService.instance.networkSpeedTestService;
  ValueNotifier<SpeedTestState> speedTestState =
      ValueNotifier(SpeedTestState());

  String get testFileName => _speedTestService.testFile.name;

  void testSpeed() async {
    speedTestState.value =
        SpeedTestState(progressState: SpeedTestProgressState.inProgress);

    final result = await _speedTestService.testDownloadSpeed();

    speedTestState.value = SpeedTestState(
      progressState: SpeedTestProgressState.completed,
      result: result,
    );
  }
}
