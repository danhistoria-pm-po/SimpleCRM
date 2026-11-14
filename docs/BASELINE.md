# Relatório de Baseline — Fase 0 (Verificação)

Data: 2026-11-12  
Branch: `fix/fases-0-2`

---

## 1. Saídas Reais dos Comandos

### 1.1 `flutter --version`
```text
Flutter 3.47.7 • channel stable • https://github.com/flutter/flutter.git
Framework • revision abaf9c5237 (5 weeks ago) • 2026-10-08 09:51:21 -0700
Engine • hash d8a2d6c768c334d53e16277f837970ffa1e2de81 (revision deb287481e) (1 months ago) • 2026-10-07 17:09:12.000Z
Tools • Dart 3.13.5 • DevTools 2.60.0
```

### 1.2 `flutter pub get`
```text
Resolving dependencies...
Downloading packages...
  app_links_linux 1.0.4 (1.0.5 available)
  crypto 3.0.7 (3.0.8 available)
  cupertino_icons 1.0.9 (2.0.0 available)
  jni 1.1.0 (1.1.2 available)
  material_color_utilities 0.13.0 (0.13.1 available)
  meta 1.18.3 (1.19.0 available)
  passkeys_platform_interface 2.10.0 (2.11.0 available)
  shared_preferences_android 2.5.1 (2.5.5 available)
  shared_preferences_foundation 2.5.7 (2.6.2 available)
  test_api 0.7.12 (0.7.15 available)
  vector_math 2.4.0 (2.4.4 available)
  web 1.1.1 (1.1.2 available)
Got dependencies!
12 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
```

### 1.3 `dart analyze`
```text
Analyzing SimpleCRM...
No issues found!
```
*(Nota: Os 2 avisos de depreciação `deprecated_member_use` de `value:` em `DropdownButtonFormField` no `deal_form_modal.dart` foram corrigidos para `initialValue:` durante a reintegração das Sprints 4 e 5).*

### 1.4 `flutter test`
```text
00:00 +0: loading C:/Jogos/SimpleCRM/test/widget_test.dart
00:00 +0: SimpleCRM domain entities instantiate and copyWith properly
00:00 +1: All tests passed!
```

### 1.5 `flutter build web`
```text
Compiling lib\main.dart for the Web...
Wasm dry run succeeded. Consider building and testing your application with the `--wasm` flag. See docs for more info: https://docs.flutter.dev/platform-integration/web/wasm
Use --no-wasm-dry-run to disable these warnings.
Font asset "CupertinoIcons.ttf" was tree-shaken, reducing it from 257628 to 1472 bytes (99.4% reduction). Tree-shaking can be disabled by providing the --no-tree-shake-icons flag when building your app.
Font asset "MaterialIcons-Regular.otf" was tree-shaken, reducing it from 1645184 to 10584 bytes (99.4% reduction). Tree-shaking can be disabled by providing the --no-tree-shake-icons flag when building your app.
Compiling lib\main.dart for the Web...                            444,0s
√ Built build\web
```

---

## 2. Diagnóstico do Que Falha ou Precisa de Correção (Pré-Fases 1 e 2)

Embora o código compile sem erros estáticos (`dart analyze` = 0 issues) e o build web conclua com sucesso, a inspeção de arquitetura, estado e segurança revelou os seguintes problemas que serão endereçados nas Fases 1 e 2:

1. **Exclusão de Cliente Não Atômica e Sem Bloqueio de Vínculos (Fase 1)**:
   - `CustomerRepository.deleteCustomer` executa dois `delete` separados no cliente (`deals` e depois `customers`) sem transação no banco e sem bloquear quando o cliente possui `invoices` ou `follow_ups`.
2. **Ausência de Diálogo de Confirmação Antes de Excluir (Fase 1)**:
   - As ações de exclusão em Clientes, Pipeline (Deals), Faturamento (Invoices), Fluxo de Caixa e Follow-up apagam o registro imediatamente ao clique, sem confirmação do usuário.
3. **Dropdowns de Cliente Usando Objeto/Dynamic (Fase 2)**:
   - `DealFormModal` usa `DropdownButtonFormField<dynamic>`, e `BillingPage`/`FollowUpView` usam `DropdownButtonFormField<Customer>` sem `==`/`hashCode` por `id` ou `String` (`customerId`), podendo causar erro de assertion do Flutter caso `CustomerController` recarregue instâncias enquanto o modal está aberto.
