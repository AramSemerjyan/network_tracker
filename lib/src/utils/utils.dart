import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

class Utils {
  /// Exports the provided [data] to a temporary `.json` file.
  ///
  /// The file is saved in the system's temporary directory using the optional [fileName].
  /// If no [fileName] is provided, a unique name is generated automatically.
  ///
  /// The [data] can be any JSON-serializable object (e.g. `Map`, `List`, custom models).
  ///
  /// Returns the created [File] on success, or `null` if an error occurs.
  ///
  /// This method is useful for exporting debug information, request/response payloads,
  /// or any app data in JSON format for external use.
  static Future<File?> exportFile(dynamic data, {String? fileName}) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final name = fileName ?? Uuid().v1();
      final filePath = '${tempDir.path}/$name.json';
      final jsonString = jsonEncode(data);
      final file = File(filePath);
      await file.writeAsString(jsonString);

      return file;
    } catch (e) {
      if (kDebugMode) print(e);

      return null;
    }
  }

  /// Exports the given [data] as a temporary `.json` file and shares it using the system share sheet.
  ///
  /// Optionally accepts a [fileName] to use for the exported file; if not provided,
  /// a unique name will be generated automatically.
  ///
  /// The [data] must be JSON-serializable.
  ///
  /// If the export is successful, the generated file is shared using the platform's
  /// native sharing capabilities (e.g., AirDrop, email, messaging apps).
  static Future<void> shareFile(dynamic data, {String? fileName}) async {
    final file = await Utils.exportFile(
      data,
      fileName: fileName,
    );

    if (file != null) {
      final params = ShareParams(
        files: [XFile(file.path)],
      );

      await SharePlus.instance.share(params);
    }
  }

  /// Converts a byte [int] value into a human-readable string.
  ///
  /// If the value is less than 1024, it's returned in bytes (e.g. `"512 bytes"`).
  /// Otherwise, it will be converted to kilobytes, megabytes, etc., using binary multiples.
  ///
  /// [bytes] is the size in bytes to be formatted.
  /// [decimals] controls the number of decimal places shown (default is `0`).
  ///
  /// Returns a formatted string such as `"1Kb"`, `"3.5Mb"`, or an empty string
  /// if [bytes] is `null`.
  static String formatBytes(int? bytes, [int decimals = 0]) {
    if (bytes == null) return '';

    if (bytes < 1024) return '$bytes bytes';
    const suffixes = ['Kb', 'Mb', 'Gb', 'Tb'];
    double size = bytes / 1024;
    int i = 0;

    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }

    return '${size.toStringAsFixed(decimals)}${suffixes[i]}';
  }

  static int estimateSize(dynamic data) {
    if (data == null) return 0;
    try {
      return utf8.encode(jsonEncode(data)).length;
    } catch (_) {
      return 0;
    }
  }
}
