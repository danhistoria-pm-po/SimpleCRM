# Relatório Consolidado — Fases 0, 1 e 2 (SimpleCRM)

Data: 2026-11-12  
Branch: `fix/fases-0-2`

---

## 1. Alterações por Arquivo

### Fase 0 — Verificação e Reintegração (Commit `8a7d9f9`)
- [`docs/BASELINE.md`](BASELINE.md): Registro das saídas completas de `flutter --version`, `flutter pub get`, `dart analyze`, `flutter test` e `flutter build web`, além do diagnóstico de baseline do banco de produção.
- [`supabase/tests/rls_check.sql`](../supabase/tests/rls_check.sql): Consultas SQL de diagnóstico para as 5 tabelas (`customers`, `deals`, `invoices`, `cash_flow`, `follow_ups`): status de RLS (`pg_tables.rowsecurity`), policies (`pg_policies`), nullability/default de `user_id` e contagem de linhas com `user_id IS NULL`.
- [`lib/home_page.dart`](../lib/home_page.dart): Integração das 5 abas reais (`PipelinePage`, `CustomerListPage`, `BillingPage`, `CashFlowPage`, `FollowUpView`) no `IndexedStack`.
- `lib/modules/billing/*`, `lib/modules/cash_flow/*`, `lib/features/follow_up/*`: Módulos resgatados das Sprints 4 e 5 e conectados ao Supabase.

### Fase 1 — Integridade e Segurança (Commit `9528826`)
- [`supabase/migrations/20261112202500_fase1_integridade.sql`](../supabase/migrations/20261112202500_fase1_integridade.sql):
  - Ativação garantida de RLS nas 5 tabelas.
  - Adição de `user_id uuid NOT NULL DEFAULT auth.uid() REFERENCES auth.users(id) ON DELETE CASCADE` nas tabelas vazias (`invoices`, `cash_flow`, `follow_ups`).
  - Conversão segura de `invoices.customer_id` de `text` para `uuid` (com bloqueio se a tabela não estiver vazia).
  - Verificação de `user_id IS NULL` em `customers` e `deals` antes de aplicar `SET NOT NULL` e `SET DEFAULT auth.uid()`.
  - Remoção da policy aberta `"Enable all access for follow_ups"` e das policies legadas `{public}`, recriando policies padronizadas `FOR ALL TO authenticated USING ((select auth.uid()) = user_id) WITH CHECK ((select auth.uid()) = user_id)` nas 5 tabelas.
  - Criação de índices em `user_id`, `customer_id`, `date`, `scheduled_date` e `due_date`.
  - Configuração de Foreign Keys `ON DELETE RESTRICT` em `invoices.customer_id`, `follow_ups.customer_id` e `deals.customer_id`.
  - Criação da função RPC atômica `public.delete_customer_safe(p_customer_id uuid)` (`SECURITY INVOKER`, `search_path = public, pg_temp`), que lança `CLIENTE_COM_VINCULOS` se houver faturas ou follow-ups e, caso contrário, apaga os `deals` e o cliente na mesma transação.
  - Adição e validação de `CHECK` constraints (`NOT VALID` + `VALIDATE CONSTRAINT`) em `invoices`, `cash_flow` e `follow_ups`.
- [`supabase/migrations/20261112202500_fase1_rollback.sql`](../supabase/migrations/20261112202500_fase1_rollback.sql): Script de reversão não destrutivo.
- [`supabase/tests/rls_two_users.md`](../supabase/tests/rls_two_users.md): Roteiro manual e script SQL transacional (com `ROLLBACK`) para validar isolamento entre Usuário A e Usuário B e bloqueio de exclusão com vínculos.
- [`lib/modules/customers/repositories/customer_repository.dart`](../lib/modules/customers/repositories/customer_repository.dart): Substituição dos dois deletes soltos por `_supabase.rpc('delete_customer_safe', params: {'p_customer_id': id})` e tradução do erro `CLIENTE_COM_VINCULOS` para `"Este cliente possui faturas ou follow-ups. Exclua-os antes de remover o cliente."`.
- Diálogos de confirmação (`showDialog<bool>`) antes de qualquer exclusão em:
  - [`lib/modules/customers/presentation/customer_list_page.dart`](../lib/modules/customers/presentation/customer_list_page.dart)
  - [`lib/modules/pipeline/presentation/pipeline_page.dart`](../lib/modules/pipeline/presentation/pipeline_page.dart)
  - [`lib/modules/billing/presentation/billing_page.dart`](../lib/modules/billing/presentation/billing_page.dart)
  - [`lib/modules/cash_flow/presentation/cash_flow_page.dart`](../lib/modules/cash_flow/presentation/cash_flow_page.dart)
  - [`lib/features/follow_up/views/follow_up_view.dart`](../lib/features/follow_up/views/follow_up_view.dart)

