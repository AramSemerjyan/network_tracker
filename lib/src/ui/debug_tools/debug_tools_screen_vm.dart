import 'package:flutter/cupertino.dart';
import 'package:network_tracker/network_tracker.dart';
import 'package:network_tracker/src/services/network_external_info_service.dart';
import 'package:network_tracker/src/services/shared_prefs/shared_prefs_service.dart';
import 'package:network_tracker/src/services/speed_test/network_speed_test_service.dart';
import 'package:network_tracker/src/ui/common/loading_label/loading_state.dart';
import 'package:network_tracker/src/ui/debug_tools/models/speed_throttle.dart';

class DebugToolsScreenVM {
  late final NetworkSpeedTestServiceInterface _speedTestService =
      NetworkRequestService.instance.networkSpeedTestService;
  late final SharedPrefsService _sharedPrefsService = SharedPrefsService();
  late final NetworkExternalInfoServiceInterface _externalInfoService =
      NetworkExternalInfoService();

  ValueNotifier<LoadingState<String?>> speedTestState =
      ValueNotifier(LoadingState());
  ValueNotifier<SpeedThrottle> selectedThrottle =
      ValueNotifier(SpeedThrottle.unlimited());
  ValueNotifier<LoadingState<String?>> externalIpState =
      ValueNotifier(LoadingState());

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
        LoadingState(loadingProgress: LoadingProgressState.inProgress);

    final result = await _speedTestService.testDownloadSpeed();

    speedTestState.value = LoadingState(
      loadingProgress: LoadingProgressState.completed,
      result: result,
    );
  }

  void selectThrottle(SpeedThrottle throttle) async {
    selectedThrottle.value = throttle;

    await _sharedPrefsService.setThrottle(throttle);
  }

  Future<String?> fetchExternalIp() async {
    externalIpState.value =
        LoadingState(loadingProgress: LoadingProgressState.inProgress);

    final ip = await _externalInfoService.fetchExternalIp();

    externalIpState.value = LoadingState(
      loadingProgress: LoadingProgressState.completed,
      result: ip,
    );
  }
}
