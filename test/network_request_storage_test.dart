import 'package:flutter_test/flutter_test.dart';
import 'package:network_tracker/src/model/network_request.dart';
import 'package:network_tracker/src/model/network_request_method.dart';
import 'package:network_tracker/src/model/network_request_storage_interface.dart';
import 'package:network_tracker/src/services/network_request_service.dart';
import 'package:network_tracker/src/services/request_status.dart';

void main() {
  group('NetworkRequestStorage', () {
    late NetworkRequestStorageInterface storage;
    final String baseUrl = 'https://api.example.com';

    setUp(() {
      storage = NetworkRequestService.instance.storageService;
    });

    NetworkRequest buildRequest({
      required String id,
      required String path,
      required String baseUrl,
      DateTime? timestamp,
    }) {
      return NetworkRequest(
        id: id,
        path: path,
        baseUrl: baseUrl,
        method: NetworkRequestMethod.fromString('GET'),
        startDate: timestamp ?? DateTime.now(),
        headers: {'Authorization': 'Bearer token'},
        requestData: {'input': 'test'},
        queryParameters: {'q': 'query'},
      );
    }

    test('addRequest stores request in _allRequests and _requestsByPath',
        () async {
      final request = buildRequest(
        id: '1',
        path: '/test',
        baseUrl: baseUrl,
      );

      await storage.addRequest(request);

      final byPath = await storage.getRequestsByPath('/test', baseUrl);
      expect(byPath, contains(request));
      expect(await storage.getTrackedPaths(baseUrl), contains('/test'));
    });

    test('updateRequest modifies the correct fields and sets execTime',
        () async {
      final request = buildRequest(
        id: '2',
        path: '/update',
        baseUrl: baseUrl,
      );
      await storage.addRequest(request);

      await storage.updateRequest(
        '2',
        status: RequestStatus.completed,
        baseUrl: baseUrl,
        responseData: {'result': 'ok'},
        statusCode: 200,
        endDate: DateTime.now(),
        responseHeaders: {'Content-Type': 'application/json'},
      );

      final updated =
          (await storage.getRequestsByPath('/update', baseUrl)).first;

      expect(updated.status, RequestStatus.completed);
      expect(updated.responseData, {'result': 'ok'});
      expect(updated.statusCode, 200);
      expect(updated.responseHeaders, {'Content-Type': 'application/json'});
      expect(updated.duration, isNotNull);
    });

    test('getRequestsByPath returns sorted list by timestamp desc', () async {
      final now = DateTime.now();
      final oldRequest = buildRequest(
        id: '3',
        path: '/sorted',
        baseUrl: baseUrl,
        timestamp: now.subtract(const Duration(seconds: 5)),
      );
      final newRequest = buildRequest(
        id: '4',
        path: '/sorted',
        baseUrl: baseUrl,
        timestamp: now,
      );

      await storage.addRequest(oldRequest);
      await storage.addRequest(newRequest);

      final result = await storage.getRequestsByPath('/sorted', baseUrl);
      expect(result.length, 2);
      expect(result.first.id, '4');
      expect(result.last.id, '3');
    });

    test('getTrackedPaths returns paths sorted by latest timestamp', () async {
      final now = DateTime.now();
      final older = buildRequest(
        id: '5',
        path: '/a',
        baseUrl: baseUrl,
        timestamp: now.subtract(const Duration(seconds: 10)),
      );
      final newer = buildRequest(
        id: '6',
        path: '/b',
        baseUrl: baseUrl,
        timestamp: now,
      );

      await storage.addRequest(older);
      await storage.addRequest(newer);

      final paths = await storage.getTrackedPaths(baseUrl);
      expect(paths.first, '/b');
      expect(paths.last, '/a');
    });

    test('singleton instance returns the same object', () {
      final instance1 = NetworkRequestService.instance;
      final instance2 = NetworkRequestService.instance;

      expect(identical(instance1, instance2), isTrue);
    });
  });
}
