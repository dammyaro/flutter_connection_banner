
import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/connection_status.dart';

/// Service responsible for detecting internet connectivity and quality
class ConnectionDetector {
  /// Creates a new connection detector
  ConnectionDetector({
    Connectivity? connectivity,
    List<String>? testEndpoints,
    Duration? timeout,
    Duration? checkInterval,
  })  : _connectivity = connectivity ?? Connectivity(),
        _testEndpoints = testEndpoints ?? _defaultEndpoints,
        _timeout = timeout ?? const Duration(seconds: 3),
        _checkInterval = checkInterval ?? const Duration(seconds: 5);

  /// Default endpoints for connectivity testing
  static const List<String> _defaultEndpoints = [
    'https://clients3.google.com/generate_204',
    'https://www.cloudflare.com',
    'https://httpbin.org/status/204',
  ];

  final List<String> _testEndpoints;
  final Duration _timeout;
  final Duration _checkInterval;
  final Connectivity _connectivity;
  
  StreamController<ConnectionStatus>? _controller;
  Timer? _timer;
  ConnectionStatus? _lastStatus;

  /// Stream of connection status updates
  Stream<ConnectionStatus> get onStatusChanged {
    _controller ??= StreamController<ConnectionStatus>.broadcast();
    return _controller!.stream;
  }

  /// Current connection status (cached)
  ConnectionStatus? get currentStatus => _lastStatus;

  /// Start monitoring connection status
  Future<void> startMonitoring() async {
    if (_timer != null) return; // Already monitoring

    // Initial check
    await _checkConnection();

    // Setup periodic checks
    _timer = Timer.periodic(_checkInterval, (_) => _checkConnection());

    // Listen to connectivity changes
    _connectivity.onConnectivityChanged.listen((_) {
      _checkConnection();
    });
  }

  /// Stop monitoring connection status
  void stopMonitoring() {
    _timer?.cancel();
    _timer = null;
    _controller?.close();
    _controller = null;
  }

  /// Manually check connection status
  Future<ConnectionStatus> checkConnection() async {
    return await _checkConnection();
  }

  /// Internal connection checking logic
  Future<ConnectionStatus> _checkConnection() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      final connectionType = _mapConnectivityResult(connectivityResult);

      if (connectivityResult == ConnectivityResult.none) {
        final status = ConnectionStatus(
          type: ConnectionType.none,
          quality: ConnectionQuality.none,
          isConnected: false,
          lastCheck: DateTime.now(),
        );
        _updateStatus(status);
        return status;
      }

      // Test actual internet connectivity
      final quality = await _testInternetQuality();
      final status = ConnectionStatus(
        type: connectionType,
        quality: quality,
        isConnected: quality != ConnectionQuality.none,
        lastCheck: DateTime.now(),
      );

      _updateStatus(status);
      return status;
    } catch (e) {
      debugPrint('ConnectionDetector: Error checking connection: $e');
      final status = ConnectionStatus(
        type: ConnectionType.none,
        quality: ConnectionQuality.none,
        isConnected: false,
        lastCheck: DateTime.now(),
      );
      _updateStatus(status);
      return status;
    }
  }

  /// Test internet quality by making actual HTTP requests
  Future<ConnectionQuality> _testInternetQuality() async {
    final stopwatch = Stopwatch()..start();
    
    for (final endpoint in _testEndpoints) {
      try {
        final response = await http.head(
          Uri.parse(endpoint),
          headers: {'Cache-Control': 'no-cache'},
        ).timeout(_timeout);

        stopwatch.stop();
        
        if (response.statusCode == 200 || response.statusCode == 204) {
          return _determineQualityFromLatency(stopwatch.elapsedMilliseconds);
        }
      } catch (e) {
        // Try next endpoint
        continue;
      }
    }

    return ConnectionQuality.none;
  }

  /// Determine connection quality based on latency
  ConnectionQuality _determineQualityFromLatency(int latencyMs) {
    if (latencyMs < 100) return ConnectionQuality.excellent;
    if (latencyMs < 300) return ConnectionQuality.good;
    if (latencyMs < 1000) return ConnectionQuality.fair;
    return ConnectionQuality.poor;
  }

  /// Map connectivity result to connection type
  ConnectionType _mapConnectivityResult(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        return ConnectionType.wifi;
      case ConnectivityResult.mobile:
        return ConnectionType.cellular;
      case ConnectivityResult.ethernet:
        return ConnectionType.ethernet;
      case ConnectivityResult.none:
        return ConnectionType.none;
      default:
        return ConnectionType.other;
    }
  }

  /// Update status and notify listeners
  void _updateStatus(ConnectionStatus status) {
    if (_lastStatus != status) {
      _lastStatus = status;
      _controller?.add(status);
    }
  }

  /// Dispose resources
  void dispose() {
    stopMonitoring();
  }
}
