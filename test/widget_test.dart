import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_crm/core/widgets/logout_action.dart';
import 'package:simple_crm/core/widgets/tutorial_help_action.dart';
import 'package:simple_crm/features/follow_up/controllers/follow_up_controller.dart';
import 'package:simple_crm/features/follow_up/models/follow_up_model.dart';
import 'package:simple_crm/features/follow_up/repositories/follow_up_repository.dart';
import 'package:simple_crm/features/follow_up/views/follow_up_view.dart';
import 'package:simple_crm/home_page.dart';
import 'package:simple_crm/main.dart';
import 'package:simple_crm/modules/auth/controllers/auth_controller.dart';
import 'package:simple_crm/modules/auth/pages/register_page.dart';
import 'package:simple_crm/modules/customers/domain/entities/customer_entity.dart';
import 'package:simple_crm/modules/customers/presentation/customer_controller.dart';
import 'package:simple_crm/modules/customers/presentation/customer_form_modal.dart';
import 'package:simple_crm/modules/customers/presentation/customer_list_page.dart';
import 'package:simple_crm/modules/customers/repositories/customer_repository.dart';
import 'package:simple_crm/modules/pipeline/components/deal_card.dart';
import 'package:simple_crm/modules/pipeline/components/deal_form_modal.dart';
import 'package:simple_crm/modules/pipeline/controllers/pipeline_controller.dart';
import 'package:simple_crm/modules/pipeline/models/deal_entity.dart';
import 'package:simple_crm/modules/pipeline/presentation/pipeline_page.dart';
import 'package:simple_crm/modules/pipeline/repositories/pipeline_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _InMemoryCustomerRepository extends CustomerRepository {
  final List<Customer> initial;
  _InMemoryCustomerRepository(this.initial);

  @override
  Future<List<Customer>> getCustomers() async => List<Customer>.from(initial);

  @override
  Future<void> updateCustomer(Customer customer) async {
    final index = initial.indexWhere((c) => c.id == customer.id);
    if (index != -1) {
      initial[index] = customer;
    }
  }
}

class _InMemoryPipelineRepository extends PipelineRepository {
  final List<DealEntity> initial;
  _InMemoryPipelineRepository(this.initial);

  @override
  Future<List<DealEntity>> fetchDeals() async => initial;
}

class _InMemoryFollowUpRepository extends FollowUpRepository {
  final List<FollowUpModel> initial;
  _InMemoryFollowUpRepository(this.initial);

  @override
  Future<List<FollowUpModel>> getFollowUps() async =>
      List<FollowUpModel>.from(initial);

  @override
  Future<void> updateFollowUp(FollowUpModel followUp) async {
    final index = initial.indexWhere((f) => f.id == followUp.id);
    if (index != -1) {
      initial[index] = followUp;
    }
  }
}

class _FakeAuthController extends ChangeNotifier implements AuthController {
  int logoutCallCount = 0;
  int registerCallCount = 0;
  String? lastRegisteredEmail;

  @override
  bool get isLoading => false;

  @override
  String? get errorMessage => null;

  @override
  bool get isAuthenticated => true;

  @override
  Future<bool> login(String email, String password) async => true;

  @override
  Future<bool> register(String email, String password) async {
    registerCallCount++;
    lastRegisteredEmail = email;
    return true;
  }

  @override
  Future<void> logout() async {
    logoutCallCount++;
  }
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

