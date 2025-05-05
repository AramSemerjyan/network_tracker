import 'package:network_tracker/src/model/network_request.dart';
import 'package:network_tracker/src/utils/utils.dart';

import '../../services/network_request_service.dart';

class RequestDataDetailsScreenVM {
  final NetworkRequest request;

  final repeatRequestService =
      NetworkRequestService.instance.repeatRequestService;

  RequestDataDetailsScreenVM(this.request);

  void repeatRequest(NetworkRequest request) {
    repeatRequestService.repeat(request);
  }

  Future<String?> exportResponseData() async {
    return (await Utils.exportRequest(request))?.path;
  }
}
