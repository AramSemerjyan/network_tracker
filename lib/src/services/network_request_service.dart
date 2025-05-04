import 'package:network_tracker/src/services/network_repeat_request_service.dart';

import '../model/network_request_storage_interface.dart';
import 'network_request_storage.dart';

class NetworkRequestService {
  NetworkRequestStorageInterface storage = NetworkRequestStorage();
  late final NetworkRepeatRequestService repeatRequestService =
      NetworkRepeatRequestService();

  static NetworkRequestService? _instance;

  static NetworkRequestService get instance {
    return _instance ??= NetworkRequestService();
  }

  void setStorage(NetworkRequestStorageInterface storage) {
    this.storage = storage;
  }
}
