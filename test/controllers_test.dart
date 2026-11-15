import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_crm/modules/billing/controllers/billing_controller.dart';
import 'package:simple_crm/modules/billing/models/invoice_entity.dart';
import 'package:simple_crm/modules/billing/repositories/billing_repository.dart';
import 'package:simple_crm/modules/cash_flow/controllers/cash_flow_controller.dart';
import 'package:simple_crm/modules/cash_flow/models/cash_flow_entry_entity.dart';
import 'package:simple_crm/modules/cash_flow/repositories/cash_flow_repository.dart';
import 'package:simple_crm/features/follow_up/controllers/follow_up_controller.dart';
import 'package:simple_crm/features/follow_up/models/follow_up_model.dart';
import 'package:simple_crm/features/follow_up/repositories/follow_up_repository.dart';
import 'package:simple_crm/modules/pipeline/controllers/pipeline_controller.dart';
import 'package:simple_crm/modules/pipeline/models/deal_entity.dart';
import 'package:simple_crm/modules/pipeline/repositories/pipeline_repository.dart';
import 'package:simple_crm/modules/customers/domain/entities/customer_entity.dart';
import 'package:simple_crm/modules/customers/presentation/customer_controller.dart';
import 'package:simple_crm/modules/customers/repositories/customer_repository.dart';

// ============================================================================
// FAKES DE REPOSITÓRIO (SEM TOCAR NO SUPABASE)
// ============================================================================

class FakeBillingRepository extends BillingRepository {
  List<InvoiceEntity> store = [];
  bool shouldFail = false;

  @override
  Future<List<InvoiceEntity>> fetchInvoices() async {
    if (shouldFail) throw Exception('Falha simulada no BillingRepository');
    return List<InvoiceEntity>.from(store);
  }

  @override
  Future<void> createInvoice(InvoiceEntity invoice) async {
    if (shouldFail) throw Exception('Falha ao criar fatura');
    store.add(invoice.copyWith(id: 'inv-${store.length + 1}'));
  }

  @override
  Future<void> updateInvoiceStatus(String id, InvoiceStatus newStatus) async {
    if (shouldFail) throw Exception('Falha ao atualizar status');
    final idx = store.indexWhere((i) => i.id == id);
    if (idx != -1) {
      store[idx] = store[idx].copyWith(status: newStatus);
    }
  }

  @override
  Future<void> deleteInvoice(String id) async {
    if (shouldFail) throw Exception('Falha ao deletar fatura');
    store.removeWhere((i) => i.id == id);
  }
}

class FakeCashFlowRepository extends CashFlowRepository {
  List<CashFlowEntryEntity> store = [];
  bool shouldFail = false;

  @override
  Future<List<CashFlowEntryEntity>> fetchEntries() async {
    if (shouldFail) throw Exception('Falha simulada no CashFlowRepository');
    return List<CashFlowEntryEntity>.from(store);
  }

  @override
  Future<void> createEntry(CashFlowEntryEntity entry) async {
    if (shouldFail) throw Exception('Falha ao criar lancamento');
    store.add(entry.copyWith(id: 'cf-${store.length + 1}'));
  }

  @override
  Future<void> deleteEntry(String id) async {
    if (shouldFail) throw Exception('Falha ao excluir lancamento');
    store.removeWhere((e) => e.id == id);
  }
}

class FakeFollowUpRepository extends FollowUpRepository {
  List<FollowUpModel> store = [];
  bool shouldFail = false;

  @override
  Future<List<FollowUpModel>> getFollowUps() async {
    if (shouldFail) throw Exception('Falha simulada no FollowUpRepository');
    return List<FollowUpModel>.from(store);
  }

  @override
  Future<void> addFollowUp(FollowUpModel followUp) async {
    if (shouldFail) throw Exception('Falha ao criar follow-up');
    store.add(followUp.copyWith(id: 'fu-${store.length + 1}'));
  }

  @override
  Future<void> updateFollowUp(FollowUpModel followUp) async {
    if (shouldFail) throw Exception('Falha ao atualizar follow-up');
    final idx = store.indexWhere((f) => f.id == followUp.id);
    if (idx != -1) {
      store[idx] = followUp;
    }
  }

  @override
  Future<void> deleteFollowUp(String id) async {
    if (shouldFail) throw Exception('Falha ao excluir follow-up');
    store.removeWhere((f) => f.id == id);
  }
}

class FakePipelineRepository extends PipelineRepository {
  List<DealEntity> store = [];
  bool shouldFail = false;

  @override
  Future<List<DealEntity>> fetchDeals() async {
    if (shouldFail) throw Exception('Falha de rede no PipelineRepository');
    return List<DealEntity>.from(store);
  }

  @override
  Future<void> createDeal(DealEntity deal) async {
    if (shouldFail) throw Exception('Falha ao criar deal');
    store.add(deal.copyWith(id: 'deal-${store.length + 1}'));
  }

  @override
  Future<void> updateDealStage(String id, DealStage newStage) async {
    if (shouldFail) throw Exception('Falha ao mover deal');
    final idx = store.indexWhere((d) => d.id == id);
    if (idx != -1) {
      store[idx] = store[idx].copyWith(stage: newStage);
    }
  }

