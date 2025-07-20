
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
- **Good**: 100ms - 300ms
- **Fair**: 300ms - 1000ms
- **Poor**: > 1000ms

