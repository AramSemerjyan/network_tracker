import '../../network_tracker.dart';
import '../model/network_request_storage_interface.dart';
import 'event_service.dart';
import 'storage/network_request_local_storage.dart';
import 'storage/persistent/network_request_persistent_storage.dart';

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
        final persistentStorage = NetworkRequestPersistentStorage();
        persistentStorage.initDb();
        _storageService = persistentStorage;
    }
  }
}
