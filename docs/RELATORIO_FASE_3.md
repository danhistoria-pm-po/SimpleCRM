# Relatório de Execução — Fase 3 (Tema/Cores, Localização pt-BR, Modais Responsivos e Logout Único)

**Data de Geração:** 2026-11-14 (`-03:00`)
**Branch:** `feat/fase-3` (criada a partir da `main`)

---

## 1. Alterações por Etapa e por Arquivo

### Etapa A — Tema e Cores (verde-azulado) (`7ed685d`)
- **`lib/core/theme/app_colors.dart` (novo):** Centraliza os tokens da paleta verde-azulada (`primary: #0F766E`, `primaryDark: #115E59`, `primaryLight: #CCFBF1`, `background: #F6F8F8`, `surface: #FFFFFF`, `textPrimary: #0F172A`, `textSecondary: #475569`, `border: #E2E8F0`, semânticas `success: #166534`, `warning: #92400E`, `danger: #B91C1C`, `info: #0369A1` e etapas do funil `stage*`) e inclui funções de luminância relativa e razão de contraste WCAG 2.1.
- **`lib/core/theme/app_theme.dart` (novo):** Define `AppTheme.lightTheme` (Material 3) com `ColorScheme.fromSeed(seedColor: AppColors.primary).copyWith(primary: AppColors.primary, ...)`, `AppBarTheme` (fundo `primary`, texto branco), `ElevatedButtonThemeData`, `OutlinedButtonThemeData`, `TextButtonThemeData`, `FloatingActionButtonThemeData`, `InputDecorationTheme` (borda arredondada, foco em `primary`), `CardThemeData`, `DialogThemeData`, `SnackBarThemeData` e `BottomNavigationBarThemeData`.
- **`lib/main.dart`:** Aplica `theme: AppTheme.lightTheme` no `MaterialApp`.
- **`lib/home_page.dart`:** Substitui `Colors.indigo` e `Colors.grey` por `AppColors.primary` e `AppColors.textSecondary`.
- **`lib/modules/auth/pages/login_page.dart` e `lib/modules/auth/pages/register_page.dart`:** Substituem `Colors.blueAccent`, `Colors.grey[...]`, `Colors.black87`, `Colors.white`, `Colors.red` e `Colors.green` pelos tokens de `AppColors`.
- **`lib/modules/customers/presentation/customer_list_page.dart`:** Remove cores fixas de `AppBar`/`FAB` e substitui `Colors.indigo`, `Colors.indigo.shade100`, `Colors.redAccent`, `Colors.red` e `Colors.grey` por `AppColors`.
- **`lib/modules/pipeline/presentation/pipeline_page.dart`:** Aplica `AppColors.stagePotential`, `AppColors.stageNegotiation`, `AppColors.stageProposal`, `AppColors.stageActive` e `AppColors.stageLost` nas colunas do Kanban e `AppColors.danger` nos alertas/exclusão.
- **`lib/modules/pipeline/components/pipeline_column.dart`:** Substitui o cabeçalho saturado por cabeçalho neutro (`surface` `#FFFFFF` com texto `textPrimary` `#0F172A`), faixa superior de `4 px` na cor da etapa (`headerColor`) e contador em chip (`primaryLight` `#CCFBF1` com texto `primaryDark` `#115E59`).
- **`lib/modules/pipeline/components/deal_card.dart` e `lib/modules/pipeline/components/deal_form_modal.dart`:** Substituem `Colors.green`, `Colors.grey[700]`, `Colors.redAccent`, `Colors.black54`, `Colors.white` e `Colors.red.shade700` por tokens de `AppColors`.
- **`lib/modules/billing/presentation/billing_page.dart`, `lib/modules/cash_flow/presentation/cash_flow_page.dart` e `lib/features/follow_up/views/follow_up_view.dart`:** Substituem todas as cores fixas (`Colors.indigo`, `Colors.indigo.shade50`, `Colors.indigo.shade700`, `Colors.green`, `Colors.orange`, `Colors.red`, `Colors.redAccent`, `Colors.grey`) por tokens de `AppColors` (`primary`, `primaryLight`, `primaryDark`, `success`, `warning`, `danger`, `textSecondary`).
- **`test/theme_contrast_test.dart` (novo):** Verifica `AppTheme.lightTheme` e valida matematicamente o contraste WCAG AA ($\ge 4.5:1$) de todos os pares texto/fundo usados no app.

