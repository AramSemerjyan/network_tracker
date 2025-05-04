import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:network_tracker/src/model/network_request.dart';
import 'package:path_provider/path_provider.dart';

class Utils {
  static Future<File?> exportRequest(NetworkRequest request) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/${request.name}.json';
      final jsonString = jsonEncode(request.responseData);
      final file = File(filePath);
      await file.writeAsString(jsonString);

      return file;
    } catch (e) {
      if (kDebugMode) print(e);

      return null;
    }
  }
}