  @override
  Future<void> deleteDeal(String id) async {
    if (shouldFail) throw Exception('Falha ao excluir deal');
    store.removeWhere((d) => d.id == id);
  }
}

class FakeCustomerRepository extends CustomerRepository {
  List<Customer> store = [];
  bool shouldFail = false;
  bool failWithVinculos = false;
  Completer<List<Customer>>? pendingFetchCompleter;

  @override
  Future<List<Customer>> getCustomers() async {
    if (pendingFetchCompleter != null) {
      return pendingFetchCompleter!.future;
    }
    if (shouldFail) throw Exception('Falha de rede em getCustomers');
    return List<Customer>.from(store);
  }

  @override
  Future<void> addCustomer(Customer customer) async {
    if (shouldFail) throw Exception('Falha ao adicionar cliente');
    store.add(customer.copyWith(id: 'cust-${store.length + 1}'));
  }

  @override
  Future<void> updateCustomer(Customer customer) async {
    if (shouldFail) throw Exception('Falha ao atualizar cliente');
    final idx = store.indexWhere((c) => c.id == customer.id);
    if (idx != -1) {
      store[idx] = customer;
    }
  }

  @override
  Future<void> deleteCustomer(String id) async {
    if (failWithVinculos) {
      throw Exception(
        'Este cliente possui faturas ou follow-ups. Exclua-os antes de remover o cliente.',
      );
    }
    if (shouldFail) throw Exception('Falha ao excluir cliente');
    store.removeWhere((c) => c.id == id);
  }
}

