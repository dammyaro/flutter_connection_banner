
/// Represents the current connection status of the device
enum ConnectionType {
  /// No internet connection available
  none,
  /// Connected via WiFi
  wifi,
  /// Connected via cellular/mobile data
  cellular,
  /// Connected via ethernet (desktop/web)
  ethernet,
  /// Connected via other means
  other,
}

/// Represents the quality of the internet connection
enum ConnectionQuality {
  /// No connection available
  none,
  /// Poor connection (high latency, low bandwidth)
  poor,
  /// Fair connection (moderate latency/bandwidth)
  fair,
  /// Good connection (low latency, good bandwidth)
  good,
  /// Excellent connection (very low latency, high bandwidth)
  excellent,
}

/// Comprehensive connection status information
class ConnectionStatus {
  /// Creates a new connection status
  const ConnectionStatus({
    required this.type,
    required this.quality,
    required this.isConnected,
    this.latency,
    this.lastCheck,
  });

  /// The type of connection
  final ConnectionType type;
  
  /// The quality of the connection
  final ConnectionQuality quality;
  
  /// Whether there is an active internet connection
  final bool isConnected;
  
  /// The latency in milliseconds (if available)
  final int? latency;
  
  /// When this status was last checked
  final DateTime? lastCheck;

  /// Creates a copy with updated values
  ConnectionStatus copyWith({
    ConnectionType? type,
    ConnectionQuality? quality,
    bool? isConnected,
    int? latency,
    DateTime? lastCheck,
  }) {
    return ConnectionStatus(
      type: type ?? this.type,
      quality: quality ?? this.quality,
      isConnected: isConnected ?? this.isConnected,
      latency: latency ?? this.latency,
      lastCheck: lastCheck ?? this.lastCheck,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConnectionStatus &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          quality == other.quality &&
          isConnected == other.isConnected &&
          latency == other.latency;

  @override
  int get hashCode =>
      type.hashCode ^
      quality.hashCode ^
      isConnected.hashCode ^
      latency.hashCode;

  @override
  String toString() {
    return 'ConnectionStatus(type: $type, quality: $quality, '
           'isConnected: $isConnected, latency: $latency)';
  }
}
