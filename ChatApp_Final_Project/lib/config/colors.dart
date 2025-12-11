import 'package:flutter/material.dart';

class AppColors {
  // WhatsApp Palette
  static const Color primary = Color(0xFF075E54);       // Dark Teal Green (AppBar)
  static const Color accent = Color(0xFF25D366);         // Bright Green (Action Buttons, Highlights)
  static const Color accentDark = Color(0xFF128C7E);     // Darker Teal for TabBar

  // Backgrounds
  static const Color background = Color(0xFFECE5DD);     // Chat Background
  static const Color appBackground = Color(0xFFFFFFFF);   // Main App BG
  static const Color scaffold = appBackground;
  static const Color card = Color(0xFFFFFFFF);

  // Text
  static const Color textDark = Color(0xFF000000);
  static const Color textLight = Color(0xFF999999);
  static const Color textHint = Color(0xFFB0B0B0);

  // Messages
  static const Color sentMessage = Color(0xFFDCF8C6);     // Sent Message Bubble
  static const Color receivedMessage = Color(0xFFFFFFFF);

  // Status
  static const Color online = Color(0xFF25D366);
  static const Color offline = Color(0xFF9E9E9E);
  static const Color typing = accent;

  // Actions
  static const Color error = Color(0xFFE53935);
  static const Color success = Color(0xFF43A047);

  // UI Elements
  static const Color divider = Color(0xFFF5F5F5);
  static const Color shadow = Color(0x1A000000);
  static const Color icon = Color(0xFF333333);         // Default icon color
  static const Color iconLight = Color(0xFFFFFFFF);     // Icons on dark backgrounds
  static const Color iconLightUnselected = Color(0xB3FFFFFF); // 70% white for unselected tabs
}
