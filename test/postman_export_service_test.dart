import 'package:flutter_test/flutter_test.dart';
import 'package:network_tracker/src/model/network_request.dart';
import 'package:network_tracker/src/model/network_request_method.dart';
import 'package:network_tracker/src/services/postman_export_service.dart';
import 'package:network_tracker/src/services/request_status.dart';
import 'dart:convert';

void main() {
  group('PostmanExportService', () {
    test('should export single GET request to Postman collection', () {
      final request = NetworkRequest(
        id: 'test-id-1',
        path: '/api/users',
        baseUrl: 'https://api.example.com',
        method: NetworkRequestMethod.get,
        startDate: DateTime(2025, 1, 1, 10, 0, 0),
        endDate: DateTime(2025, 1, 1, 10, 0, 1),
        status: RequestStatus.completed,
        statusCode: 200,
        headers: {
          'Authorization': 'Bearer token123',
          'Content-Type': 'application/json',
        },
        queryParameters: {
          'page': '1',
          'limit': '10',
        },
        responseData: {
          'users': [
            {'id': 1, 'name': 'John'},
            {'id': 2, 'name': 'Jane'},
          ]
        },
      );

      final result = PostmanExportService.exportToPostmanCollection(
        requests: [request],
        collectionName: 'Test API Collection',
      );

      expect(result, isNotEmpty);

      final json = jsonDecode(result);
      expect(json['info']['name'], equals('Test API Collection'));
      expect(json['info']['schema'], contains('v2.1.0'));
      expect(json['item'], hasLength(1));

      final item = json['item'][0];
      expect(item['name'], equals('GET /api/users'));
      expect(item['request']['method'], equals('GET'));
      expect(item['request']['url']['raw'],
          contains('https://api.example.com/api/users?page=1&limit=10'));
      expect(item['request']['header'], hasLength(2));
    });

    test('should export POST request with body', () {
      final request = NetworkRequest(
        id: 'test-id-2',
        path: '/api/users',
        baseUrl: 'https://api.example.com',
        method: NetworkRequestMethod.post,
        startDate: DateTime.now(),
        status: RequestStatus.completed,
        statusCode: 201,
        requestData: {
          'name': 'New User',
          'email': 'user@example.com',
        },
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final result = PostmanExportService.exportToPostmanCollection(
        requests: [request],
        collectionName: 'API Collection',
      );

      final json = jsonDecode(result);
      final item = json['item'][0];

      expect(item['request']['method'], equals('POST'));
      expect(item['request']['body'], isNotNull);
      expect(item['request']['body']['mode'], equals('raw'));

      final bodyData = jsonDecode(item['request']['body']['raw']);
      expect(bodyData['name'], equals('New User'));
      expect(bodyData['email'], equals('user@example.com'));
    });

    test('should export multiple requests', () {
      final requests = [
        NetworkRequest(
          id: 'req-1',
          path: '/users',
          baseUrl: 'https://api.example.com',
          method: NetworkRequestMethod.get,
          startDate: DateTime.now(),
          status: RequestStatus.completed,
        ),
        NetworkRequest(
          id: 'req-2',
          path: '/posts',
          baseUrl: 'https://api.example.com',
          method: NetworkRequestMethod.get,
          startDate: DateTime.now(),
          status: RequestStatus.completed,
        ),
        NetworkRequest(
          id: 'req-3',
          path: '/comments',
          baseUrl: 'https://api.example.com',
          method: NetworkRequestMethod.post,
          startDate: DateTime.now(),
          status: RequestStatus.completed,
          requestData: {'text': 'Great post!'},
        ),
      ];

      final result = PostmanExportService.exportToPostmanCollection(
        requests: requests,
        collectionName: 'Multi Request Collection',
      );

      final json = jsonDecode(result);
      expect(json['item'], hasLength(3));
      expect(json['item'][0]['name'], equals('GET /users'));
      expect(json['item'][1]['name'], equals('GET /posts'));
      expect(json['item'][2]['name'], equals('POST /comments'));
    });

    test('should handle requests without query parameters', () {
      final request = NetworkRequest(
        id: 'test-id-3',
        path: '/api/status',
        baseUrl: 'https://api.example.com',
        method: NetworkRequestMethod.get,
        startDate: DateTime.now(),
        status: RequestStatus.completed,
      );

      final result = PostmanExportService.exportToPostmanCollection(
        requests: [request],
        collectionName: 'Simple Collection',
      );

      final json = jsonDecode(result);
      final item = json['item'][0];
      expect(item['request']['url']['raw'],
          equals('https://api.example.com/api/status'));
      expect(item['request']['url']['query'], isNull);
    });

    test('should include request metadata in description', () {
      final request = NetworkRequest(
        id: 'test-id-4',
        path: '/api/data',
        baseUrl: 'https://api.example.com',
        method: NetworkRequestMethod.get,
        startDate: DateTime(2025, 1, 1, 10, 0, 0),
        endDate: DateTime(2025, 1, 1, 10, 0, 2),
        status: RequestStatus.completed,
        statusCode: 200,
        requestSizeBytes: 1024,
        responseSizeBytes: 2048,
        isRepeated: true,
      );

      final result = PostmanExportService.exportToPostmanCollection(
        requests: [request],
        collectionName: 'Metadata Collection',
      );

      final json = jsonDecode(result);
      final description = json['item'][0]['request']['description'];

      expect(description, contains('test-id-4'));
      expect(description, contains('2000ms'));
      expect(description, contains('Status Code: 200'));
      expect(description, contains('repeated'));
    });

    test('should export without pretty print', () {
      final request = NetworkRequest(
        id: 'test-id-5',
        path: '/test',
        baseUrl: 'https://api.example.com',
        method: NetworkRequestMethod.get,
        startDate: DateTime.now(),
        status: RequestStatus.completed,
      );

      final result = PostmanExportService.exportToPostmanCollection(
        requests: [request],
        collectionName: 'Compact',
        prettyPrint: false,
      );

      // Should not contain indentation
      expect(result, isNot(contains('  ')));
      // But should still be valid JSON
      expect(() => jsonDecode(result), returnsNormally);
    });

    test('should handle empty request list', () {
      final result = PostmanExportService.exportToPostmanCollection(
        requests: [],
        collectionName: 'Empty Collection',
      );

      final json = jsonDecode(result);
      expect(json['item'], isEmpty);
      expect(json['info']['name'], equals('Empty Collection'));
    });
  });
}
