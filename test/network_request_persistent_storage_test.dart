import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_tracker/src/model/network_request.dart';
import 'package:network_tracker/src/model/network_request_method.dart';
import 'package:network_tracker/src/services/request_status.dart';
import 'package:network_tracker/src/services/storage/persistent/network_request_persistent_storage.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit(); // initialize FFI bindings
  databaseFactory = databaseFactoryFfi; // set the factory for tests

  late NetworkRequestPersistentStorage storage;

  setUp(() async {
    storage = NetworkRequestPersistentStorage();
    await storage.initDb();
    await storage.clear();
  });

  test('addRequest stores a new request into the database', () async {
    final request = NetworkRequest(
      id: '1',
      path: '/test',
      method: NetworkRequestMethod.get,
      baseUrl: 'https://api.example.com',
      startDate: DateTime.now(),
    );

    await storage.addRequest(request);
    final result =
        await storage.getRequestsByPath('/test', 'https://api.example.com');

    expect(result.length, 1);
    expect(result.first.path, '/test');
  });

  test('getUrls returns all distinct baseUrls', () async {
    final req1 = NetworkRequest(
      id: '1',
      path: '/a',
      method: NetworkRequestMethod.get,
      baseUrl: 'https://url1.com',
      startDate: DateTime.now(),
    );
    final req2 = NetworkRequest(
      id: '2',
      path: '/b',
      method: NetworkRequestMethod.get,
      baseUrl: 'https://url2.com',
      startDate: DateTime.now(),
    );
    await storage.addRequest(req1);
    await storage.addRequest(req2);

    final urls = await storage.getUrls();
    expect(urls.length, 2);
    expect(urls, containsAll(['https://url1.com', 'https://url2.com']));
  });

  test('clear removes all records from the requests table', () async {
    final request = NetworkRequest(
      id: '1',
      path: '/clear',
      method: NetworkRequestMethod.get,
      baseUrl: 'https://clear.com',
      startDate: DateTime.now(),
    );
    await storage.addRequest(request);
    await storage.clear();
    final result =
        await storage.getRequestsByPath('/clear', 'https://clear.com');
    expect(result.isEmpty, true);
  });

  test(
      'getTrackedPaths returns paths grouped by most recent request date for a baseUrl',
      () async {
    final now = DateTime.now();
    final req1 = NetworkRequest(
      id: '1',
      path: '/a',
      method: NetworkRequestMethod.get,
      baseUrl: 'https://track.com',
      startDate: now,
    );
    final req2 = NetworkRequest(
      id: '2',
      path: '/b',
      method: NetworkRequestMethod.get,
      baseUrl: 'https://track.com',
      startDate: now.add(Duration(seconds: 1)),
    );
    await storage.addRequest(req1);
    await storage.addRequest(req2);

    final paths = await storage.getTrackedPaths('https://track.com');
    expect(paths, ['/b', '/a']);
  });

  test('updateRequest updates only provided fields correctly', () async {
    final startTime = DateTime.now();
    final request = NetworkRequest(
      id: '3',
      path: '/update',
      method: NetworkRequestMethod.post,
      baseUrl: 'https://update.com',
      startDate: startTime,
    );
    await storage.addRequest(request);

    final options =
        RequestOptions(path: '/update', baseUrl: 'https://update.com');
    final response = Response(
      requestOptions: options,
      data: {'message': 'done'},
      statusCode: 200,
      headers: Headers.fromMap({
        'Content-Type': ['application/json']
      }),
    );

    await storage.updateRequest(
      '3',
      requestOptions: options,
      response: response,
      status: RequestStatus.completed,
      endDate: DateTime.now(),
    );

    final updated =
        (await storage.getRequestsByPath('/update', 'https://update.com'))
            .first;
    expect(updated.status, RequestStatus.completed);
    expect(updated.responseData, {'message': 'done'});
    expect(updated.statusCode, 200);
    expect(updated.responseHeaders, {
      'Content-Type': ['application/json']
    });
    expect(updated.duration, isNotNull);
  });
}
