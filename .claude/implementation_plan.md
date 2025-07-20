# Flutter Connection Banner - Implementation Plan

## 🚀 Step-by-Step Implementation Guide

This document provides a complete roadmap for implementing the `flutter_connection_banner` package from scratch to production release.

---

## Phase 1: Project Setup & Foundation (v0.1.0)

### Step 1: Repository & Package Setup (Day 1)

#### 1.1 Create GitHub Repository
```bash
# Create repository
gh repo create flutter_connection_banner --public --description "Smart, beautiful internet connection banner for Flutter apps"

# Clone and setup
git clone https://github.com/dammyaro/flutter_connection_banner.git
cd flutter_connection_banner
```

#### 1.2 Initialize Flutter Package
```bash
# Create Flutter package
flutter create --template=package flutter_connection_banner
cd flutter_connection_banner

# Clean up generated files
rm -rf test/flutter_connection_banner_test.dart
rm -rf lib/flutter_connection_banner.dart
```

#### 1.3 Setup Package Structure
```bash
mkdir -p lib/src/{banner,detection,animations,theme}
mkdir -p test/{banner,detection,animations,theme}
mkdir -p example
mkdir -p doc
mkdir -p .github/{workflows,ISSUE_TEMPLATE}
```

#### 1.4 Create pubspec.yaml
```yaml
name: flutter_connection_banner
description: A smart, beautiful internet connection status banner for Flutter applications with contextual intelligence and premium UX.
version: 0.1.0
homepage: https://github.com/yourusername/flutter_connection_banner
repository: https://github.com/yourusername/flutter_connection_banner
issue_tracker: https://github.com/yourusername/flutter_connection_banner/issues

environment:
  sdk: '>=3.2.0 <4.0.0'
  flutter: ">=3.16.0"

dependencies:
  flutter:
    sdk: flutter
  connectivity_plus: ^5.0.2
  http: ^1.1.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  mockito: ^5.4.4
  build_runner: ^2.4.7

# Ensure proper pub.dev scoring
topics:
  - flutter
  - widget
  - internet
  - connectivity
  - banner
  - ui
  - networking

screenshots:
  - description: 'Basic connection banner in action'
    path: screenshots/basic_banner.png
  - description: 'Customized banner with actions'
    path: screenshots/custom_banner.png
```

#### 1.5 Create analysis_options.yaml
```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    # Additional strict rules for package quality
    public_member_api_docs: true
    lines_longer_than_80_chars: true
    avoid_classes_with_only_static_members: false

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
```

### Step 2: Core Architecture (Day 2)

#### 2.1 Create Connection Status Models
Create `lib/src/models/connection_status.dart`:
```dart
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
```

#### 2.2 Create Connection Detector Service
Create `lib/src/detection/connection_detector.dart`:
```dart
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
    List<String>? testEndpoints,
    Duration? timeout,
    Duration? checkInterval,
  })  : _testEndpoints = testEndpoints ?? _defaultEndpoints,
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
  final Connectivity _connectivity = Connectivity();
  
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
```

### Step 3: Banner UI Implementation (Day 3-4)

#### 3.1 Create Banner Animation Types
Create `lib/src/animations/banner_animations.dart`:
```dart
import 'package:flutter/material.dart';

/// Available animation styles for the connection banner
enum BannerAnimation {
  /// Material Design standard slide animation
  materialSlide,
  /// iOS-style notification animation
  iosNotification,
  /// Gentle fade in/out animation
  gentle,
  /// Attention-grabbing bounce animation
  attention,
}

/// Factory for creating banner animation controllers
class BannerAnimations {
  /// Create animation controller for the specified animation type
  static AnimationController createController({
    required BannerAnimation type,
    required TickerProvider vsync,
    Duration? duration,
  }) {
    final animationDuration = duration ?? _getDefaultDuration(type);
    return AnimationController(
      duration: animationDuration,
      vsync: vsync,
    );
  }

  /// Create the appropriate animation for the banner
  static Animation<Offset> createSlideAnimation({
    required BannerAnimation type,
    required AnimationController controller,
  }) {
    switch (type) {
      case BannerAnimation.materialSlide:
        return Tween<Offset>(
          begin: const Offset(0.0, -1.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOut,
        ));
      
      case BannerAnimation.iosNotification:
        return Tween<Offset>(
          begin: const Offset(0.0, -1.5),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: controller,
          curve: Curves.elasticOut,
        ));
      
      case BannerAnimation.gentle:
        return Tween<Offset>(
          begin: const Offset(0.0, -0.5),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOut,
        ));
      
      case BannerAnimation.attention:
        return Tween<Offset>(
          begin: const Offset(0.0, -1.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: controller,
          curve: Curves.bounceOut,
        ));
    }
  }

  /// Create fade animation for the banner
  static Animation<double> createFadeAnimation({
    required BannerAnimation type,
    required AnimationController controller,
  }) {
    switch (type) {
      case BannerAnimation.gentle:
        return Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOut,
        ));
      
      default:
        return Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(controller);
    }
  }

  /// Get default duration for animation type
  static Duration _getDefaultDuration(BannerAnimation type) {
    switch (type) {
      case BannerAnimation.materialSlide:
        return const Duration(milliseconds: 300);
      case BannerAnimation.iosNotification:
        return const Duration(milliseconds: 500);
      case BannerAnimation.gentle:
        return const Duration(milliseconds: 400);
      case BannerAnimation.attention:
        return const Duration(milliseconds: 600);
    }
  }
}
```

