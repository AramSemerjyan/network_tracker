import 'dart:convert';

import 'package:dio/src/dio_exception.dart';
import 'package:network_tracker/src/model/network_request.dart';
import 'package:network_tracker/src/model/network_request_filter.dart';
import 'package:network_tracker/src/services/request_status.dart';
import 'package:network_tracker/src/services/storage/persistent/db_tables.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../../model/network_request_method.dart';
import '../../../model/network_request_storage_interface.dart';

class NetworkRequestPersistentStorage
    implements NetworkRequestStorageInterface {
  late final Database _db;

  @override
  String baseUrl = '';

  Future<void> initDb() async {
    _db = await openDatabase(
      join(await getDatabasesPath(), 'network_tracker.db'),
      version: 1,
      onCreate: (Database db, int version) async {
        for (var t in DBTables.values) {
          await db.execute(t.struct);
        }
      },
    );
  }

  Map<String, dynamic> _encodeRequest(NetworkRequest request) => {
        'id': request.id,
        'path': request.path,
        'method': request.method.value,
        'startDate': request.startDate.toIso8601String(),
        'endDate': request.endDate?.toIso8601String(),
        'headers': jsonEncode(request.headers),
        'requestData': jsonEncode(request.requestData),
        'queryParameters': jsonEncode(request.queryParameters),
        'status': request.status.name,
        'responseData': jsonEncode(request.responseData),
        'statusCode': request.statusCode,
        'responseHeaders': jsonEncode(request.responseHeaders),
        'dioError': request.dioError?.toString(),
        'requestSize': request.requestSizeBytes,
        'responseSize': request.responseSizeBytes,
        'isRepeated': request.isRepeated == true ? 1 : 0,
      };

  @override
  Future<void> addRequest(NetworkRequest request) async {
    await _db.insert(
      'requests',
      _encodeRequest(request),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateRequest(String id,
      {RequestStatus? status,
      responseData,
      int? statusCode,
      Map<String, dynamic>? responseHeaders,
      DateTime? endDate,
      DioException? dioError,
      int? responseSize}) async {
    await _db.update(
      'requests',
      {
        if (status != null) 'status': status.name,
        if (responseData != null) 'responseData': jsonEncode(responseData),
        if (statusCode != null) 'statusCode': statusCode,
        if (responseHeaders != null)
          'responseHeaders': jsonEncode(responseHeaders),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
        if (dioError != null) 'dioError': dioError.toString(),
        if (responseSize != null) 'responseSize': responseSize,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  NetworkRequest _fromMap(Map<String, dynamic> map) {
    return NetworkRequest(
      id: map['id'],
      path: map['path'],
      method: NetworkRequestMethod.fromString(map['method']),
      startDate: DateTime.parse(map['startDate']),
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
      headers: jsonDecode(map['headers']),
      requestData: jsonDecode(map['requestData']),
      queryParameters: jsonDecode(map['queryParameters']),
      status: RequestStatus.values.firstWhere((e) => e.name == map['status'],
          orElse: () => RequestStatus.pending),
      responseData: jsonDecode(map['responseData']),
      statusCode: map['statusCode'],
      responseHeaders: jsonDecode(map['responseHeaders']),
      dioError: null,
      requestSizeBytes: map['requestSize'],
      responseSizeBytes: map['responseSize'],
      isRepeated: map['isRepeated'] == 1,
    );
  }

  @override
  Future<List<NetworkRequest>> getRequestsByPath(String path) async {
    final result = await _db.query(
      'requests',
      where: 'path = ?',
      whereArgs: [path],
      orderBy: 'startDate DESC',
    );
    return result.map(_fromMap).toList();
  }

  @override
  Future<List<String>> getTrackedPaths() async {
    final result = await _db.rawQuery('''
      SELECT path, MAX(startDate) as latest FROM requests
      GROUP BY path
      ORDER BY latest DESC
    ''');
    return result.map((e) => e['path'] as String).toList();
  }

  @override
  Future<List<List<NetworkRequest>>> getFilteredGroups(
      NetworkRequestFilter filter) async {
    final paths = await getTrackedPaths();
    final List<List<NetworkRequest>> result = [];

    for (final path in paths) {
      List<NetworkRequest> requests = await getRequestsByPath(path);

      if (filter.method != null) {
        requests = requests.where((r) => r.method == filter.method).toList();
      }

      if (filter.status != null) {
        requests = requests.where((r) => r.status == filter.status).toList();
      }

      if (filter.isRepeated == true) {
        requests = requests.where((r) => r.isRepeated == true).toList();
      }

      if (filter.searchQuery.isNotEmpty &&
          !path.toLowerCase().contains(filter.searchQuery.toLowerCase())) {
        continue;
      }

      if (requests.isNotEmpty) result.add(requests);
    }

    return result;
  }

  @override
  void setBaseUrl(String baseUrl) {
    this.baseUrl = baseUrl;
  }

  @override
  Future<void> clear() async {
    await _db.delete('requests');
  }
}
