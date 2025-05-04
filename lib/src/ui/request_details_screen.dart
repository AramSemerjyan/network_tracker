import 'package:flutter/material.dart';

import '../model/network_request.dart';
import 'request_data_details_screen.dart';

class RequestDetailsScreen extends StatelessWidget {
  final String path;
  final List<NetworkRequest> requests;

  const RequestDetailsScreen(
      {super.key, required this.path, required this.requests});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(path),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView.builder(
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final request = requests[index];
          return ListTile(
            title: Text('${request.method} - ${request.timestamp}'),
            subtitle:
                Text('Status: ${request.status.symbol} ${request.status}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RequestDataDetailsScreen(
                    request: request,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
