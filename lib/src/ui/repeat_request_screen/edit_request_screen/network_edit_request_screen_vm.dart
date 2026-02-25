import '../../../model/network_request.dart';
import '../../../services/network_request_service.dart';

/// View model for sending edited request payloads.
class NetworkRequestEditScreenVM {
  /// Service used to replay edited requests.
  final repeatService = NetworkRequestService.instance.repeatRequestService;

  /// Sends the edited [request].
  void send(NetworkRequest request) {
    repeatService.repeat(request);
  }
}
