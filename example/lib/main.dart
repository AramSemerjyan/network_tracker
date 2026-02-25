import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:network_tracker/network_tracker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.dark;
  static const Color _darkBackground = Color(0xFF1F2238);
  static final Color _darkCard = Color.alphaBlend(
    Colors.white.withAlpha(18),
    _darkBackground,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ).copyWith(
          surface: _darkBackground,
        ),
        cardTheme: CardThemeData(color: _darkCard),
        dropdownMenuTheme: DropdownMenuThemeData(
          menuStyle: MenuStyle(
            backgroundColor: WidgetStateProperty.all(_darkCard),
          ),
        ),
        scaffoldBackgroundColor: _darkBackground,
        appBarTheme: const AppBarTheme(backgroundColor: _darkBackground),
        useMaterial3: true,
      ),
      themeMode: _themeMode,
      home: MyHomePage(
        title: 'Network tracker demo',
        isDarkMode: _themeMode == ThemeMode.dark,
        onThemeModeChanged: (isDark) {
          setState(() {
            _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
          });
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
    required this.isDarkMode,
    required this.onThemeModeChanged,
  });

  final String title;
  final bool isDarkMode;
  final ValueChanged<bool> onThemeModeChanged;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const EdgeInsets _pagePadding = EdgeInsets.fromLTRB(16, 20, 16, 28);
  static const EdgeInsets _cardPadding = EdgeInsets.all(16);
  static const double _sectionSpacing = 16;
  static const double _maxContentWidth = 520;

  static const String _jsonPlaceholder = 'https://jsonplaceholder.typicode.com';
  static const String _dummyJson = 'https://dummyjson.com';
  late final List<String> _baseUrls = [
    _jsonPlaceholder,
    _dummyJson,
  ];

  String _selectedPath = '/posts/1';
  String _selectedMethod = 'GET';
  late final ValueNotifier<String> _selectedClient =
      ValueNotifier(_jsonPlaceholder);

  final List<String> _allPaths = [
    '/posts',
    '/posts/1',
    '/posts/2',
    '/comments/1',
    '/todos/1',
    '/albums/1',
  ];

  late final Dio _jsonPlaceholderDio = Dio(
    BaseOptions(
      baseUrl: _jsonPlaceholder,
      headers: {
        'User-Agent': 'network-tracker-example',
        'Accept': 'application/json',
      },
    ),
  );

  late final Dio _dummyJsonDio = Dio(BaseOptions(baseUrl: _dummyJson));

  final List<String> _methods = ['GET', 'POST'];

  @override
  void initState() {
    super.initState();

    NetworkRequestService.instance.setDioClient(_jsonPlaceholderDio);

    _jsonPlaceholderDio.interceptors
        .add(NetworkTrackerRequestModifierInterceptor());
    _jsonPlaceholderDio.interceptors.add(NetworkTrackerInterceptor());
    _dummyJsonDio.interceptors.add(NetworkTrackerInterceptor());
  }

  void _makeDummyJsonRequest() async {
    try {
      final result = await _dummyJsonDio.get('/test');

      if (kDebugMode) {
        print('Request success: $result');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Request failed: $e');
      }
    }
  }

  void _makeJsonPlaceholderRequest() async {
    try {
      Response result;

      if (_selectedMethod == 'GET') {
        result = await _jsonPlaceholderDio.get(_selectedPath);
      } else {
        result = await _jsonPlaceholderDio.post(
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
      final result = await _jsonPlaceholderDio.get('/invalid-endpoint-404');
      if (kDebugMode) {
        print('Unexpected success: $result');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Expected failure occurred: $e');
      }
    }
  }

  void _makeRequest() async {
    switch (_selectedClient.value) {
      case _jsonPlaceholder:
        _makeJsonPlaceholderRequest();
        break;
      case _dummyJson:
        _makeDummyJsonRequest();
        break;
      default:
        return;
    }
  }

  List<String> _filteredPaths() {
    final paths = _allPaths.where((path) {
      if (_selectedMethod == 'POST') {
        return path == '/posts';
      }
      return true;
    }).toList();

    if (!paths.contains(_selectedPath)) {
      _selectedPath = paths.first;
    }

    return paths;
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: Text(widget.title),
      actions: [
        Tooltip(
          message: widget.isDarkMode ? 'Dark mode' : 'Light mode',
          child: IconButton(
            icon: Icon(
              widget.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            ),
            onPressed: () => widget.onThemeModeChanged(!widget.isDarkMode),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.list_alt),
          tooltip: 'Open tracker',
          onPressed: () => NetworkRequestsViewer.showPage(context: context),
        ),
      ],
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Request Playground',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Try different clients and endpoints to generate traffic for the tracker.',
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildCard({
    required Widget child,
  }) {
    return Card(
      child: Padding(
        padding: _cardPadding,
        child: child,
      ),
    );
  }

  Widget _buildClientCard(ThemeData theme) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Client',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _selectedClient.value,
            isExpanded: true,
            onChanged: (clientBaseUrl) => setState(() {
              _selectedClient.value = clientBaseUrl!;
            }),
            items: _baseUrls
                .map((clientBaseUrl) => DropdownMenuItem(
                      value: clientBaseUrl,
                      child: Text(
                        clientBaseUrl,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ))
                .toList(),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Dio client',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestSetupCard(ThemeData theme, List<String> filteredPaths) {
    return ValueListenableBuilder(
      valueListenable: _selectedClient,
      builder: (_, baseUrl, __) {
        if (baseUrl != _jsonPlaceholder) {
          return const SizedBox.shrink();
        }

        return _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Request Setup',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedMethod,
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
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedPath,
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
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionsCard(ThemeData theme) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Actions',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ValueListenableBuilder(
            valueListenable: _selectedClient,
            builder: (_, baseUrl, __) {
              if (baseUrl == _jsonPlaceholder) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent.withAlpha(180),
                      ),
                      onPressed: _makeRequest,
                      child: const Text('Make Request'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.withAlpha(180),
                      ),
                      onPressed: _makeErrorRequest,
                      child: const Text('Make Error Request'),
                    ),
                  ],
                );
              }

              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent.withAlpha(180),
                ),
                onPressed: _makeRequest,
                child: const Text('Make Request'),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredPaths = _filteredPaths();
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: _pagePadding,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxContentWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(theme),
                  const SizedBox(height: 20),
                  _buildClientCard(theme),
                  const SizedBox(height: _sectionSpacing),
                  _buildRequestSetupCard(theme, filteredPaths),
                  const SizedBox(height: _sectionSpacing),
                  _buildActionsCard(theme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