void main() {
  final now = DateTime(2026, 11, 12, 12, 0);

  group('BillingController', () {
    test('load, create, updateStatus otimista com reversao em falha', () async {
      final repo = FakeBillingRepository();
      final controller = BillingController(repository: repo);

      final created = await controller.createInvoice(
        InvoiceEntity(
          id: '',
          customerId: 'c1',
          customerName: 'Cliente A',
          amount: 1200.0,
          dueDate: now,
          createdAt: now,
        ),
      );
      expect(created, isTrue);
      expect(controller.invoices.length, 1);
      expect(controller.invoices.first.status, InvoiceStatus.pending);

      // Atualização otimista sem ligar isLoading
      bool sawLoadingTrue = false;
      controller.addListener(() {
        if (controller.isLoading) sawLoadingTrue = true;
      });

      final updated = await controller.updateInvoiceStatus(
        controller.invoices.first.id,
        InvoiceStatus.paid,
      );
      expect(updated, isTrue);
      expect(sawLoadingTrue, isFalse);
      expect(controller.invoices.first.status, InvoiceStatus.paid);

      // Se o repositório falhar, reverte o estado otimista e preenche errorMessage
      repo.shouldFail = true;
      final failedUpdate = await controller.updateInvoiceStatus(
        controller.invoices.first.id,
        InvoiceStatus.cancelled,
      );
      expect(failedUpdate, isFalse);
      expect(controller.invoices.first.status, InvoiceStatus.paid);
      expect(controller.errorMessage, isNotNull);
    });
  });

  group('CashFlowController', () {
    test('calcula entradas, saidas, saldo liquido e reverte exclusao se falhar', () async {
      final repo = FakeCashFlowRepository();
      final controller = CashFlowController(repository: repo);

      await controller.createEntry(
        CashFlowEntryEntity(
          id: '',
          description: 'Venda 1',
          amount: 1000.0,
          type: CashFlowType.income,
          date: now,
        ),
      );
      await controller.createEntry(
        CashFlowEntryEntity(
          id: '',
          description: 'Servidor',
          amount: 350.0,
          type: CashFlowType.expense,
          date: now,
        ),
      );

      expect(controller.totalIncome, 1000.0);
      expect(controller.totalExpense, 350.0);
      expect(controller.netBalance, 650.0);

      // Falha na exclusão reverte a lista
      repo.shouldFail = true;
      final deleted = await controller.deleteEntry(controller.entries.first.id);
      expect(deleted, isFalse);
      expect(controller.entries.length, 2);
      expect(controller.errorMessage, isNotNull);
    });
  });

  group('FollowUpController', () {
    test('toggleReceived marca receivedDate e limpa receivedDate ao desmarcar', () async {
      final repo = FakeFollowUpRepository();
      final controller = FollowUpController(repository: repo);

      await controller.addFollowUp(
        FollowUpModel(
          id: '',
          customerId: 'c1',
          title: 'Pós-venda inicial',
          scheduledDate: now,
          status: 'pendente',
          isReceived: false,
          createdAt: now,
        ),
      );
      expect(controller.followUps.length, 1);
      final item = controller.followUps.first;
      expect(item.receivedDate, isNull);

      // Marcar como recebido -> define receivedDate e status concluido
      final okMark = await controller.toggleReceived(item, true);
      expect(okMark, isTrue);
      expect(controller.followUps.first.isReceived, isTrue);
      expect(controller.followUps.first.status, 'concluido');
      expect(controller.followUps.first.receivedDate, isNotNull);

      // Desmarcar recebido -> DEVE limpar receivedDate para null e voltar a pendente
      final okUnmark = await controller.toggleReceived(
        controller.followUps.first,
        false,
      );
      expect(okUnmark, isTrue);
      expect(controller.followUps.first.isReceived, isFalse);
      expect(controller.followUps.first.status, 'pendente');
      expect(controller.followUps.first.receivedDate, isNull);
    });
  });

  group('PipelineController', () {
    test('erro nao propaga, refresh nao liga isLoading e updateDealStage faz rollback se falhar', () async {
      final repo = FakePipelineRepository();
      repo.store.add(
        DealEntity(
          id: 'd1',
          customerId: 'c1',
          customerName: 'Cliente 1',
          title: 'Oportunidade 1',
          value: 500.0,
          stage: DealStage.potential,
          createdAt: now,
        ),
      );

      final controller = PipelineController(repository: repo);

      // Carga inicial funciona
      final loaded = await controller.loadDeals();
      expect(loaded, isTrue);
      expect(controller.deals.length, 1);

      // Refresh silencioso NÃO liga isLoading
      bool sawLoadingDuringRefresh = false;
      controller.addListener(() {
        if (controller.isLoading) sawLoadingDuringRefresh = true;
      });
      await controller.loadDeals(silent: true);
      expect(sawLoadingDuringRefresh, isFalse);

      // Erro em loadDeals não propaga exceção não capturada
      repo.shouldFail = true;
      final failedLoad = await controller.loadDeals(silent: true);
      expect(failedLoad, isFalse);
      expect(controller.errorMessage, isNotNull);

      // Falha ao mover estágio reverte para o estágio original sem ligar isLoading
      final failedMove = await controller.updateDealStage(
        'd1',
        DealStage.activeClient,
      );
      expect(failedMove, isFalse);
      expect(sawLoadingDuringRefresh, isFalse);
      expect(controller.deals.first.stage, DealStage.potential);
    });
  });

  group('CustomerController', () {
    test('corrida de reset durante loadCustomers descarta resposta antiga e erro nao propaga', () async {
      final repo = FakeCustomerRepository();
      final completer = Completer<List<Customer>>();
      repo.pendingFetchCompleter = completer;

      final controller = CustomerController(repository: repo);

      // Dispara load em andamento para a sessão A
      final loadFuture = controller.loadCustomers();
      expect(controller.isLoading, isTrue);

      // Usuário faz logout (reset) antes de a requisição da sessão A terminar
      controller.reset();
      expect(controller.customers, isEmpty);
      expect(controller.isLoading, isFalse);

      // A requisição antiga da sessão A retorna dados atrasados
      completer.complete([
        Customer(
          id: 'c-old',
          name: 'Cliente Sessao Antiga',
          createdAt: now,
          updatedAt: now,
        ),
      ]);

      final loadResult = await loadFuture;
      expect(loadResult, isFalse);
      // Os dados da sessão antiga foram descartados!
      expect(controller.customers, isEmpty);

      // Testar que falha de rede e bloqueio CLIENTE_COM_VINCULOS não lançam exceção não capturada
      repo.pendingFetchCompleter = null;
      repo.shouldFail = true;
      final okLoad = await controller.loadCustomers();
      expect(okLoad, isFalse);
      expect(controller.errorMessage, contains('Falha de rede'));

      repo.shouldFail = false;
      repo.failWithVinculos = true;
      final okDelete = await controller.removeCustomer('c1');
      expect(okDelete, isFalse);
      expect(
        controller.errorMessage,
        'Este cliente possui faturas ou follow-ups. Exclua-os antes de remover o cliente.',
      );
    });

    test('updateCustomer atualiza dados e observacoes e trata erro sem propagar excecao', () async {
      final repo = FakeCustomerRepository();
      final controller = CustomerController(repository: repo);

      final added = await controller.addCustomer(
        name: 'Empresa Original',
        phone: '11999990000',
        email: 'contato@original.com',
        notes: 'Observação inicial',
      );
      expect(added, isTrue);
      expect(controller.customers.length, 1);
      final id = controller.customers.first.id;

      final updated = await controller.updateCustomer(
        id: id,
        name: 'Empresa Atualizada',
        phone: '11988887777',
        email: 'novo@atualizada.com',
        address: 'Av. Paulista, 1000',
        notes: 'Cliente VIP com contrato renovado',
      );
      expect(updated, isTrue);
      expect(controller.customers.first.name, 'Empresa Atualizada');
      expect(controller.customers.first.phone, '11988887777');
      expect(controller.customers.first.email, 'novo@atualizada.com');
      expect(controller.customers.first.address, 'Av. Paulista, 1000');
      expect(
        controller.customers.first.notes,
        'Cliente VIP com contrato renovado',
      );

      repo.shouldFail = true;
      final failedUpdate = await controller.updateCustomer(
        id: id,
        name: 'Tentativa Falha',
      );
      expect(failedUpdate, isFalse);
      expect(controller.errorMessage, contains('Falha ao atualizar cliente'));
    });
  });
}