#### 3.2 Create Banner Theme
Create `lib/src/theme/banner_theme.dart`:
```dart
import 'package:flutter/material.dart';
import '../models/connection_status.dart';

/// Theme configuration for the connection banner
@immutable
class ConnectionBannerTheme {
  /// Creates a new banner theme
  const ConnectionBannerTheme({
    this.backgroundColor,
    this.textColor,
    this.iconColor,
    this.elevation = 4.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(8.0)),
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    this.margin = const EdgeInsets.all(8.0),
    this.textStyle,
    this.titleStyle,
    this.actionButtonStyle,
  });

  /// Background color of the banner
  final Color? backgroundColor;
  
  /// Text color
  final Color? textColor;
  
  /// Icon color
  final Color? iconColor;
  
  /// Banner elevation
  final double elevation;
  
  /// Border radius
  final BorderRadius borderRadius;
  
  /// Internal padding
  final EdgeInsets padding;
  
  /// External margin
  final EdgeInsets margin;
  
  /// Default text style
  final TextStyle? textStyle;
  
  /// Title text style
  final TextStyle? titleStyle;
  
  /// Action button style
  final ButtonStyle? actionButtonStyle;

  /// Create theme from color scheme
  factory ConnectionBannerTheme.fromColorScheme(
    ColorScheme colorScheme, {
    ConnectionStatus? status,
  }) {
    Color backgroundColor;
    Color textColor;
    
    // Choose colors based on connection status
    if (status?.isConnected == false) {
      backgroundColor = colorScheme.errorContainer;
      textColor = colorScheme.onErrorContainer;
    } else if (status?.quality == ConnectionQuality.poor) {
      backgroundColor = colorScheme.tertiaryContainer;
      textColor = colorScheme.onTertiaryContainer;
    } else {
      backgroundColor = colorScheme.surfaceVariant;
      textColor = colorScheme.onSurfaceVariant;
    }

    return ConnectionBannerTheme(
      backgroundColor: backgroundColor,
      textColor: textColor,
      iconColor: textColor,
      textStyle: TextStyle(
        color: textColor,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      titleStyle: TextStyle(
        color: textColor,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      actionButtonStyle: TextButton.styleFrom(
        foregroundColor: textColor,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  /// Default theme for offline status
  factory ConnectionBannerTheme.offline() {
    return const ConnectionBannerTheme(
      backgroundColor: Color(0xFFFFEBEE),
      textColor: Color(0xFFB71C1C),
      iconColor: Color(0xFFB71C1C),
    );
  }

  /// Default theme for poor connection
  factory ConnectionBannerTheme.poorConnection() {
    return const ConnectionBannerTheme(
      backgroundColor: Color(0xFFFFF3E0),
      textColor: Color(0xFFE65100),
      iconColor: Color(0xFFE65100),
    );
  }

  /// Copy with new values
  ConnectionBannerTheme copyWith({
    Color? backgroundColor,
    Color? textColor,
    Color? iconColor,
    double? elevation,
    BorderRadius? borderRadius,
    EdgeInsets? padding,
    EdgeInsets? margin,
    TextStyle? textStyle,
    TextStyle? titleStyle,
    ButtonStyle? actionButtonStyle,
  }) {
    return ConnectionBannerTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      iconColor: iconColor ?? this.iconColor,
      elevation: elevation ?? this.elevation,
      borderRadius: borderRadius ?? this.borderRadius,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      textStyle: textStyle ?? this.textStyle,
      titleStyle: titleStyle ?? this.titleStyle,
      actionButtonStyle: actionButtonStyle ?? this.actionButtonStyle,
    );
  }
}
```