4. **Exceções Não Capturadas (`rethrow` em `loadCustomers` / `loadDeals`) (Fase 2)**:
   - `CustomerController._internal()` e `CustomerListPage.initState()` chamam `loadCustomers()` de forma fire-and-forget enquanto `loadCustomers()` faz `rethrow`, gerando `Unhandled Exception` caso a rede/Supabase falhe.
5. **Spinner de Tela Cheia em Atualizações Rápidas (Fase 2)**:
   - Mudar etapa de um `deal`, atualizar status de `invoice` ou marcar `follow_up` como recebido chama `load*()`, que liga `isLoading = true` e substitui toda a tela (incluindo o scroll horizontal do Kanban) por um `CircularProgressIndicator`.
6. **Bug ao Desmarcar `isReceived` em `FollowUpModel.copyWith` (Fase 2)**:
   - `receivedDate: receivedDate ?? this.receivedDate` impede limpar `receivedDate` para `null` quando o usuário desmarca o checkbox "Recebido".
7. **Ciclo de Vida e Corrida de Sessão em `main.dart` e Modais (Fase 2)**:
   - `StreamSubscription` de `onAuthStateChange` em `AuthCheckPage` não é guardada nem cancelada no `dispose()`.
   - Carga duplicada de clientes na abertura inicial e ausência de proteção contra respostas atrasadas (`generation token`) após `reset()` no logout.
   - `TextEditingController` instanciados dentro de métodos/builders de modais sem `dispose()`, e `PipelineController` sem `dispose()` em `PipelinePage`.
8. **Ordenação e Timezones nas Queries (Fase 2)**:
   - `customers`, `deals` e `invoices` fazem `.select()` sem `.order(...)` determinístico, e datas não padronizam `.toUtc().toIso8601String()` na escrita e `.toLocal()` na leitura.

---

## 3. Verificação de RLS no Supabase (`supabase/tests/rls_check.sql`)

O script de diagnóstico foi criado em [`supabase/tests/rls_check.sql`](../supabase/tests/rls_check.sql) e o estado real do banco de produção foi verificado:

- **RLS (`pg_tables.rowsecurity`)**: Ativo nas 5 tabelas (`customers`, `deals`, `invoices`, `cash_flow`, `follow_ups`).
- **Coluna `user_id` e Contagem de Linhas**:
  - `customers`: 6 linhas, possui coluna `user_id`.
  - `deals`: 6 linhas, possui coluna `user_id`.
  - `invoices`: 0 linhas, **SEM** coluna `user_id` (erro `42703`) e com `customer_id` do tipo `text` (enquanto `customers.id`, `deals.customer_id` e `follow_ups.customer_id` são `uuid`).
  - `cash_flow`: 0 linhas, **SEM** coluna `user_id`.
  - `follow_ups`: 0 linhas, **SEM** coluna `user_id`.
- **Policies Existentes (`pg_policies`)**:
  - `customers` e `deals`: policy `(auth.uid() = user_id)` atribuída a `roles {public}`.
  - `invoices` e `cash_flow`: **sem nenhuma policy** (bloqueio total com RLS ativo).
  - `follow_ups`: policy `"Enable all access for follow_ups"` com `USING (true)` e `WITH CHECK (true)` (**brecha crítica de segurança**, deve ser removida).

### 3.1 Aplicação e Validação da Migration da Fase 1 (Pós-Baseline)
- **Correção de histórico**: Em `2026-11-12` (inclusive às `20:45:18 -03:00`), apenas o diagnóstico inicial de baseline havia sido levantado; a migration **ainda não havia sido aplicada** nessa data.
- **Data/Hora real de aplicação em produção**: `2026-11-13`, por volta das `21:44 -03:00` (aplicada manualmente).
- **Validação no SQL Editor (`2026-11-13`)**:
  - 5 policies `*_owner_policy` ativas para `{authenticated}` (e policy aberta de `follow_ups` removida).
  - `user_id NOT NULL` confirmado nas 5 tabelas (`customers`, `deals`, `invoices`, `cash_flow`, `follow_ups`).
  - Função `public.delete_customer_safe` criada.
  - 3 Foreign Keys `ON DELETE RESTRICT` e `customer_id` do tipo `uuid` confirmados em `deals`, `follow_ups` e `invoices`.
- **Validação de 2 usuários (`2026-11-13`)**:
  - Teste de isolamento entre 2 usuários validado na prática: o Usuário B não vê dados do Usuário A e vice-versa nas 5 abas.
