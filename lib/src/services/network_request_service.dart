import 'package:network_tracker/src/services/network_request_storage.dart';

class NetworkRequestService {
  NetworkRequestStorageInterface storage = NetworkRequestStorage();

  static NetworkRequestService? _instance;

  static NetworkRequestService get instance {
    return _instance ??= NetworkRequestService();
  }

  void setStorage(NetworkRequestStorageInterface storage) {
    this.storage = storage;
  }
}
