// lib/core/theme/app_colors.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Identidade visual principal (Teal)
  static const Color primary = Color(0xFF0F766E); // teal-700
  static const Color primaryDark = Color(0xFF115E59); // teal-800
  static const Color primaryLight = Color(0xFFCCFBF1); // teal-100

  // Superfícies e neutros
  static const Color background = Color(0xFFF6F8F8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF0F172A); // slate-900
  static const Color textSecondary = Color(0xFF475569); // slate-600
  static const Color border = Color(0xFFE2E8F0); // slate-200
  static const Color overlay = Color(0x8A000000);

  // Cores semânticas
  // Nota de contraste WCAG AA (>= 4.5:1):
  // - #15803D sobre #FFFFFF = 5.02:1, mas sobre primaryLight (#CCFBF1) = 4.46:1
  //   e sobre fundo de badge com 10% alpha (#E8F2EC) = 4.43:1 (< 4.5:1).
  //   Ajustado para #166534 (green-800): 6.57:1 no branco, 5.83:1 no primaryLight
  //   e 5.74:1 no badge 10% alpha.
  // - #B45309 sobre #FFFFFF = 5.02:1, mas sobre fundo de badge com 10% alpha
  //   (#F8EEE6) = 4.43:1 (< 4.5:1).
  //   Ajustado para #92400E (amber-800): 6.86:1 no branco e 6.02:1 no badge 10% alpha.
  static const Color success = Color(0xFF166534);
  static const Color warning = Color(0xFF92400E);
  static const Color danger = Color(0xFFB91C1C);
  static const Color info = Color(0xFF0369A1);

  // Cores das etapas do Funil (Kanban)
  static const Color stagePotential = info;
  static const Color stageNegotiation = warning;
  static const Color stageProposal = Color(0xFF6D28D9);
  static const Color stageActive = success;
  static const Color stageLost = danger;

  /// Calcula a luminância relativa (WCAG 2.1) de uma cor.
  static double relativeLuminance(Color color) {
    double channelLuminance(double channel) {
      return channel <= 0.03928
          ? channel / 12.92
          : math.pow((channel + 0.055) / 1.055, 2.4).toDouble();
    }

    final r = channelLuminance(color.r);
    final g = channelLuminance(color.g);
    final b = channelLuminance(color.b);
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  /// Calcula a razão de contraste WCAG 2.1 entre [foreground] e [background].
  static double contrastRatio(Color foreground, Color background) {
    final l1 = relativeLuminance(foreground);
    final l2 = relativeLuminance(background);
    final brightest = math.max(l1, l2);
    final darkest = math.min(l1, l2);
    return (brightest + 0.05) / (darkest + 0.05);
  }
}