### Etapa B — Localização pt-BR (`dedfde7`)
- **`pubspec.yaml` e `pubspec.lock`:** Adicionados `flutter_localizations` (`sdk: flutter`) e `intl`.
- **`lib/main.dart`:** Configurados `locale: const Locale('pt', 'BR')`, `supportedLocales: const [Locale('pt', 'BR')]` e `localizationsDelegates` (`GlobalMaterialLocalizations`, `GlobalWidgetsLocalizations`, `GlobalCupertinoLocalizations`).
- **`lib/core/utils/formatters.dart` (novo):** Implementa `formatCurrency(double)` (`"R$ 1.500,00"`), `formatDate(DateTime)` (`"13/11/2026"`) e `parseCurrency(String)` (suportando `"1500"`, `"1500,50"`, `"1.500,50"` e `"1500.50"`, retornando `null` quando inválido).
- **`lib/modules/pipeline/components/deal_card.dart`, `lib/modules/pipeline/components/deal_form_modal.dart`, `lib/modules/billing/presentation/billing_page.dart`, `lib/modules/cash_flow/presentation/cash_flow_page.dart` e `lib/features/follow_up/views/follow_up_view.dart`:** Substituídos todos os `toStringAsFixed(2)`, `double.tryParse` de campos monetários e os 4 métodos `_formatDate` duplicados pelos utilitários centralizados de `formatters.dart`.
- **`lib/modules/auth/data/auth_repository.dart`, `lib/modules/auth/pages/login_page.dart`, `lib/modules/auth/pages/register_page.dart`, `lib/modules/billing/presentation/billing_page.dart`, `lib/modules/cash_flow/presentation/cash_flow_page.dart`, `lib/features/follow_up/views/follow_up_view.dart` e `lib/features/follow_up/controllers/follow_up_controller.dart`:** Textos padronizados para pt-BR (`"palavra-passe"` $\rightarrow$ `"senha"`, `"carateres"` $\rightarrow$ `"caracteres"`, `"Registe-se"` $\rightarrow$ `"Cadastre-se"`, `"Registar Conta"` $\rightarrow$ `"Cadastrar Conta"`, `"registado/registada/registo"` $\rightarrow$ `"cadastrado/cadastrada/registro"`, `"ecrã"` $\rightarrow$ `"tela"`, `"eliminar"` $\rightarrow$ `"excluir"`, `"Guardar"` $\rightarrow$ `"Salvar"`, `"terminar sessão"` $\rightarrow$ `"sair da conta"`).
- **`test/formatters_test.dart` (novo) e `test/widget_test.dart`:** Testes unitários para `formatCurrency`, `formatDate` e `parseCurrency` (casos válidos e inválidos) e atualização da asserção de moeda no `DealCard` para `'R$ 2.500,00'`.

### Etapa C — Modais Responsivos (`435da1a`)
- **`lib/modules/pipeline/components/deal_form_modal.dart`:** Removidos o `Material` com fundo manual e o `Container(width: 400)`. Refatorado para `AlertDialog` com `insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24)`, `ConstrainedBox(constraints: const BoxConstraints(maxWidth: 480))` e `SingleChildScrollView`.
- **`lib/modules/customers/presentation/customer_form_modal.dart`, `lib/modules/billing/presentation/billing_page.dart` (`_InvoiceFormDialog`), `lib/modules/cash_flow/presentation/cash_flow_page.dart` (`_CashFlowEntryFormDialog`) e `lib/features/follow_up/views/follow_up_view.dart` (`_FollowUpFormDialog`):** Padronizados com `insetPadding`, `ConstrainedBox(maxWidth: 480)`, `SingleChildScrollView`, `isExpanded: true` nos dropdowns e `Flexible` nos rótulos de data.
- **`test/widget_test.dart`:** Adicionado teste de widget que renderiza `DealFormModal` em viewport `320x568` com `viewInsets: EdgeInsets.only(bottom: 220)` simulando teclado aberto, verificando zero exceções de overflow.

### Etapa D — Logout Único (`c453847`)
- **`lib/core/widgets/logout_action.dart` (novo):** Centraliza o botão `"Sair"` da `AppBar`, o diálogo de confirmação `"Deseja sair da conta?"` (`"Cancelar"` / `"Sair"`) e a única chamada `_authController.logout()` do projeto.
- **`lib/modules/pipeline/presentation/pipeline_page.dart`, `lib/modules/customers/presentation/customer_list_page.dart`, `lib/modules/billing/presentation/billing_page.dart`, `lib/modules/cash_flow/presentation/cash_flow_page.dart` e `lib/features/follow_up/views/follow_up_view.dart`:** Removidas as 5 instâncias duplicadas de `AuthController`, seus `dispose()` e seus botões inline de logout, substituídos por `const LogoutAction()`. O reset de sessão (`CustomerController().reset()`) permanece acionado pelo listener `onAuthStateChange` em `lib/main.dart`.
- **`test/widget_test.dart`:** Adicionado teste de widget de `LogoutAction` validando que `"Cancelar"` não invoca `logout()` e `"Sair"` invoca `logout()` uma vez no fake de `AuthController`.

