// lib/modules/billing/utils/nf_clipboard_helper.dart
import 'package:flutter/services.dart';
import '../../customers/domain/entities/customer_entity.dart';

class NfClipboardHelper {
  static Future<void> copyCustomerDataForNF(Customer customer) async {
    final formattedData = '''
=== DADOS PARA EMISSÃO DE NF ===
Nome/Razão Social: ${customer.name}
E-mail: ${customer.email ?? 'Não informado'}
Telefone: ${customer.phone ?? 'Não informado'}
Endereço: ${customer.address ?? 'Não informado'}
================================
''';

    await Clipboard.setData(ClipboardData(text: formattedData));
  }
}