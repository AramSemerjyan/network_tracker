import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:network_tracker/src/services/connectivity/network_connectivity_service.dart';

class ConnectionStatusViewVM {
  final NetworkConnectivityService connectivityService =
      NetworkConnectivityService();

  late final StreamController<ConnectivityResult> onConnectionUpdate =
      connectivityService.onConnectionStatusChanged;

  void dispose() {
    connectivityService.dispose();
  }
}

extension ConnectivityResultExt on ConnectivityResult {
  IconData get icon {
    switch (this) {
      case ConnectivityResult.wifi:
        return Icons.wifi;
      case ConnectivityResult.ethernet:
        return Icons.settings_ethernet;
      case ConnectivityResult.mobile:
        return Icons.network_cell;
      case ConnectivityResult.vpn:
        return Icons.vpn_lock;
      case ConnectivityResult.other:
        return Icons.device_hub;
      case ConnectivityResult.none:
      default:
        return Icons.cancel;
    }
  }

  Color get tintColor {
    switch (this) {
      case ConnectivityResult.none:
        return Colors.red.shade800;
      case ConnectivityResult.vpn:
      case ConnectivityResult.other:
        return Colors.orange.shade800;
      default:
        return Colors.green.shade800;
    }
  }

  String get title {
    switch (this) {
      case ConnectivityResult.wifi:
        return 'Wi-Fi';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.mobile:
        return 'Mobile';
      case ConnectivityResult.vpn:
        return 'VPN';
      case ConnectivityResult.other:
        return 'Other';
      case ConnectivityResult.none:
        return 'None';
      default:
        return 'Unknown';
    }
  }

  Color get color {
    switch (this) {
      case ConnectivityResult.none:
        return Colors.red.shade300;
      case ConnectivityResult.vpn:
        return Colors.amber.shade300;
      case ConnectivityResult.other:
        return Colors.amber.shade300;
      default:
        return Colors.green.shade300;
    }
  }
}
