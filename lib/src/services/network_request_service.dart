import 'package:dio/dio.dart';
import 'package:network_tracker/src/services/speed_test/network_speed_test_service.dart';

import '../../network_tracker.dart';
import '../model/network_request_method.dart';
import '../model/response_modification.dart';
import '../model/network_request_storage_interface.dart';
import 'event_service.dart';
import 'network_repeat_request_service.dart';
import 'storage/network_request_local_storage.dart';
import 'storage/persistent/network_request_persistent_storage.dart';

/// Central service that manages all network tracking functionality.
///
/// This singleton service provides access to:
/// - Request storage and retrieval
/// - Request replay/repeat functionality
/// - Event notifications for network events
/// - Network speed testing
///
/// Example usage:
/// ```dart
/// // Access the singleton instance
/// final service = NetworkRequestService.instance;
///
/// // Configure persistent storage
/// service.setStorageType(StorageType.persistent);
///
/// // Set a custom Dio client for request repeating
/// service.setDioClient(myCustomDio);
///
/// // Access storage to retrieve requests
/// final requests = await service.storageService.getUrls();
/// ```
class NetworkRequestService {
  /// Service for repeating previously captured network requests.
  ///
  /// Provides functionality to replay HTTP requests with their original
  /// parameters, headers, and body data.
  late final NetworkRepeatRequestService repeatRequestService =
      NetworkRepeatRequestService.instance;

  /// Service for managing network-related events and notifications.
  ///
  /// Publishes events such as request completion, repeat request completion,
  /// and other network tracking lifecycle events.
  late final EventService eventService = EventService();

  /// Service for performing network speed tests.
  ///
  /// Allows measuring download speeds by downloading test files from
  /// known fast servers.
  late final NetworkSpeedTestServiceInterface networkSpeedTestService =
      NetworkSpeedTestService();

  /// Returns the currently active storage service.
  ///
  /// Used to store and retrieve captured network requests. Can be either
  /// in-memory (local) or persistent (database) storage.
  NetworkRequestStorageInterface get storageService => _storageService;

  /// The internal storage implementation currently in use.
  ///
  /// Defaults to [NetworkRequestLocalStorage] which keeps requests in memory.
  /// Can be changed via [setStorage] or [setStorageType].
  NetworkRequestStorageInterface _storageService = NetworkRequestLocalStorage();

  final Map<String, ResponseModification> _responseModifications = {};

  /// Singleton instance holder.
  static NetworkRequestService? _instance;

  /// Returns the singleton instance of [NetworkRequestService].
  ///
  /// Creates a new instance on first access and reuses it on subsequent calls.
  static NetworkRequestService get instance {
    return _instance ??= NetworkRequestService();
  }

  /// Sets a custom storage implementation.
  ///
  /// Allows you to provide your own implementation of [NetworkRequestStorageInterface]
  /// for custom storage behavior (e.g., remote storage, custom database, etc.).
  ///
  /// Example:
  /// ```dart
  /// class MyCustomStorage implements NetworkRequestStorageInterface {
  ///   // ... implementation
  /// }
  ///
  /// NetworkRequestService.instance.setStorage(MyCustomStorage());
  /// ```
  void setStorage(NetworkRequestStorageInterface storage) {
    _storageService = storage;
  }

  /// Sets the storage type using predefined options.
  ///
  /// Available types:
  /// - [StorageType.local]: In-memory storage (default). Requests are lost when the app closes.
  /// - [StorageType.persistent]: SQLite database storage. Requests persist across app restarts.
  ///
  /// When switching to persistent storage, the database is automatically initialized.
  ///
  /// Example:
  /// ```dart
  /// // Switch to persistent storage
  /// NetworkRequestService.instance.setStorageType(StorageType.persistent);
  ///
  /// // Switch back to in-memory storage
  /// NetworkRequestService.instance.setStorageType(StorageType.local);
  /// ```
  void setStorageType(StorageType type) {
    switch (type) {
      case StorageType.local:
        _storageService = NetworkRequestLocalStorage();
        break;
      case StorageType.persistent:
        final persistentStorage = NetworkRequestPersistentStorage();
        persistentStorage.initDb();
        _storageService = persistentStorage;
    }
  }

  /// Registers a custom Dio client for repeating requests.
  ///
  /// The provided [client] will be used when replaying network requests
  /// that match its base URL. This allows you to customize interceptors,
  /// timeouts, authentication, and other Dio configurations for repeated requests.
  ///
  /// Example:
  /// ```dart
  /// final customDio = Dio(BaseOptions(
  ///   baseUrl: 'https://api.example.com',
  ///   headers: {'Authorization': 'Bearer token'},
  ///   connectTimeout: Duration(seconds: 10),
  /// ));
  ///
  /// NetworkRequestService.instance.setDioClient(customDio);
  /// ```
  void setDioClient(Dio client) {
    repeatRequestService.setCustomDio(client);
  }

  void setResponseModification({
    required String baseUrl,
    required String path,
    required NetworkRequestMethod method,
    required ResponseModification modification,
  }) {
    _responseModifications[_modKey(
      baseUrl: baseUrl,
      path: path,
      method: method,
    )] = modification;
  }

  ResponseModification? getResponseModification({
    required String baseUrl,
    required String path,
    required NetworkRequestMethod method,
  }) {
    return _responseModifications[_modKey(
      baseUrl: baseUrl,
      path: path,
      method: method,
    )];
  }

  void clearResponseModification({
    required String baseUrl,
    required String path,
    required NetworkRequestMethod method,
  }) {
    _responseModifications.remove(_modKey(
      baseUrl: baseUrl,
      path: path,
      method: method,
    ));
  }

  int get responseModificationCount => _responseModifications.length;

  List<ResponseModificationEntry> getAllResponseModifications() {
    final entries = <ResponseModificationEntry>[];

    _responseModifications.forEach((key, modification) {
      final parts = key.split('::');
      if (parts.length < 3) return;

      final methodRaw = parts.first;
      final baseUrl = parts[1];
      final path = parts.sublist(2).join('::');

      try {
        final method = NetworkRequestMethod.fromString(methodRaw);
        entries.add(
          ResponseModificationEntry(
            baseUrl: baseUrl,
            path: path,
            method: method,
            modification: modification,
          ),
        );
      } catch (_) {
        return;
      }
    });

    entries.sort((a, b) {
      final byHost = a.baseUrl.compareTo(b.baseUrl);
      if (byHost != 0) return byHost;
      final byPath = a.path.compareTo(b.path);
      if (byPath != 0) return byPath;
      return a.method.value.compareTo(b.method.value);
    });

    return entries;
  }

  String _modKey({
    required String baseUrl,
    required String path,
    required NetworkRequestMethod method,
  }) {
    return '${method.value}::$baseUrl::$path';
  }
}
