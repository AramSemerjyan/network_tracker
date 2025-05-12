import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:network_tracker/network_tracker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Network tracker demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Dio _dio =
      Dio(BaseOptions(baseUrl: 'https://jsonplaceholder.typicode.com'));
  final Dio _secondDio = Dio(BaseOptions(baseUrl: 'https://dummyjson.com'));

  String _selectedPath = '/posts/1';
  String _selectedMethod = 'GET';

  final List<String> _allPaths = [
    '/posts',
    '/posts/1',
    '/posts/2',
    '/comments/1',
    '/todos/1',
    '/albums/1',
  ];

  final List<String> _methods = ['GET', 'POST'];

  @override
  void initState() {
    super.initState();

    _dio.interceptors.add(NetworkTrackerInterceptor());
    _secondDio.interceptors.add(NetworkTrackerInterceptor());
  }

  void _makeSecondDioRequest() async {
    try {
      final result = await _secondDio.get('/test');

      if (kDebugMode) {
        print('Request success: $result');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Request failed: $e');
      }
    }
  }

  void _makeRequest() async {
    try {
      Response result;

      if (_selectedMethod == 'GET') {
        result = await _dio.get(_selectedPath);
      } else {
        result = await _dio.post(
          _selectedPath,
          data: {
            'title': 'foo',
            'body': 'bar',
            'userId': 1,
          },
        );
      }

      if (kDebugMode) {
        print('Request success: $result');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Request failed: $e');
      }
    }
  }

  Future<void> _makeErrorRequest() async {
    try {
      final result = await _dio.get('/invalid-endpoint-404');
      if (kDebugMode) {
        print('Unexpected success: $result');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Expected failure occurred: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredPaths = _allPaths.where((path) {
      if (_selectedMethod == 'POST') {
        return path == '/posts';
      }
      return true;
    }).toList();

    if (!filteredPaths.contains(_selectedPath)) {
      _selectedPath = filteredPaths.first;
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: 'Open tracker',
            onPressed: () => NetworkRequestsViewer.showPage(context: context),
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Select method and path:'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: DropdownButtonFormField<String>(
              value: _selectedMethod,
              onChanged: (value) => setState(() {
                _selectedMethod = value!;
              }),
              items: _methods
                  .map((method) => DropdownMenuItem(
                        value: method,
                        child: Text(method),
                      ))
                  .toList(),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'HTTP Method',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: DropdownButtonFormField<String>(
              value: _selectedPath,
              onChanged: (value) => setState(() {
                _selectedPath = value!;
              }),
              items: filteredPaths
                  .map((path) => DropdownMenuItem(
                        value: path,
                        child: Text(path),
                      ))
                  .toList(),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Endpoint',
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.greenAccent.withAlpha(180),
            ),
            onPressed: _makeRequest,
            child: const Text('Make Request'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.greenAccent.withAlpha(180),
            ),
            onPressed: _makeSecondDioRequest,
            child: const Text('Make Second Dio Request'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.withAlpha(180),
            ),
            onPressed: _makeErrorRequest,
            child: const Text('Make Error Request'),
          ),
        ],
      ),
    );
  }
}
