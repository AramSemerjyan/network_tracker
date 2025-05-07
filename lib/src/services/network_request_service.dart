import 'package:network_tracker/src/services/event_service.dart';
import 'package:network_tracker/src/services/network_request_Persistent_storage.dart';

import '../../network_tracker.dart';
import '../model/network_request_storage_interface.dart';
import 'storage/network_request_local_storage.dart';

class NetworkRequestService {
  late final NetworkRepeatRequestService repeatRequestService =
      NetworkRepeatRequestService.instance;
  late final EventService eventService = EventService();

  NetworkRequestStorageInterface get storageService => _storageService;

  NetworkRequestStorageInterface _storageService = NetworkRequestLocalStorage();

  static NetworkRequestService? _instance;

  static NetworkRequestService get instance {
    return _instance ??= NetworkRequestService();
  }

  void setStorage(NetworkRequestStorageInterface storage) {
    _storageService = storage;
  }

  void setStorageType(StorageType type) {
    switch (type) {
      case StorageType.local:
        _storageService = NetworkRequestLocalStorage();
      case StorageType.persistent:
        _storageService = NetworkRequestPersistentStorage();
    }
  }
}
