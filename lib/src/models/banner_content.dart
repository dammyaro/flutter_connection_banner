
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