#### 3.3 Create Banner Content Model
Create `lib/src/models/banner_content.dart`:
```dart
import 'package:flutter/material.dart';

/// Action that can be performed from the banner
class BannerAction {
  /// Creates a new banner action
  const BannerAction({
    required this.label,
    required this.onTap,
    this.icon,
  });

  /// Label for the action button
  final String label;
  
  /// Callback when action is tapped
  final VoidCallback onTap;
  
  /// Optional icon for the action
  final IconData? icon;

  /// Create a retry action
  factory BannerAction.retry(VoidCallback onRetry) {
    return BannerAction(
      label: 'Retry',
      icon: Icons.refresh,
      onTap: onRetry,
    );
  }

  /// Create a settings action
  factory BannerAction.settings(VoidCallback onSettings) {
    return BannerAction(
      label: 'Settings',
      icon: Icons.settings,
      onTap: onSettings,
    );
  }

  /// Create a dismiss action
  factory BannerAction.dismiss(VoidCallback onDismiss) {
    return BannerAction(
      label: 'Dismiss',
      icon: Icons.close,
      onTap: onDismiss,
    );
  }
}

/// Content configuration for the connection banner
class BannerContent {
  /// Creates new banner content
  const BannerContent({
    this.title,
    this.message,
    this.icon,
    this.actions = const [],
    this.showQualityIndicator = false,
  });

  /// Title text (optional)
  final String? title;
  
  /// Main message text
  final String? message;
  
  /// Leading icon
  final IconData? icon;
  
  /// Action buttons
  final List<BannerAction> actions;
  
  /// Whether to show connection quality indicator
  final bool showQualityIndicator;

  /// Create default content for offline status
  factory BannerContent.offline({
    List<BannerAction> actions = const [],
  }) {
    return BannerContent(
      title: 'No Internet Connection',
      message: 'Please check your connection and try again',
      icon: Icons.wifi_off,
      actions: actions,
    );
  }

  /// Create default content for poor connection
  factory BannerContent.poorConnection({
    List<BannerAction> actions = const [],
  }) {
    return BannerContent(
      title: 'Poor Connection',
      message: 'Some features may not work properly',
      icon: Icons.signal_wifi_bad,
      actions: actions,
      showQualityIndicator: true,
    );
  }

  /// Create content for restored connection
  factory BannerContent.connected() {
    return const BannerContent(
      message: 'Connection restored',
      icon: Icons.wifi,
    );
  }
}
```

### Step 6: Example App (Continued)

#### 6.1 Complete Example App
Continue `example/lib/main.dart`:
```dart
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Animation Style'),
                    DropdownButton<BannerAnimation>(
                      value: _selectedAnimation,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedAnimation = value);
                        }
                      },
                      items: BannerAnimation.values.map((animation) {
                        return DropdownMenuItem(
                          value: animation,
                          child: Text(animation.name),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Toggle Options
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CheckboxListTile(
                      title: const Text('Show Quality Indicator'),
                      value: _showQuality,
                      onChanged: (value) {
                        setState(() => _showQuality = value ?? false);
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Show Connected Banner'),
                      value: _showConnectedBanner,
                      onChanged: (value) {
                        setState(() => _showConnectedBanner = value ?? false);
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Example Content
            const Expanded(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sample App Content',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'This is a sample app to demonstrate the Connection Banner. '
                        'Try turning off your internet connection to see the banner in action!',
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Features:',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 8),
                      Text('• Automatic connection detection'),
                      Text('• Beautiful animations'),
                      Text('• Customizable themes'),
                      Text('• Quality indicators'),
                      Text('• Action buttons'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Connection Banner Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: ConnectionBanner(
        animation: _selectedAnimation,
        showQuality: _showQuality,
        showConnectedBanner: _showConnectedBanner,
        onConnectionChanged: (status) {
          setState(() {
            _currentStatus = status;
          });
        },
        child: _buildContent(),
      ),
    );
  }
}
```

#### 6.2 Create Example pubspec.yaml
Create `example/pubspec.yaml`:
```yaml
name: connection_banner_example
description: Example app for flutter_connection_banner package
version: 1.0.0+1
publish_to: 'none'

environment:
  sdk: '>=3.2.0 <4.0.0'
  flutter: ">=3.16.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_connection_banner:
    path: ../

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1

flutter:
  uses-material-design: true
```

### Step 7: Documentation & Quality (Day 8-9)

