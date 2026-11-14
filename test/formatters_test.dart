// test/formatters_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_crm/core/utils/formatters.dart';

void main() {
  group('Etapa B — Formatters e parseCurrency (pt-BR)', () {
    test('formatCurrency formata valores no padrão R\$ 1.500,00', () {
      expect(formatCurrency(0), 'R\$ 0,00');
      expect(formatCurrency(1500), 'R\$ 1.500,00');
      expect(formatCurrency(1500.5), 'R\$ 1.500,50');
      expect(formatCurrency(1234567.89), 'R\$ 1.234.567,89');
    });

    test('formatDate formata datas no padrão dd/MM/yyyy', () {
      expect(formatDate(DateTime(2026, 11, 13)), '13/11/2026');
      expect(formatDate(DateTime(2026, 1, 5)), '05/01/2026');
    });

    test('parseCurrency aceita formatos válidos (1500, 1500,50, 1.500,50, 1500.50)', () {
      expect(parseCurrency('1500'), 1500.0);
      expect(parseCurrency('1500,50'), 1500.50);
      expect(parseCurrency('1.500,50'), 1500.50);
      expect(parseCurrency('1500.50'), 1500.50);
      expect(parseCurrency('R\$ 1.500,50'), 1500.50);
      expect(parseCurrency('  250,75  '), 250.75);
      expect(parseCurrency('1.000.000,00'), 1000000.0);
    });

    test('parseCurrency retorna null para entradas inválidas', () {
      expect(parseCurrency(''), isNull);
      expect(parseCurrency('   '), isNull);
      expect(parseCurrency('abc'), isNull);
      expect(parseCurrency('R\$'), isNull);
      expect(parseCurrency('15,00,50'), isNull);
      expect(parseCurrency('15.00.50'), isNull);
      expect(parseCurrency('1500,'), isNull);
      expect(parseCurrency('1500.'), isNull);
      expect(parseCurrency('1.50,00'), isNull);
    });
  });
}