### Fase 2 — Estabilidade de Estado e Testes (Commit `33cc557`)
- [`lib/main.dart`](../lib/main.dart): Guarda da `StreamSubscription<AuthState>` de `onAuthStateChange` com cancelamento em `dispose()`, uso de `ensureLoaded()` no `signedIn` e `reset()` no `signedOut`.
- [`lib/modules/customers/domain/entities/customer_entity.dart`](../lib/modules/customers/domain/entities/customer_entity.dart): Implementação de `operator ==` e `hashCode` por `id`.
- [`lib/modules/customers/presentation/customer_controller.dart`](../lib/modules/customers/presentation/customer_controller.dart):
  - Injeção opcional de `CustomerRepository`.
  - Remoção da chamada fire-and-forget no construtor e adição de `ensureLoaded()`.
  - Token de geração (`_generation`) incrementado em `reset()` para descartar respostas atrasadas de sessões encerradas.
  - Separação entre `isLoading` (carga inicial) e `isRefreshing` (atualização silenciosa), retorno `Future<bool>` e exposição de `errorMessage` sem `rethrow`.
- [`lib/modules/customers/presentation/customer_form_modal.dart`](../lib/modules/customers/presentation/customer_form_modal.dart): Convertido para `StatefulWidget` com `dispose()` de todos os `TextEditingController`.
- [`lib/modules/pipeline/controllers/pipeline_controller.dart`](../lib/modules/pipeline/controllers/pipeline_controller.dart) e [`lib/modules/pipeline/presentation/pipeline_page.dart`](../lib/modules/pipeline/presentation/pipeline_page.dart):
  - Injeção opcional de `PipelineRepository`, retorno `Future<bool>` sem `rethrow`, separação `isLoading`/`isRefreshing`.
  - Atualização e exclusão otimistas com reversão automática em caso de falha (sem acionar spinner de tela cheia e preservando o `ScrollController` horizontal do Kanban).
  - `dispose()` do `PipelineController`, `AuthController` e `ScrollController`.
- [`lib/modules/pipeline/components/deal_card.dart`](../lib/modules/pipeline/components/deal_card.dart): Correção de `RenderFlex overflow` no item de menu `"Excluir Oportunidade"` com `Flexible`.
- [`lib/modules/pipeline/components/deal_form_modal.dart`](../lib/modules/pipeline/components/deal_form_modal.dart), [`lib/modules/billing/presentation/billing_page.dart`](../lib/modules/billing/presentation/billing_page.dart) e [`lib/features/follow_up/views/follow_up_view.dart`](../lib/features/follow_up/views/follow_up_view.dart):
  - Dropdowns de cliente padronizados como `DropdownButtonFormField<String>` usando `customer.id` e `isExpanded: true`.
  - Modais extraídos em `StatefulWidget` dedicados (`_InvoiceFormDialog`, `_CashFlowEntryFormDialog`, `_FollowUpFormDialog`) com `dispose()` de todos os `TextEditingController`.
- [`lib/features/follow_up/models/follow_up_model.dart`](../lib/features/follow_up/models/follow_up_model.dart) e [`lib/features/follow_up/controllers/follow_up_controller.dart`](../lib/features/follow_up/controllers/follow_up_controller.dart):
  - Parâmetro `clearReceivedDate` em `copyWith` para limpar `receivedDate` (`null`) quando o usuário desmarca "Recebido".
  - `toggleReceived` retorna `Future<bool>` com atualização otimista, reversão em falha e `SnackBar` de erro na UI.
- Repositórios (`customer_repository.dart`, `pipeline_repository.dart`, `billing_repository.dart`, `cash_flow_repository.dart`, `follow_up_repository.dart`):
  - Ordenação determinística (`.order('name')` em `customers`, `.order('created_at', ascending: false)` em `deals`, `.order('due_date')` em `invoices`, `.order('date', ascending: false)` em `cash_flow`, `.order('scheduled_date')` em `follow_ups`).
  - Datas gravadas em UTC (`.toUtc().toIso8601String()`) e lidas em horário local (`DateTime.parse(...).toLocal()`).
