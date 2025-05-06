import 'package:network_tracker/src/services/event_service.dart';
import 'package:network_tracker/src/services/network_repeat_request_service.dart';

import '../model/network_request_storage_interface.dart';
import 'network_request_storage.dart';

class NetworkRequestService {
  NetworkRequestStorageInterface storageService = NetworkRequestStorage();
  late final NetworkRepeatRequestService repeatRequestService =
      NetworkRepeatRequestService.instance;
  late final EventService eventService = EventService();

  static NetworkRequestService? _instance;

  static NetworkRequestService get instance {
    return _instance ??= NetworkRequestService();
  }

  void setStorage(NetworkRequestStorageInterface storage) {
    storageService = storage;
  }
}
