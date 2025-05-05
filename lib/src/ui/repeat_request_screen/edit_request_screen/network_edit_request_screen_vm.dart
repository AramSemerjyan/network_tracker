import '../../../model/network_request.dart';
import '../../../services/network_request_service.dart';

class NetworkRequestEditScreenVM {
  final repeatService = NetworkRequestService.instance.repeatRequestService;

  void send(NetworkRequest request) {
    repeatService.repeat(request);
  }
}