- [`test/controllers_test.dart`](../test/controllers_test.dart) e [`test/widget_test.dart`](../test/widget_test.dart):
  - Testes unitários com fakes para `BillingController`, `CashFlowController`, `FollowUpController`, `PipelineController` e `CustomerController`.
  - Testes de widgets isolados (`DealCard`, `DealFormModal` com reload dinâmico de clientes e `CustomerFormModal`) sem chamadas de rede ao Supabase.

---

## 2. Saídas Reais de Verificação Final

### 2.1 `dart analyze`
```text
Analyzing SimpleCRM...
No issues found!
```

### 2.2 `flutter test`
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
00:00 +5: loading C:/Jogos/SimpleCRM/test/widget_test.dart
00:03 +5: C:/Jogos/SimpleCRM/test/widget_test.dart: DealCard exibe dados da oportunidade e aciona callbacks de etapa e exclusao
00:07 +6: C:/Jogos/SimpleCRM/test/widget_test.dart: DealFormModal usa ID (String) no dropdown e nao quebra ao recarregar clientes
00:09 +7: C:/Jogos/SimpleCRM/test/widget_test.dart: CustomerFormModal preenche, salva e descarta controllers sem erros
00:09 +8: All tests passed!
```

### 2.3 `flutter build web`
```text
Compiling lib\main.dart for the Web...
Wasm dry run succeeded. Consider building and testing your application with the `--wasm` flag. See docs for more info: https://docs.flutter.dev/platform-integration/web/wasm
Use --no-wasm-dry-run to disable these warnings.
Font asset "CupertinoIcons.ttf" was tree-shaken, reducing it from 257628 to 1472 bytes (99.4% reduction). Tree-shaking can be disabled by providing the --no-tree-shake-icons flag when building your app.
Font asset "MaterialIcons-Regular.otf" was tree-shaken, reducing it from 1645184 to 10584 bytes (99.4% reduction). Tree-shaking can be disabled by providing the --no-tree-shake-icons flag when building your app.
Compiling lib\main.dart for the Web...                            183,5s
√ Built build\web
```

---

## 3. Riscos Conhecidos e Pendências (Pós-Fase 2)

1. **Controllers de Abas Secundárias no Logout/Login**:
   - Como `HomePage` é recriada pelo `AuthCheckPage` ao alternar entre `LoginPage` e `HomePage`, as instâncias de `PipelineController`, `BillingController`, `CashFlowController` e `FollowUpController` são descartadas junto com as respectivas `State` das páginas no logout, enquanto o singleton `CustomerController` é limpo explicitamente via `reset()`.
2. **Escopo da Fase 3+ (Não incluído nesta entrega por regra de escopo)**:
   - Internacionalização/formatação monetária e de datas via `intl` (`pt_BR`).
   - Edição de clientes/oportunidades existentes e persistência de `Customer.status` no banco.
   - Barra de busca e filtro por etapa na UI da `PipelinePage` (os métodos já existem no `PipelineController`).

---

## 4. Passo a Passo de Rollback

### 4.1 Rollback do App (Git)
1. Para reverter apenas a Fase 2 mantendo a Fase 1:
   ```bash
   git revert <hash-commit-fase-2>
   ```
2. Para voltar integralmente ao estado da `main` anterior à branch `fix/fases-0-2`:
   ```bash
   git checkout main
   ```

### 4.2 Rollback do Banco de Dados (Supabase)
1. Caso seja necessário reverter as alterações de schema/constraints/RPC da Fase 1 no Supabase, execute no SQL Editor o arquivo:
   - [`supabase/migrations/20261112202500_fase1_rollback.sql`](../supabase/migrations/20261112202500_fase1_rollback.sql)
2. O script de rollback:
   - Remove as `CHECK` constraints adicionadas na Fase 1.
   - Remove a função `public.delete_customer_safe(uuid)`.
   - Reverte `invoices.customer_id` para `text` e restaura `ON DELETE CASCADE` em `follow_ups` e `deals`.
   - Remove os índices criados na Fase 1.
   - Mantém o RLS ativo nas 5 tabelas e **não** recria a policy aberta insegura de `follow_ups`.
