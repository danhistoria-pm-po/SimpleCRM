// test/theme_contrast_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_crm/core/theme/app_colors.dart';
import 'package:simple_crm/core/theme/app_theme.dart';

void main() {
  group('Etapa A — Tema e Contraste WCAG AA (>= 4.5:1)', () {
    test('AppTheme.lightTheme aplica primary #0F766E e background #F6F8F8', () {
      final theme = AppTheme.lightTheme;
      expect(theme.colorScheme.primary, const Color(0xFF0F766E));
      expect(theme.scaffoldBackgroundColor, const Color(0xFFF6F8F8));
      expect(theme.appBarTheme.backgroundColor, const Color(0xFF0F766E));
      expect(theme.appBarTheme.foregroundColor, const Color(0xFFFFFFFF));
    });

    test('Todos os pares texto/fundo usados no app atendem WCAG AA (>= 4.5:1)', () {
      // Simula alpha blending sobre surface (#FFFFFF) para os badges de status (10% alpha)
      final badgeSuccessBg = Color.alphaBlend(
        AppColors.success.withValues(alpha: 0.10),
        AppColors.surface,
      );
      final badgeWarningBg = Color.alphaBlend(
        AppColors.warning.withValues(alpha: 0.10),
        AppColors.surface,
      );
      final badgeDangerBg = Color.alphaBlend(
        AppColors.danger.withValues(alpha: 0.10),
        AppColors.surface,
      );

      final pairs = <String, (Color, Color)>{
        'primary sobre surface (#0F766E / #FFFFFF)': (
          AppColors.primary,
          AppColors.surface,
        ),
        'surface sobre primary (#FFFFFF / #0F766E - AppBar/FAB/Botões)': (
          AppColors.surface,
          AppColors.primary,
        ),
        'textPrimary sobre surface (#0F172A / #FFFFFF)': (
          AppColors.textPrimary,
          AppColors.surface,
        ),
        'textPrimary sobre background (#0F172A / #F6F8F8)': (
          AppColors.textPrimary,
          AppColors.background,
        ),
        'textSecondary sobre surface (#475569 / #FFFFFF)': (
          AppColors.textSecondary,
          AppColors.surface,
        ),
        'textSecondary sobre background (#475569 / #F6F8F8)': (
          AppColors.textSecondary,
          AppColors.background,
        ),
        'textSecondary sobre primaryLight (#475569 / #CCFBF1 - Resumo Caixa)': (
          AppColors.textSecondary,
          AppColors.primaryLight,
        ),
        'primaryDark sobre primaryLight (#115E59 / #CCFBF1 - Chip Kanban / Avatar / Saldo)': (
          AppColors.primaryDark,
          AppColors.primaryLight,
        ),
        'success sobre surface (#166534 / #FFFFFF)': (
          AppColors.success,
          AppColors.surface,
        ),
        'success sobre primaryLight (#166534 / #CCFBF1 - Entradas Caixa)': (
          AppColors.success,
          AppColors.primaryLight,
        ),
        'success sobre badge 10% alpha': (
          AppColors.success,
          badgeSuccessBg,
        ),
        'warning sobre surface (#92400E / #FFFFFF)': (
          AppColors.warning,
          AppColors.surface,
        ),
        'warning sobre badge 10% alpha': (
          AppColors.warning,
          badgeWarningBg,
        ),
        'danger sobre surface (#B91C1C / #FFFFFF)': (
          AppColors.danger,
          AppColors.surface,
        ),
        'danger sobre primaryLight (#B91C1C / #CCFBF1 - Saídas Caixa)': (
          AppColors.danger,
          AppColors.primaryLight,
        ),
        'danger sobre badge 10% alpha': (
          AppColors.danger,
          badgeDangerBg,
        ),
        'info sobre surface (#0369A1 / #FFFFFF)': (
          AppColors.info,
          AppColors.surface,
        ),
        'stageProposal sobre surface (#6D28D9 / #FFFFFF)': (
          AppColors.stageProposal,
          AppColors.surface,
        ),
      };

      for (final entry in pairs.entries) {
        final (fg, bg) = entry.value;
        final ratio = AppColors.contrastRatio(fg, bg);
        expect(
          ratio,
          greaterThanOrEqualTo(4.5),
          reason: '${entry.key} teve contraste ${ratio.toStringAsFixed(2)}:1 (< 4.5:1)',
        );
      }
    });
  });
}
