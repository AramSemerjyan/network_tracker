import 'package:flutter/cupertino.dart';
import 'package:network_tracker/network_tracker.dart';
import 'package:network_tracker/src/services/shared_prefs/shared_prefs_service.dart';
import 'package:network_tracker/src/services/speed_test/network_speed_test_service.dart';
import 'package:network_tracker/src/ui/debug_tools/models/speed_throttle.dart';

import 'models/speed_test_state.dart';

class DebugToolsScreenVM {
  late final NetworkSpeedTestServiceInterface _speedTestService =
      NetworkRequestService.instance.networkSpeedTestService;
  late final SharedPrefsService _sharedPrefsService = SharedPrefsService();

  ValueNotifier<SpeedTestState> speedTestState =
      ValueNotifier(SpeedTestState());
  ValueNotifier<SpeedThrottle> selectedThrottle =
      ValueNotifier(SpeedThrottle.unlimited());

  List<SpeedThrottle> get throttleOptions => SpeedThrottle.allCases();
  String get testFileName => _speedTestService.testFile.name;
  bool get hasClient =>
      NetworkRequestService.instance.repeatRequestService.clients.isNotEmpty;

  DebugToolsScreenVM() {
    _sharedPrefsService.loadThrottle().then((value) {
      if (value != null) {
        selectedThrottle.value = value;
      }
    });
  }

  void testSpeed() async {
    speedTestState.value =
        SpeedTestState(progressState: SpeedTestProgressState.inProgress);

    final result = await _speedTestService.testDownloadSpeed();

    speedTestState.value = SpeedTestState(
      progressState: SpeedTestProgressState.completed,
      result: result,
    );
  }

  void selectThrottle(SpeedThrottle throttle) async {
    selectedThrottle.value = throttle;

    await _sharedPrefsService.setThrottle(throttle);

    // for (final dio
    //     in NetworkRequestService.instance.repeatRequestService.clients.values) {
    //   dio.interceptors.removeWhere((i) => i is NetworkThrottleInterceptor);
    //   final limit = throttle.value;
    //
    //   if (limit != null) {
    //     dio.interceptors.insert(0, NetworkThrottleInterceptor(limit));
    //   }
    // }
  }
}
