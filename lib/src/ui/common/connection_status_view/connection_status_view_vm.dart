import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:network_tracker/src/services/connectivity/network_connectivity_service.dart';

/// View model that exposes connectivity updates for the status badge.
class ConnectionStatusViewVM {
  /// Connectivity service that produces connection state updates.
  final NetworkConnectivityService connectivityService =
      NetworkConnectivityService();

  /// Handles connection update events.
  late final StreamController<ConnectivityResult> onConnectionUpdate =
      connectivityService.onConnectionStatusChanged;

  /// Releases resources held by this instance.
  void dispose() {
    connectivityService.dispose();
  }
}

/// ConnectivityResultExt extension.
extension ConnectivityResultExt on ConnectivityResult {
  /// Icon representing this connectivity state.
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

  /// Foreground color used for text/icon over the connectivity badge.
  Color tintColor(ColorScheme scheme) {
    switch (this) {
      case ConnectivityResult.none:
        return scheme.onErrorContainer;
      case ConnectivityResult.vpn:
      case ConnectivityResult.other:
        return scheme.onTertiaryContainer;
      default:
        return scheme.onSecondaryContainer;
    }
  }

  /// Human-readable label for this connectivity state.
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

  /// Background color used for the connectivity badge.
  Color color(ColorScheme scheme) {
    switch (this) {
      case ConnectivityResult.none:
        return scheme.errorContainer;
      case ConnectivityResult.vpn:
        return scheme.tertiaryContainer;
      case ConnectivityResult.other:
        return scheme.tertiaryContainer;
      default:
        return scheme.secondaryContainer;
    }
  }
}
