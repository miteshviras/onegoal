import 'package:flutter/material.dart';

/// App color definitions derived from the Google Stitch "Mindful Daily Goal Planner"
/// design system ("Behavior-First Productivity").
class AppColors {
  // --- Dark Graphite Theme (Primary / Default) ---
  static const Color darkBackground = Color(0xFF111319);
  static const Color darkSurface = Color(0xFF111319);
  static const Color darkSurfaceContainerLowest = Color(0xFF0C0E14);
  static const Color darkSurfaceContainerLow = Color(0xFF191C22);
  static const Color darkSurfaceContainer = Color(0xFF1D2026);
  static const Color darkSurfaceContainerHigh = Color(0xFF272A30);
  static const Color darkSurfaceContainerHighest = Color(0xFF32353B);
  
  static const Color darkOnSurface = Color(0xFFE1E2EB);
  static const Color darkOnSurfaceVariant = Color(0xFFC2C6D5);
  static const Color darkOutline = Color(0xFF8C909E);
  static const Color darkOutlineVariant = Color(0xFF424753);

  // --- Light "Paper Studio" Theme ---
  static const Color lightBackground = Color(0xFFFAF9F6);
  static const Color lightSurface = Color(0xFFFAF9F6);
  static const Color lightSurfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color lightSurfaceContainerLow = Color(0xFFF6F2F7);
  static const Color lightSurfaceContainer = Color(0xFFF0EDF1);
  static const Color lightSurfaceContainerHigh = Color(0xFFEAE7EB);
  static const Color lightSurfaceContainerHighest = Color(0xFFE4E1E6);

  static const Color lightOnSurface = Color(0xFF1B1B1E);
  static const Color lightOnSurfaceVariant = Color(0xFF444651);
  static const Color lightOutline = Color(0xFF757682);
  static const Color lightOutlineVariant = Color(0xFFC5C5D3);

  // --- Brand Accents & Semantic Colors ---
  static const Color primary = Color(0xFFACC7FF);
  static const Color primaryDark = Color(0xFF00236F);
  static const Color primaryContainer = Color(0xFF0E5FC3);
  static const Color onPrimaryContainer = Color(0xFFD2DEFF);

  static const Color secondary = Color(0xFFAEC6FF);
  static const Color secondaryContainer = Color(0xFF25457F);
  
  static const Color tertiary = Color(0xFFFFB68A); // Soft Coral Amber
  static const Color tertiaryContainer = Color(0xFF9E4A00);

  // Semantic
  static const Color successEmerald = Color(0xFF10B981);
  static const Color successEmeraldDark = Color(0xFF059669);
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color errorMuted = Color(0xFFEF4444);
  
  // Motivational Moments Accent Gradient
  static const Color accentPurpleStart = Color(0xFF7C3AED);
  static const Color accentIndigoEnd = Color(0xFF4F46E5);

  // Design Tokens & Fidelity Aliases
  static const Color fidelityDarkBackground = darkBackground;
  static const Color fidelityDarkCard = darkSurfaceContainerLow;
  static const Color fidelityDarkBorder = darkOutlineVariant;
  static const Color fidelityDarkAccent = primary;
  static const Color fidelityDarkText = darkOnSurface;
  static const Color fidelityDarkMutedText = darkOnSurfaceVariant;
  static const Color fidelityCyan = Color(0xFF38BDF8);
  static const Color fidelityEmerald = successEmerald;

  static const Color fidelityLightBackground = lightBackground;
  static const Color fidelityLightCard = lightSurfaceContainerLowest;
  static const Color fidelityLightBorder = lightOutlineVariant;
  static const Color fidelityLightAccent = primaryContainer;
  static const Color fidelityLightText = lightOnSurface;
  static const Color fidelityLightMutedText = lightOnSurfaceVariant;
}
