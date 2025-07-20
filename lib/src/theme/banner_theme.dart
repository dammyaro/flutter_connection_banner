
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
