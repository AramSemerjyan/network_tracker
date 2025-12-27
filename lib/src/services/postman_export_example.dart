import 'dart:io';
import 'package:network_tracker/network_tracker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Example demonstrating how to export network requests as a Postman collection.
class PostmanExportExample {
  /// Export all tracked network requests to a Postman collection file.
  ///
  /// This creates a `.json` file that can be imported directly into Postman.
  static Future<void> exportAllRequests({
    required String collectionName,
  }) async {
    // Get all tracked requests from the storage
    final requests =
        await NetworkRequestService.instance.storageService.getAllRequests();

    // Generate the Postman collection JSON
    final postmanJson = PostmanExportService.exportToPostmanCollection(
      requests: requests,
      collectionName: collectionName,
    );

    // Save to file
    final directory = await getApplicationDocumentsDirectory();
    final file =
        File('${directory.path}/$collectionName.postman_collection.json');
    await file.writeAsString(postmanJson);

    print('Postman collection exported to: ${file.path}');
  }

  /// Export and share a Postman collection via the share dialog.
  ///
  /// This allows users to share the collection through various apps
  /// (email, messaging, cloud storage, etc.)
  static Future<void> exportAndShareRequests({
    required String collectionName,
  }) async {
    // Get all tracked requests
    final requests =
        await NetworkRequestService.instance.storageService.getAllRequests();

    if (requests.isEmpty) {
      print('No requests to export');
      return;
    }

    // Generate the Postman collection JSON
    final postmanJson = PostmanExportService.exportToPostmanCollection(
      requests: requests,
      collectionName: collectionName,
    );

    // Save to a temporary file
    final directory = await getTemporaryDirectory();
    final fileName =
        '${collectionName.replaceAll(' ', '_')}.postman_collection.json';
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(postmanJson);

    // Share the file
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Postman collection: $collectionName',
    );
  }

  /// Export specific requests (e.g., filtered by path or method).
  static Future<void> exportFilteredRequests({
    required String collectionName,
    String? pathContains,
    String? method,
  }) async {
    // Get all requests
    final allRequests =
        await NetworkRequestService.instance.storageService.getAllRequests();

    // Filter requests based on criteria
    var filteredRequests = allRequests.where((request) {
      if (pathContains != null && !request.path.contains(pathContains)) {
        return false;
      }
      if (method != null &&
          request.method.name.toUpperCase() != method.toUpperCase()) {
        return false;
      }
      return true;
    }).toList();

    if (filteredRequests.isEmpty) {
      print('No requests match the filter criteria');
      return;
    }

    // Generate the Postman collection
    final postmanJson = PostmanExportService.exportToPostmanCollection(
      requests: filteredRequests,
      collectionName: collectionName,
    );

    // Save to file
    final directory = await getApplicationDocumentsDirectory();
    final file =
        File('${directory.path}/$collectionName.postman_collection.json');
    await file.writeAsString(postmanJson);

    print(
        'Exported ${filteredRequests.length} filtered requests to: ${file.path}');
  }

  /// Export a single request by ID.
  static Future<void> exportSingleRequest({
    required String requestId,
    required String collectionName,
  }) async {
    final allRequests =
        await NetworkRequestService.instance.storageService.getAllRequests();
    final request = allRequests.where((r) => r.id == requestId).firstOrNull;

    if (request == null) {
      print('Request not found: $requestId');
      return;
    }

    final postmanJson = PostmanExportService.exportToPostmanCollection(
      requests: [request],
      collectionName: collectionName,
    );

    final directory = await getApplicationDocumentsDirectory();
    final file =
        File('${directory.path}/$collectionName.postman_collection.json');
    await file.writeAsString(postmanJson);

    print('Single request exported to: ${file.path}');
  }

  /// Export requests from a specific base URL (useful for multi-API apps).
  static Future<void> exportByBaseUrl({
    required String baseUrl,
    required String collectionName,
  }) async {
    final allRequests =
        await NetworkRequestService.instance.storageService.getAllRequests();

    final filteredRequests = allRequests.where((request) {
      return request.baseUrl == baseUrl;
    }).toList();

    if (filteredRequests.isEmpty) {
      print('No requests found for base URL: $baseUrl');
      return;
    }

    final postmanJson = PostmanExportService.exportToPostmanCollection(
      requests: filteredRequests,
      collectionName: collectionName,
    );

    final directory = await getApplicationDocumentsDirectory();
    final file =
        File('${directory.path}/$collectionName.postman_collection.json');
    await file.writeAsString(postmanJson);

    print('Exported ${filteredRequests.length} requests from $baseUrl');
  }
}

/// UI integration example - add button to export from the network viewer.
/// 
/// Example usage in your Flutter app:
/// 
/// ```dart
/// FloatingActionButton(
///   onPressed: () async {
///     await PostmanExportExample.exportAndShareRequests(
///       collectionName: 'My App API',
///     );
///   },
///   child: Icon(Icons.file_download),
/// )
/// ```
/// 
/// Or add to the network viewer's app bar:
/// 
/// ```dart
/// AppBar(
///   title: Text('Network Requests'),
///   actions: [
///     IconButton(
///       icon: Icon(Icons.share),
///       onPressed: () async {
///         await PostmanExportExample.exportAndShareRequests(
///           collectionName: 'Project Name API',
///         );
///       },
///     ),
///   ],
/// )
/// ```