---

## 2. Tabela de Contraste WCAG AA ($\ge 4.5:1$)

> **Nota sobre ajuste de tom (Etapa A, item 6):**
> - `#15803D` (`success` original) apresentava contraste **5.02:1** sobre `#FFFFFF`, porém **4.46:1** sobre `primaryLight` (`#CCFBF1`, resumo do caixa) e **4.43:1** sobre o fundo suave do badge de status (`10% alpha` sobre branco = `#E8F2EC`). Foi ajustado para `#166534` (green-800), elevando o contraste para **6.57:1** no branco, **5.83:1** no `primaryLight` e **5.74:1** no badge `10% alpha`.
> - `#B45309` (`warning` original) apresentava contraste **5.02:1** sobre `#FFFFFF`, porém **4.43:1** sobre o fundo suave do badge de status (`10% alpha` sobre branco = `#F8EEE6`). Foi ajustado para `#92400E` (amber-800), elevando o contraste para **6.86:1** no branco e **6.02:1** no badge `10% alpha`.

| Par Texto / Fundo | Cores (Hex) | Contraste Calculado | Status WCAG AA ($\ge 4.5:1$) |
| :--- | :--- | :---: | :---: |
| `surface` sobre `primary` (AppBar, FAB, Botões) | `#FFFFFF` / `#0F766E` | **5.49:1** | Aprovado |
| `textPrimary` sobre `surface` (Cards, Cabeçalho Kanban, Modais) | `#0F172A` / `#FFFFFF` | **17.85:1** | Aprovado |
| `textPrimary` sobre `background` (Títulos Login/Cadastro) | `#0F172A` / `#F6F8F8` | **16.75:1** | Aprovado |
| `textSecondary` sobre `surface` (Subtítulos, Labels) | `#475569` / `#FFFFFF` | **7.58:1** | Aprovado |
| `textSecondary` sobre `background` (Textos secundários) | `#475569` / `#F6F8F8` | **7.11:1** | Aprovado |
| `textSecondary` sobre `primaryLight` (Rótulos Resumo Caixa) | `#475569` / `#CCFBF1` | **6.55:1** | Aprovado |
| `primaryDark` sobre `primaryLight` (Chip Contador Kanban / Avatar / Saldo Caixa) | `#115E59` / `#CCFBF1` | **6.53:1** | Aprovado |
| `success` (ajustado) sobre `surface` | `#166534` / `#FFFFFF` | **6.57:1** | Aprovado |
| `success` (ajustado) sobre `primaryLight` (Entradas Caixa) | `#166534` / `#CCFBF1` | **5.83:1** | Aprovado |
| `success` (ajustado) sobre badge `10% alpha` (`#E8F0EB`) | `#166534` / `#E8F0EB` | **5.74:1** | Aprovado |
| `warning` (ajustado) sobre `surface` | `#92400E` / `#FFFFFF` | **6.86:1** | Aprovado |
| `warning` (ajustado) sobre badge `10% alpha` (`#F4ECE7`) | `#92400E` / `#F4ECE7` | **6.02:1** | Aprovado |
| `danger` sobre `surface` | `#B91C1C` / `#FFFFFF` | **6.47:1** | Aprovado |
| `danger` sobre `primaryLight` (Saídas Caixa) | `#B91C1C` / `#CCFBF1` | **5.75:1** | Aprovado |
| `danger` sobre badge `10% alpha` (`#F8E8E8`) | `#B91C1C` / `#F8E8E8` | **5.70:1** | Aprovado |
| `info` (`stagePotential`) sobre `surface` | `#0369A1` / `#FFFFFF` | **5.93:1** | Aprovado |
| `stageProposal` sobre `surface` | `#6D28D9` / `#FFFFFF` | **7.02:1** | Aprovado |

---

## 3. Saídas Reais dos Comandos

### 3.1 `dart analyze`
```text
Analyzing SimpleCRM...
No issues found!
```

