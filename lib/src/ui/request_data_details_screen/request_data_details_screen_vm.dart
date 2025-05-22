import 'package:network_tracker/src/model/network_request.dart';
import 'package:network_tracker/src/utils/utils.dart';

import '../../services/network_request_service.dart';

class RequestDataDetailsScreenVM {
  final NetworkRequest request;

  final repeatRequestService =
      NetworkRequestService.instance.repeatRequestService;

  RequestDataDetailsScreenVM(this.request);

  Future<void> shareRequest() async {
    Utils.shareFile(request.responseData, fileName: request.name);
  }
}
