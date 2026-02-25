import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:network_tracker/src/model/network_request.dart';
import 'package:network_tracker/src/model/network_request_filter.dart';
import 'package:network_tracker/src/services/request_status.dart';
import 'package:network_tracker/src/services/storage/persistent/db_tables.dart';
import 'package:network_tracker/src/utils/extensions.dart';
import 'package:network_tracker/src/utils/utils.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../../model/network_request_storage_interface.dart';

/// SQLite-backed implementation of [NetworkRequestStorageInterface].
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

  /// Initializes the SQLite database and applies schema migrations.
  Future<void> initDb() async {
    _db = await openDatabase(
      join(await getDatabasesPath(), 'network_tracker.db'),
      version: 2,
      onCreate: (Database db, int version) async {
        for (var t in DBTables.values) {
          await db.execute(t.struct);
        }
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE ${DBTables.requests.key} ADD COLUMN isModified INTEGER',
          );
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
    required RequestOptions requestOptions,
    Response? response,
    RequestStatus? status,
    DateTime? endDate,
    DioException? dioError,
    bool? isModified,
  }) async {
    await _db.update(
      DBTables.requests.key,
      {
        if (status != null) 'status': status.name,
        if (response?.data != null) 'responseData': jsonEncode(response!.data),
        if (response?.statusCode != null) 'statusCode': response!.statusCode,
        if (response?.headers.map != null)
          'responseHeaders': jsonEncode(response!.headers.map),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
        if (dioError != null) 'dioError': dioError.dioExceptionToJsonString(),
        if (response!.data != null)
          'responseSize': Utils.estimateSize(response.data),
        if (requestOptions.baseUrl.isNotEmpty)
          'baseUrl': requestOptions.baseUrl,
        if (isModified != null) 'isModified': isModified == true ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  NetworkRequest _fromMap(Map<String, dynamic> map) {
    return NetworkRequest.fromJson(map);
  }
}
