import 'package:flutter/cupertino.dart';
import 'package:network_tracker/network_tracker.dart';
import 'package:network_tracker/src/services/network_info_service.dart';
import 'package:network_tracker/src/services/speed_test/network_speed_test_service.dart';
import 'package:network_tracker/src/ui/common/loading_label/loading_state.dart';
import 'package:network_tracker/src/utils/utils.dart';

class DebugToolsScreenVM {
  late final NetworkSpeedTestServiceInterface _speedTestService =
      NetworkRequestService.instance.networkSpeedTestService;
  late final NetworkInfoServiceInterface _ipInfoService = NetworkInfoService();

  ValueNotifier<LoadingState<String?>> speedTestState =
      ValueNotifier(LoadingState());
  ValueNotifier<LoadingState<Map<String, dynamic>?>> networkInfoState =
      ValueNotifier(LoadingState());

  String get testFileName => _speedTestService.testFile.name;

  void testSpeed() async {
    speedTestState.value =
        LoadingState(loadingProgress: LoadingProgressState.inProgress);

    final result = await _speedTestService.testDownloadSpeed();

    speedTestState.value = LoadingState(
      loadingProgress: LoadingProgressState.completed,
      result: result,
    );
  }

  Future<String?> fetchExternalIp() async {
    networkInfoState.value =
        LoadingState(loadingProgress: LoadingProgressState.inProgress);

    final networkInfo = await _ipInfoService.fetchExternalInfo();
    final localIP = await _ipInfoService.fetchLocalIP();
    networkInfo?['local_ip'] = localIP;

    networkInfoState.value = LoadingState(
      loadingProgress: LoadingProgressState.completed,
      result: networkInfo,
    );
  }

  void shareNetworkInfo() {
    final networkInfo = networkInfoState.value.result;

    if (networkInfo != null) {
      Utils.shareFile(networkInfo, fileName: 'network_info_${DateTime.now()}');
    }
  }
}
