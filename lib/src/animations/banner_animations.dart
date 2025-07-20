
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
