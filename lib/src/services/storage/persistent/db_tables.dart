/// Database tables used by persistent request storage.
enum DBTables {
  /// Stores tracked network requests.
  requests,
}

/// DbTablesExt extension.
extension DbTablesExt on DBTables {
  /// SQL table name for this enum value.
  String get key {
    switch (this) {
      case DBTables.requests:
        return 'requests_table';
    }
  }

  /// SQL `CREATE TABLE` statement for this table.
  String get struct {
    switch (this) {
      case DBTables.requests:
        return '''
        CREATE TABLE IF NOT EXISTS ${DBTables.requests.key} (
          id TEXT PRIMARY KEY,
          path TEXT,
          baseUrl TEXT, 
          method TEXT,
          startDate TEXT,
          endDate TEXT,
          headers TEXT,
          requestData TEXT,
          queryParameters TEXT,
          status TEXT,
          responseData TEXT,
          statusCode INTEGER,
          responseHeaders TEXT,
          dioError TEXT,
          requestSize INTEGER,
          responseSize INTEGER,
          isRepeated INTEGER,
          isModified INTEGER,
          requestSizeBytes INTEGER,
          responseSizeBytes INTEGER
        )
        ''';
    }
  }
}