### 3.2 `flutter test`
```text
00:00 +0: loading C:/Jogos/SimpleCRM/test/controllers_test.dart
00:00 +0: C:/Jogos/SimpleCRM/test/controllers_test.dart: BillingController load, create, updateStatus otimista com reversao em falha
Erro ao atualizar status da fatura: Falha ao atualizar status
00:00 +1: C:/Jogos/SimpleCRM/test/controllers_test.dart: CashFlowController calcula entradas, saidas, saldo liquido e reverte exclusao se falhar
Erro ao excluir lançamento: Falha ao excluir lancamento
00:00 +2: C:/Jogos/SimpleCRM/test/controllers_test.dart: FollowUpController toggleReceived marca receivedDate e limpa receivedDate ao desmarcar
00:00 +3: C:/Jogos/SimpleCRM/test/controllers_test.dart: PipelineController erro nao propaga, refresh nao liga isLoading e updateDealStage faz rollback se falhar
Erro ao carregar do Supabase: Falha de rede no PipelineRepository
Erro ao atualizar estágio: Falha ao mover deal
00:00 +4: C:/Jogos/SimpleCRM/test/controllers_test.dart: CustomerController corrida de reset durante loadCustomers descarta resposta antiga e erro nao propaga
Erro no controller ao carregar clientes: Falha de rede em getCustomers
Erro ao remover cliente: Este cliente possui faturas ou follow-ups. Exclua-os antes de remover o cliente.
00:00 +5: loading C:/Jogos/SimpleCRM/test/formatters_test.dart
00:04 +5: C:/Jogos/SimpleCRM/test/formatters_test.dart: Etapa B — Formatters e parseCurrency (pt-BR) formatCurrency formata valores no padrão R$ 1.500,00
00:04 +6: C:/Jogos/SimpleCRM/test/formatters_test.dart: Etapa B — Formatters e parseCurrency (pt-BR) formatDate formata datas no padrão dd/MM/yyyy
00:04 +7: C:/Jogos/SimpleCRM/test/formatters_test.dart: Etapa B — Formatters e parseCurrency (pt-BR) parseCurrency aceita formatos válidos (1500, 1500,50, 1.500,50, 1500.50)
00:04 +8: C:/Jogos/SimpleCRM/test/formatters_test.dart: Etapa B — Formatters e parseCurrency (pt-BR) parseCurrency retorna null para entradas inválidas
00:04 +9: loading C:/Jogos/SimpleCRM/test/theme_contrast_test.dart
00:10 +9: C:/Jogos/SimpleCRM/test/theme_contrast_test.dart: Etapa A — Tema e Contraste WCAG AA (>= 4.5:1) AppTheme.lightTheme aplica primary #0F766E e background #F6F8F8
00:11 +10: C:/Jogos/SimpleCRM/test/theme_contrast_test.dart: Etapa A — Tema e Contraste WCAG AA (>= 4.5:1) Todos os pares texto/fundo usados no app atendem WCAG AA (>= 4.5:1)
00:11 +11: loading C:/Jogos/SimpleCRM/test/widget_test.dart
00:35 +11: C:/Jogos/SimpleCRM/test/widget_test.dart: DealCard exibe dados da oportunidade e aciona callbacks de etapa e exclusao
00:51 +12: C:/Jogos/SimpleCRM/test/widget_test.dart: DealFormModal usa ID (String) no dropdown e nao quebra ao recarregar clientes
00:53 +13: C:/Jogos/SimpleCRM/test/widget_test.dart: CustomerFormModal preenche, salva e descarta controllers sem erros
00:54 +14: C:/Jogos/SimpleCRM/test/widget_test.dart: DealFormModal renderiza em 320x568 com viewInsets de teclado sem overflow
00:54 +15: C:/Jogos/SimpleCRM/test/widget_test.dart: LogoutAction exibe confirmacao: Cancelar nao sai e Sair chama logout no fake
00:55 +16: All tests passed!
```

### 3.3 `flutter build web`
```text
Compiling lib\main.dart for the Web...                          
Wasm dry run succeeded. Consider building and testing your application with the `--wasm` flag. See docs for more info: https://docs.flutter.dev/platform-integration/web/wasm
Use --no-wasm-dry-run to disable these warnings.
Font asset "MaterialIcons-Regular.otf" was tree-shaken, reducing it from 1645184 to 10584 bytes (99.4% reduction). Tree-shaking can be disabled by providing the --no-tree-shake-icons flag when building your app.
Font asset "CupertinoIcons.ttf" was tree-shaken, reducing it from 257628 to 1472 bytes (99.4% reduction). Tree-shaking can be disabled by providing the --no-tree-shake-icons flag when building your app.
Compiling lib\main.dart for the Web...                            370,5s
√ Built build\web
```

---

## 4. Pendente de validação manual (usuário)

- [ ] aparência do tema verde-azulado nas 5 abas e no login;
- [ ] valores e datas em pt-BR em todas as telas;
- [ ] modal de oportunidade no celular/janela estreita;
- [ ] um único botão Sair com confirmação;
- [ ] fluxo completo de 2 usuários continua isolado.
