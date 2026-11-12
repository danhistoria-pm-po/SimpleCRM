import 'package:flutter_test/flutter_test.dart';
import 'package:simple_crm/modules/customers/domain/entities/customer_entity.dart';
import 'package:simple_crm/modules/pipeline/models/deal_entity.dart';
import 'package:simple_crm/modules/billing/models/invoice_entity.dart';
import 'package:simple_crm/modules/cash_flow/models/cash_flow_entry_entity.dart';
import 'package:simple_crm/features/follow_up/models/follow_up_model.dart';

void main() {
  test('SimpleCRM domain entities instantiate and copyWith properly', () {
    final now = DateTime.now();

    final customer = Customer(
      id: 'c1',
      name: 'Empresa Alpha',
      email: 'contato@alpha.com',
      createdAt: now,
      updatedAt: now,
    );
    expect(customer.name, 'Empresa Alpha');

    final deal = DealEntity(
      id: 'd1',
      customerId: customer.id,
      customerName: customer.name,
      title: 'Contrato Anual',
      value: 5000.0,
      stage: DealStage.potential,
      createdAt: now,
    );
    expect(deal.copyWith(stage: DealStage.activeClient).stage, DealStage.activeClient);

    final invoice = InvoiceEntity(
      id: 'i1',
      customerId: customer.id,
      customerName: customer.name,
      amount: 5000.0,
      dueDate: now,
      createdAt: now,
    );
    expect(invoice.status, InvoiceStatus.pending);

    final entry = CashFlowEntryEntity(
      id: 'cf1',
      description: 'Recebimento Contrato Anual',
      amount: 5000.0,
      type: CashFlowType.income,
      date: now,
    );
    expect(entry.type, CashFlowType.income);

    final followUp = FollowUpModel(
      id: 'f1',
      customerId: customer.id,
      title: 'Validar satisfação 7 dias',
      scheduledDate: now,
      status: 'pendente',
      isReceived: false,
      createdAt: now,
    );
    expect(followUp.copyWith(isReceived: true).isReceived, isTrue);
  });
}
