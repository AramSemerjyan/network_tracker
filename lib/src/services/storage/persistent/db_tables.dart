enum DBTables { requests }

extension DbTablesExt on DBTables {
  String get key {
    switch (this) {
      case DBTables.requests:
        return 'requests_table';
    }
  }

  String get struct {
    switch (this) {
      case DBTables.requests:
        return '''
        CREATE TABLE IF NOT EXISTS ${DBTables.requests.key} (
          id TEXT PRIMARY KEY,
          path TEXT,
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
          isRepeated INTEGER
        )
        ''';
    }
  }
}
