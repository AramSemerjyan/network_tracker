import 'package:flutter_test/flutter_test.dart';
import 'package:network_tracker/src/model/network_request.dart';
import 'package:network_tracker/src/model/network_request_method.dart';
import 'package:network_tracker/src/services/network_request_service.dart';
import 'package:network_tracker/src/services/network_request_storage.dart';
import 'package:network_tracker/src/services/request_status.dart';

void main() {
  group('NetworkRequestStorage', () {
    late NetworkRequestStorageInterface storage;

    setUp(() {
      storage = NetworkRequestService.instance.storage;
    });

    NetworkRequest buildRequest({
      required String id,
      required String path,
      DateTime? timestamp,
    }) {
      return NetworkRequest(
        id: id,
        path: path,
        method: NetworkRequestMethod.fromString('GET'),
        timestamp: timestamp ?? DateTime.now(),
        headers: {'Authorization': 'Bearer token'},
        requestData: {'input': 'test'},
        queryParameters: {'q': 'query'},
      );
    }

    test('addRequest stores request in _allRequests and _requestsByPath', () {
      final request = buildRequest(id: '1', path: '/test');

      storage.addRequest(request);

      final byPath = storage.getRequestsByPath('/test');
      expect(byPath, contains(request));
      expect(storage.getTrackedPaths(), contains('/test'));
    });

    test('updateRequest modifies the correct fields and sets execTime',
        () async {
      final request = buildRequest(id: '2', path: '/update');
      storage.addRequest(request);

      storage.updateRequest(
        '2',
        status: RequestStatus.completed,
        responseData: {'result': 'ok'},
        statusCode: 200,
        responseHeaders: {'Content-Type': 'application/json'},
        error: 'none',
      );

      final updated = storage.getRequestsByPath('/update').first;

      expect(updated.status, RequestStatus.completed);
      expect(updated.responseData, {'result': 'ok'});
      expect(updated.statusCode, 200);
      expect(updated.responseHeaders, {'Content-Type': 'application/json'});
      expect(updated.error, 'none');
      expect(updated.execTime, isNotNull);
    });

    test('getRequestsByPath returns sorted list by timestamp desc', () {
      final now = DateTime.now();
      final oldRequest = buildRequest(
          id: '3',
          path: '/sorted',
          timestamp: now.subtract(const Duration(seconds: 5)));
      final newRequest = buildRequest(id: '4', path: '/sorted', timestamp: now);

      storage.addRequest(oldRequest);
      storage.addRequest(newRequest);

      final result = storage.getRequestsByPath('/sorted');
      expect(result.length, 2);
      expect(result.first.id, '4');
      expect(result.last.id, '3');
    });

    test('getTrackedPaths returns paths sorted by latest timestamp', () {
      final now = DateTime.now();
      final older = buildRequest(
          id: '5',
          path: '/a',
          timestamp: now.subtract(const Duration(seconds: 10)));
      final newer = buildRequest(id: '6', path: '/b', timestamp: now);

      storage.addRequest(older);
      storage.addRequest(newer);

      final paths = storage.getTrackedPaths();
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
