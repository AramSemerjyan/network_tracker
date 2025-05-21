import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:network_tracker/src/model/network_request.dart';
import 'package:network_tracker/src/model/network_request_filter.dart';
import 'package:network_tracker/src/services/request_status.dart';
import 'package:network_tracker/src/services/storage/persistent/db_tables.dart';
import 'package:network_tracker/src/utils/extensions.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../../model/network_request_storage_interface.dart';

class NetworkRequestPersistentStorage
    implements NetworkRequestStorageInterface {
  late final Database _db;

  @override
  Future<List<String>> getUrls() async {
    final result = await _db
        .rawQuery('SELECT DISTINCT baseUrl FROM ${DBTables.requests.key}');
    return result
        .map((e) => e['baseUrl'] as String)
        .whereType<String>()
        .toList();
  }

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

  @override
  Future<void> addRequest(NetworkRequest request) async {
    await _db.insert(
      DBTables.requests.key,
      request.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> clear() async {
    await _db.delete(DBTables.requests.key);
  }

  @override
  Future<List<List<NetworkRequest>>> getFilteredGroups(
      NetworkRequestFilter filter, String baseUrl) async {
    final paths = await getTrackedPaths(baseUrl);
    final List<List<NetworkRequest>> result = [];

    for (final path in paths) {
      List<NetworkRequest> requests = await getRequestsByPath(path, baseUrl);

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
  Future<List<NetworkRequest>> getRequestsByPath(
      String path, String baseUrl) async {
    final result = await _db.query(
      DBTables.requests.key,
      where: 'path = ? AND baseUrl = ?',
      whereArgs: [path, baseUrl],
      orderBy: 'startDate DESC',
    );
    return result.map(_fromMap).toList();
  }

  @override
  Future<List<String>> getTrackedPaths(String baseUrl) async {
    final result = await _db.rawQuery('''
        SELECT path, MAX(startDate) as latest
        FROM ${DBTables.requests.key}
        WHERE baseUrl = ?
        GROUP BY path
        ORDER BY latest DESC
      ''', [baseUrl]);
    return result.map((e) => e['path'] as String).toList();
  }

  @override
  Future<void> updateRequest(
    String id, {
    required String baseUrl,
    RequestStatus? status,
    responseData,
    int? statusCode,
    Map<String, dynamic>? responseHeaders,
    DateTime? endDate,
    DioException? dioError,
    int? responseSize,
    bool? isThrottled,
  }) async {
    /// TODO: add isThrottled
    await _db.update(
      DBTables.requests.key,
      {
        if (status != null) 'status': status.name,
        if (responseData != null) 'responseData': jsonEncode(responseData),
        if (statusCode != null) 'statusCode': statusCode,
        if (responseHeaders != null)
          'responseHeaders': jsonEncode(responseHeaders),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
        if (dioError != null) 'dioError': dioError.dioExceptionToJsonString(),
        if (responseSize != null) 'responseSize': responseSize,
        if (baseUrl.isNotEmpty) 'baseUrl': baseUrl,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  NetworkRequest _fromMap(Map<String, dynamic> map) {
    return NetworkRequest.fromJson(map);
  }
}