#### 7.1 Create README.md
```markdown
# Flutter Connection Banner

[![pub package](https://img.shields.io/pub/v/flutter_connection_banner.svg)](https://pub.dev/packages/flutter_connection_banner)
[![popularity](https://badges.bar/flutter_connection_banner/popularity)](https://pub.dev/packages/flutter_connection_banner/score)
[![likes](https://badges.bar/flutter_connection_banner/likes)](https://pub.dev/packages/flutter_connection_banner/score)
[![pub points](https://badges.bar/flutter_connection_banner/pub%20points)](https://pub.dev/packages/flutter_connection_banner/score)

A smart, beautiful internet connection status banner for Flutter applications with contextual intelligence and premium UX.

## ✨ Features

- **🧠 Smart Detection**: Real internet connectivity testing, not just network interface status
- **🎨 Beautiful UI**: Material Design 3 theming with customizable styles
- **⚡ Premium Animations**: Multiple animation styles (Material, iOS, Gentle, Attention)
- **📊 Quality Indicators**: Visual connection quality bars based on latency
- **🔄 Auto-Retry**: Built-in retry mechanisms with exponential backoff
- **🎯 Contextual**: Shows different messages based on connection quality
- **🛠 Customizable**: Full control over appearance, behavior, and content
- **📱 Cross-Platform**: Works on iOS, Android, Web, and Desktop

## 🚀 Quick Start

### Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_connection_banner: ^0.1.0
```

### Basic Usage

Wrap your app or any widget with `ConnectionBanner`:

```dart
import 'package:flutter_connection_banner/flutter_connection_banner.dart';

MaterialApp(
  home: ConnectionBanner.wrap(
    MyHomePage(),
  ),
)
```

### Advanced Configuration

```dart
ConnectionBanner(
  animation: BannerAnimation.iosNotification,
  showQuality: true,
  showConnectedBanner: true,
  duration: Duration(seconds: 4),
  theme: ConnectionBannerTheme.offline(),
  onConnectionChanged: (status) {
    print('Connection: ${status.type} - ${status.quality}');
  },
  child: MyApp(),
)
```

## 📖 Documentation

### Configuration Options

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `child` | `Widget` | required | Widget to display below banner |
| `animation` | `BannerAnimation` | `materialSlide` | Animation style for banner |
| `showQuality` | `bool` | `false` | Show connection quality indicator |
| `showConnectedBanner` | `bool` | `false` | Show brief banner when connected |
| `duration` | `Duration` | `5 seconds` | Auto-dismiss duration |
| `theme` | `ConnectionBannerTheme?` | `null` | Custom theme |
| `onConnectionChanged` | `Function?` | `null` | Connection status callback |

### Animation Styles

- `BannerAnimation.materialSlide` - Standard Material Design slide
- `BannerAnimation.iosNotification` - iOS-style elastic notification
- `BannerAnimation.gentle` - Subtle fade in/out
- `BannerAnimation.attention` - Attention-grabbing bounce

### Custom Theming

```dart
ConnectionBannerTheme(
  backgroundColor: Colors.red.shade100,
  textColor: Colors.red.shade800,
  iconColor: Colors.red.shade800,
  elevation: 8.0,
  borderRadius: BorderRadius.circular(12.0),
  padding: EdgeInsets.all(16.0),
)
```

### Custom Content

```dart
ConnectionBanner(
  customContent: (status) {
    if (!status.isConnected) {
      return BannerContent(
        title: 'Offline Mode',
        message: 'You\'re browsing cached content',
        icon: Icons.cloud_off,
        actions: [
          BannerAction.retry(() => _refreshData()),
          BannerAction.settings(() => _openSettings()),
        ],
      );
    }
    return null;
  },
  child: MyApp(),
)
```

## 🎯 Examples

### E-commerce App
```dart
ConnectionBanner(
  customContent: (status) => !status.isConnected 
    ? BannerContent(
        title: 'Offline Shopping',
        message: 'Browse products offline, sync when connected',
        actions: [BannerAction.retry(_syncCart)],
      )
    : null,
  child: ShoppingApp(),
)
```

### Social Media App
```dart
ConnectionBanner(
  animation: BannerAnimation.attention,
  showQuality: true,
  customContent: (status) {
    if (status.quality == ConnectionQuality.poor) {
      return BannerContent(
        title: 'Slow Connection',
        message: 'Images may load slowly',
        showQualityIndicator: true,
      );
    }
    return null;
  },
  child: SocialFeedApp(),
)
```

## 🔧 Advanced Features

### Connection Quality Detection

The package tests actual internet connectivity by making HTTP requests to reliable endpoints:

- Google's connectivity check
- Cloudflare
- HTTPBin

Quality is determined by response latency:
- **Excellent**: < 100ms