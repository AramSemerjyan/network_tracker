import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:json_view/json_view.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../model/network_request.dart';

class RequestDataDetailsScreen extends StatelessWidget {
  final NetworkRequest request;

  const RequestDataDetailsScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${request.method} - ${request.timestamp}',
          style: const TextStyle(fontSize: 14),
        ),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (request.requestData != null)
              ListTile(
                title: const Text('Request Data:'),
                subtitle: JsonView(
                  json: request.requestData,
                  shrinkWrap: true,
                ),
              ),
            if (request.queryParameters?.isNotEmpty ?? false)
              ListTile(
                title: const Text('Request Parameters:'),
                subtitle: JsonView(
                  json: request.queryParameters,
                  shrinkWrap: true,
                ),
              ),
            if (request.execTime != null)
              ListTile(
                title: const Text('Request time:'),
                subtitle: Text(
                  '${request.execTime!.millisecondsSinceEpoch / 1000.0}',
                ),
              ),
            if (request.error != null)
              ListTile(
                title: const Text('Error:'),
                subtitle: Text('${request.error}'),
              ),
            if (request.responseData != null)
              Expanded(
                child: ListTile(
                  title: Row(
                    children: [
                      const Text('Response data:'),
                      const Spacer(),
                      IconButton(
                        onPressed: () async {
                          try {
                            final tempDir = await getTemporaryDirectory();
                            final filePath =
                                '${tempDir.path}/${request.name}.json';
                            final jsonString = jsonEncode(request.responseData);
                            final file = File(filePath);
                            await file.writeAsString(jsonString);

                            await Share.shareXFiles([XFile(file.path)]);
                          } catch (e) {
                            if (kDebugMode) {
                              print("Error saving or sharing JSON file: $e");
                            }
                          }
                        },
                        icon: const Icon(Icons.save_alt),
                      )
                    ],
                  ),
                  subtitle: JsonView(
                    json: request.responseData,
                    padding: const EdgeInsets.only(bottom: 40),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