  testWidgets('LogoutAction exibe confirmacao: Cancelar nao sai e Sair chama logout no fake', (
    WidgetTester tester,
  ) async {
    final fakeAuth = _FakeAuthController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            actions: [
              LogoutAction(authController: fakeAuth),
            ],
          ),
        ),
      ),
    );

    // Clicar no botão Sair e depois em Cancelar
    await tester.tap(find.byIcon(Icons.logout));
    await tester.pumpAndSettle();

    expect(find.text('Deseja sair da conta?'), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(fakeAuth.logoutCallCount, 0);

    // Clicar no botão Sair e confirmar
    await tester.tap(find.byIcon(Icons.logout));
    await tester.pumpAndSettle();

    expect(find.text('Deseja sair da conta?'), findsOneWidget);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sair'));
    await tester.pumpAndSettle();

    expect(fakeAuth.logoutCallCount, 1);
  });

  testWidgets('Micro-Sprint 4.1: AuthCheckPage instancia HomePage com ValueKey(user.id) e recria estado ao trocar de usuario', (
    WidgetTester tester,
  ) async {
    final authStreamController = StreamController<AuthState>.broadcast();
    addTearDown(() => authStreamController.close());

    Session buildFakeSession(String userId) {
      return Session(
        accessToken: 'fake-token-$userId',
        tokenType: 'bearer',
        user: User(
          id: userId,
          appMetadata: const {},
          userMetadata: const {},
          aud: 'authenticated',
          createdAt: DateTime(2026, 11, 15).toIso8601String(),
        ),
      );
    }

    final sessionA = buildFakeSession('user-a');
    Session? currentSession = sessionA;

    await tester.pumpWidget(
      MaterialApp(
        home: AuthCheckPage(
          authStateStream: authStreamController.stream,
          currentSessionGetter: () => currentSession,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Sessão ativa do usuário A -> HomePage instanciado com ValueKey('user-a')
    final homeFinderA = find.byType(HomePage);
    expect(homeFinderA, findsOneWidget);
    expect(tester.widget<HomePage>(homeFinderA).key, const ValueKey('user-a'));
    final stateUserA = tester.state(homeFinderA);

    // Muda para a aba Clientes (índice 1) na sessão do usuário A
    await tester.tap(find.text('Clientes'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar)).currentIndex,
      1,
    );

    // Troca para a sessão do usuário B
    final sessionB = buildFakeSession('user-b');
    currentSession = sessionB;
    authStreamController.add(AuthState(AuthChangeEvent.signedIn, sessionB));
    await tester.pumpAndSettle();

    final homeFinderB = find.byType(HomePage);
    expect(homeFinderB, findsOneWidget);
    expect(tester.widget<HomePage>(homeFinderB).key, const ValueKey('user-b'));
    final stateUserB = tester.state(homeFinderB);

    // Garante que o State do HomePage (e das 5 abas filhas) foi descartado e recriado do zero (volta para aba 0)
    expect(identical(stateUserA, stateUserB), isFalse);
    expect(
      tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar)).currentIndex,
      0,
    );
  });

  testWidgets('Micro-Sprint 4.2: PipelinePage filtra cards por busca e por etapa e limpa busca', (
    WidgetTester tester,
  ) async {
    final now = DateTime(2026, 11, 15);
    final deals = [
      DealEntity(
        id: 'd1',
        customerId: 'c1',
        customerName: 'Mercado Alfa',
        title: 'Consultoria Fiscal',
        value: 1500.0,
        stage: DealStage.potential,
        createdAt: now,
      ),
      DealEntity(
        id: 'd2',
        customerId: 'c2',
        customerName: 'Clínica Beta',
        title: 'Licença Anual CRM',
        value: 3200.0,
        stage: DealStage.proposalSent,
        createdAt: now,
      ),
    ];

    final pipelineController = PipelineController(
      repository: _InMemoryPipelineRepository(deals),
    );
    final customerController = CustomerController(
      repository: _InMemoryCustomerRepository([]),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: PipelinePage(
          controller: pipelineController,
          customerController: customerController,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Inicialmente os 2 cards aparecem
    expect(find.text('Consultoria Fiscal'), findsOneWidget);
    expect(find.text('Licença Anual CRM'), findsOneWidget);

    // Digitar na barra de busca pelo nome do cliente 'Clínica Beta'
    await tester.enterText(
      find.widgetWithText(TextField, 'Buscar por título ou cliente...'),
      'Clínica Beta',
    );
    await tester.pumpAndSettle();

    expect(find.text('Consultoria Fiscal'), findsNothing);
    expect(find.text('Licença Anual CRM'), findsOneWidget);

    // Clicar no botão de limpar busca (Icons.clear) restaura a listagem completa
    await tester.tap(find.byIcon(Icons.clear));
    await tester.pumpAndSettle();

    expect(find.text('Consultoria Fiscal'), findsOneWidget);
    expect(find.text('Licença Anual CRM'), findsOneWidget);

    // Filtrar por etapa 'Potencial' no dropdown
    await tester.tap(find.byType(DropdownButton<DealStage?>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Potencial').last);
    await tester.pumpAndSettle();

    expect(find.text('Consultoria Fiscal'), findsOneWidget);
    expect(find.text('Licença Anual CRM'), findsNothing);
  });

  testWidgets('Micro-Sprint 4.3: CustomerListPage exibe observacoes (notes) e edita cliente existente via CustomerFormModal', (
    WidgetTester tester,
  ) async {
    final now = DateTime(2026, 11, 15);
    final repo = _InMemoryCustomerRepository([
      Customer(
        id: 'c1',
        name: 'Padaria Estrela',
        phone: '11999991111',
        email: 'contato@estrela.com',
        address: 'Rua das Flores, 50',
        notes: 'Prefere atendimento no período da manhã',
        createdAt: now,
        updatedAt: now,
      ),
    ]);
    final customerController = CustomerController(repository: repo);

    await tester.pumpWidget(
      MaterialApp(
        home: CustomerListPage(controller: customerController),
      ),
    );
    await tester.pumpAndSettle();

    // Verifica que o nome, contato e observações (notes) aparecem no card
    expect(find.text('Padaria Estrela'), findsOneWidget);
    expect(
      find.text('11999991111 • contato@estrela.com • Rua das Flores, 50'),
      findsOneWidget,
    );
    expect(
      find.text('Prefere atendimento no período da manhã'),
      findsOneWidget,
    );

    // Clicar no botão Editar Cliente abre o CustomerFormModal preenchido
    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Editar Cliente'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Padaria Estrela'), findsOneWidget);
    expect(
      find.widgetWithText(TextField, 'Prefere atendimento no período da manhã'),
      findsOneWidget,
    );

    // Alterar nome e observações e salvar
    await tester.enterText(
      find.widgetWithText(TextField, 'Nome *'),
      'Padaria Estrela Ouro',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Observações'),
      'Contrato anual renovado',
    );
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    // Verifica que a lista foi atualizada com os novos dados
    expect(find.text('Padaria Estrela Ouro'), findsOneWidget);
    expect(find.text('Contrato anual renovado'), findsOneWidget);
  });

  testWidgets('Micro-Sprint 4.4: FollowUpView exibe e atualiza avaliacao de satisfacao (1 a 5 estrelas)', (
    WidgetTester tester,
  ) async {
    final now = DateTime(2026, 11, 15);
    final followUpRepo = _InMemoryFollowUpRepository([
      FollowUpModel(
        id: 'f1',
        customerId: 'c1',
        title: 'Onboarding Concluído',
        description: 'Verificar adaptação da equipe',
        scheduledDate: now,
        status: 'concluido',
        isReceived: true,
        createdAt: now,
      ),
    ]);
    final customerRepo = _InMemoryCustomerRepository([
      Customer(
        id: 'c1',
        name: 'Clínica Sol',
        createdAt: now,
        updatedAt: now,
      ),
    ]);

    final followUpController = FollowUpController(repository: followUpRepo);
    final customerController = CustomerController(repository: customerRepo);

    await tester.pumpWidget(
      MaterialApp(
        home: FollowUpView(
          controller: followUpController,
          customerController: customerController,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Inicialmente exibe 'Sem nota' e 5 estrelas vazias
    expect(find.text('Onboarding Concluído'), findsOneWidget);
    expect(find.text('Sem nota'), findsOneWidget);
    expect(find.byIcon(Icons.star_border), findsNWidgets(5));
    expect(find.byIcon(Icons.star), findsNothing);

    // Clicar na 4ª estrela define a nota 4/5
    await tester.tap(find.byKey(const ValueKey('follow-up-f1-star-4')));
    await tester.pumpAndSettle();

    expect(find.text('4/5'), findsOneWidget);
    expect(find.byIcon(Icons.star), findsNWidgets(4));
    expect(find.byIcon(Icons.star_border), findsNWidgets(1));
    expect(followUpController.followUps.first.satisfactionScore, 4);
  });

  testWidgets('Micro-Sprint 4.5: RegisterPage exige consentimento LGPD, exibe modal de termos e permite cadastro apos aceite', (
    WidgetTester tester,
  ) async {
    final fakeAuth = _FakeAuthController();

    await tester.pumpWidget(
      MaterialApp(
        home: RegisterPage(authController: fakeAuth),
      ),
    );
    await tester.pumpAndSettle();

    // Preencher e-mail e senha válidos sem marcar o checkbox LGPD
    await tester.enterText(
      find.widgetWithText(TextFormField, 'E-mail'),
      'novo@empresa.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Senha'),
      'senha123',
    );
    await tester.tap(find.text('Cadastrar Conta'));
    await tester.pumpAndSettle();

    // Não deve chamar register sem o aceite LGPD
    expect(fakeAuth.registerCallCount, 0);
    expect(
      find.text(
        'Você deve aceitar os Termos de Uso e a Política de Privacidade (LGPD) para criar a conta.',
      ),
      findsOneWidget,
    );

    // Abrir modal de leitura rápida dos Termos e Política (LGPD) e clicar em 'Li e Aceito'
    await tester.tap(find.text('Ler Termos e Política (LGPD)'));
    await tester.pumpAndSettle();

    expect(find.text('Termos de Uso e Privacidade (LGPD)'), findsOneWidget);
    await tester.tap(find.text('Li e Aceito'));
    await tester.pumpAndSettle();

    // Agora o checkbox está marcado; clicar em 'Cadastrar Conta' realiza o cadastro
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
    await tester.tap(find.text('Cadastrar Conta'));
    await tester.pumpAndSettle();

    expect(fakeAuth.registerCallCount, 1);
    expect(fakeAuth.lastRegisteredEmail, 'novo@empresa.com');
  });

  testWidgets('Tutorial de Imersao: exibe botao Assistir Video Tutorial e abre modal responsivo com link do Google Drive', (
    WidgetTester tester,
  ) async {
    String? launchedUrl;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            actions: [
              TutorialHelpAction(
                urlLauncher: (url) async {
                  launchedUrl = url;
                  return true;
                },
              ),
            ],
          ),
          body: TutorialQuickAccessBanner(
            urlLauncher: (url) async {
              launchedUrl = url;
              return true;
            },
          ),
        ),
      ),
    );

    expect(
      find.text('Assistir Vídeo Tutorial - Imersão SimpleCRM'),
      findsOneWidget,
    );

    // Clicar no ícone de Ajuda na AppBar abre o modal com o botão e o link do Google Drive
    await tester.tap(find.byIcon(Icons.help_outline));
    await tester.pumpAndSettle();

    expect(find.text('Ajuda — Imersão SimpleCRM'), findsOneWidget);
    expect(find.text(kTutorialVideoUrl), findsOneWidget);

    // Clicar no botão do modal aciona a abertura do link oficial do vídeo
    await tester.tap(find.byKey(const ValueKey('btn-modal-watch-tutorial')));
    await tester.pumpAndSettle();

    expect(
      launchedUrl,
      'https://drive.google.com/file/d/1cZTOqHp8ep5uqpEN_34VWIOzUbxrZfkg/view?usp=sharing',
    );
  });
}
