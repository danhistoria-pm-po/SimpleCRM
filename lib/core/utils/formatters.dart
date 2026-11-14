// lib/core/utils/formatters.dart
import 'package:intl/intl.dart';

class AppFormatters {
  AppFormatters._();

  static final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: r'R$',
    decimalDigits: 2,
  );

  static final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy');

  /// Formata um valor numérico como moeda em Real brasileiro: "R$ 1.500,00".
  static String formatCurrency(double value) {
    return _currencyFormatter.format(value).replaceAll('\u00A0', ' ');
  }

  /// Formata uma data no padrão brasileiro: "13/11/2026".
  static String formatDate(DateTime date) {
    return _dateFormatter.format(date);
  }

  /// Converte entradas monetárias em pt-BR ou decimal simples para [double]:
  /// Aceita "1500", "1500,50", "1.500,50", "1500.50", "R$ 1.500,50".
  /// Retorna `null` se a string for vazia ou inválida.
  static double? parseCurrency(String raw) {
    var cleaned = raw.trim();
    if (cleaned.isEmpty) return null;

    if (cleaned.startsWith(r'R$')) {
      cleaned = cleaned.substring(2).trim();
    }

    if (cleaned.isEmpty) return null;

    // Permite apenas dígitos, pontos, vírgulas e sinal negativo opcional no início
    if (!RegExp(r'^-?\d[\d.,]*$').hasMatch(cleaned)) {
      return null;
    }

    final hasComma = cleaned.contains(',');
    final hasDot = cleaned.contains('.');

    if (hasComma && hasDot) {
      final lastComma = cleaned.lastIndexOf(',');
      final lastDot = cleaned.lastIndexOf('.');
      if (lastComma > lastDot) {
        // Formato pt-BR: "1.500,50" -> pontos são separadores de milhar, vírgula é decimal
        final parts = cleaned.split(',');
        if (parts.length != 2) return null;
        // Valida agrupamento de milhar quando há ponto
        if (!RegExp(r'^-?\d{1,3}(\.\d{3})+$').hasMatch(parts[0])) {
          return null;
        }
        cleaned = '${parts[0].replaceAll('.', '')}.${parts[1]}';
      } else {
        // Formato en-US: "1,500.50"
        final parts = cleaned.split('.');
        if (parts.length != 2) return null;
        if (!RegExp(r'^-?\d{1,3}(,\d{3})+$').hasMatch(parts[0])) {
          return null;
        }
        cleaned = '${parts[0].replaceAll(',', '')}.${parts[1]}';
      }
    } else if (hasComma) {
      // Apenas vírgula: "1500,50"
      final parts = cleaned.split(',');
      if (parts.length != 2 || parts[1].isEmpty) return null;
      cleaned = '${parts[0]}.${parts[1]}';
    } else if (hasDot) {
      // Apenas ponto: pode ser decimal ("1500.50") ou múltiplos pontos inválidos ("1.2.3")
      final parts = cleaned.split('.');
      if (parts.length > 2) {
        // Se forem múltiplos pontos de milhar sem centavos (ex: "1.000.000")
        if (RegExp(r'^-?\d{1,3}(\.\d{3})+$').hasMatch(cleaned)) {
          cleaned = cleaned.replaceAll('.', '');
        } else {
          return null;
        }
      } else if (parts[1].isEmpty) {
        return null;
      }
    }

    final parsed = double.tryParse(cleaned);
    if (parsed == null || parsed.isNaN || parsed.isInfinite) {
      return null;
    }
    return parsed;
  }
}

String formatCurrency(double value) => AppFormatters.formatCurrency(value);

String formatDate(DateTime date) => AppFormatters.formatDate(date);

double? parseCurrency(String raw) => AppFormatters.parseCurrency(raw);
