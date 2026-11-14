import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_crm/modules/customers/domain/entities/customer_entity.dart';
import 'package:simple_crm/modules/customers/presentation/customer_controller.dart';
import 'package:simple_crm/modules/customers/presentation/customer_form_modal.dart';
import 'package:simple_crm/modules/customers/repositories/customer_repository.dart';
import 'package:simple_crm/modules/pipeline/components/deal_card.dart';
import 'package:simple_crm/modules/pipeline/components/deal_form_modal.dart';
import 'package:simple_crm/modules/pipeline/models/deal_entity.dart';

class _InMemoryCustomerRepository extends CustomerRepository {
  final List<Customer> initial;
  _InMemoryCustomerRepository(this.initial);

  @override
  Future<List<Customer>> getCustomers() async => initial;
}

void main() {
  testWidgets('DealCard exibe dados da oportunidade e aciona callbacks de etapa e exclusao', (
    WidgetTester tester,
  ) async {
    DealStage? changedStage;
    String? deletedDealId;

    final deal = DealEntity(
      id: 'deal-1',
      customerId: 'cust-1',
      customerName: 'Padaria Central',
      title: 'Implantação ERP',
      value: 2500.0,
      stage: DealStage.potential,
      createdAt: DateTime(2026, 11, 12),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DealCard(
            deal: deal,
            onStageChanged: (stage) => changedStage = stage,
            onDelete: (id) => deletedDealId = id,
          ),
        ),
      ),
    );

    expect(find.text('Implantação ERP'), findsOneWidget);
    expect(find.text('Padaria Central'), findsOneWidget);
    expect(find.text('R\$ 2.500,00'), findsOneWidget);

    // Abrir menu popup e mudar para Cliente Ativo
    await tester.tap(find.byIcon(Icons.swap_horiz));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cliente Ativo'));
    await tester.pumpAndSettle();

    expect(changedStage, DealStage.activeClient);

    // Abrir menu popup e clicar em Excluir Oportunidade
    await tester.tap(find.byIcon(Icons.swap_horiz));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Excluir Oportunidade'));
    await tester.pumpAndSettle();

    expect(deletedDealId, 'deal-1');
  });

  testWidgets('DealFormModal usa ID (String) no dropdown e nao quebra ao recarregar clientes', (
    WidgetTester tester,
  ) async {
    final now = DateTime(2026, 11, 12);
    final repo = _InMemoryCustomerRepository([
      Customer(id: 'c1', name: 'Cliente Um', createdAt: now, updatedAt: now),
      Customer(id: 'c2', name: 'Cliente Dois', createdAt: now, updatedAt: now),
    ]);
    final customerController = CustomerController(repository: repo);
    await customerController.loadCustomers();

    DealEntity? savedDeal;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DealFormModal(
            customerController: customerController,
            onSave: (deal) => savedDeal = deal,
          ),
        ),
      ),
    );

    // Selecionar 'Cliente Um' no dropdown
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cliente Um').last);
    await tester.pumpAndSettle();

    // Recarregar clientes enquanto o modal está aberto (novas instâncias de Customer com mesmo id)
    await customerController.loadCustomers(silent: true);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Título da Oportunidade'),
      'Consultoria Mensal',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Valor (R\$)'),
      '1800',
    );

    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(savedDeal, isNotNull);
    expect(savedDeal!.customerId, 'c1');
    expect(savedDeal!.customerName, 'Cliente Um');
    expect(savedDeal!.title, 'Consultoria Mensal');
    expect(savedDeal!.value, 1800.0);
  });

  testWidgets('CustomerFormModal preenche, salva e descarta controllers sem erros', (
    WidgetTester tester,
  ) async {
    String? savedName;
    String? savedEmail;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomerFormModal(
            onSave: ({
              required name,
              phone,
              email,
              address,
              notes,
            }) {
              savedName = name;
              savedEmail = email;
            },
          ),
        ),
      ),
    );

    await tester.enterText(find.widgetWithText(TextField, 'Nome *'), 'Maria Silva');
    await tester.enterText(find.widgetWithText(TextField, 'E-mail'), 'maria@silva.com');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(savedName, 'Maria Silva');
    expect(savedEmail, 'maria@silva.com');
  });

  testWidgets('DealFormModal renderiza em 320x568 com viewInsets de teclado sem overflow', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final now = DateTime(2026, 11, 13);
    final repo = _InMemoryCustomerRepository([
      Customer(
        id: 'c1',
        name: 'Cliente Com Nome Muito Longo Para Testar Truncamento Em Tela Estreita',
        createdAt: now,
        updatedAt: now,
      ),
    ]);
    final customerController = CustomerController(repository: repo);
    await customerController.loadCustomers();

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 568),
            viewInsets: EdgeInsets.only(bottom: 220),
          ),
          child: Scaffold(
            body: DealFormModal(
              customerController: customerController,
              onSave: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Nova Oportunidade'), findsOneWidget);
  });
}
