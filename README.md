# SimpleCRM — Produtividade PME

Aplicação **Flutter + Supabase** focada em gestão comercial enxuta para Pequenas e Médias Empresas (PMEs), cobrindo desde a prospecção no funil de vendas até faturamento, fluxo de caixa e pós-venda.

## Funcionalidades e Módulos

1. **Autenticação & Multi-usuário (`lib/modules/auth/`)**
   - Login e registo com Supabase Auth (`signInWithPassword`, `signUp`, `signOut`).
   - Proteção de rotas reativa via `AuthCheckPage` (`onAuthStateChange`).
   - Isolamento de dados por utilizador via Row Level Security (RLS / `auth.uid()`).

2. **Funil de Vendas / Pipeline Kanban (`lib/modules/pipeline/`)**
   - 5 etapas: *Potencial*, *Em Negociação*, *Proposta Enviada*, *Cliente Ativo* e *Perdido*.
   - Criação de oportunidades associadas aos clientes cadastrados, movimentação entre colunas e exclusão direta.

3. **Gestão de Clientes (`lib/modules/customers/`)**
   - Cadastro e listagem de clientes (nome, telefone/WhatsApp, e-mail, endereço e observações).
   - Singleton `CustomerController` sincronizado com o Pipeline, Faturamento e Pós-Venda.

4. **Faturamento & Notas Fiscais (`lib/modules/billing/`)**
   - Gestão de faturas (`Pendente`, `Pago`, `Cancelado`) sincronizada com a tabela `invoices`.
   - Cópia rápida de dados formatados do cliente para área de transferência (`NfClipboardHelper`) para agilizar emissão de NF.

5. **Fluxo de Caixa Simples (`lib/modules/cash_flow/`)**
   - Dashboard com totalizador automático de **Entradas**, **Saídas** e **Saldo Líquido**.
   - Lançamento e exclusão de receitas e despesas na tabela `cash_flow`.

6. **Pós-Venda & Follow-up (`lib/features/follow_up/`)**
   - Agendamento de acompanhamento pós-venda vinculado ao cliente na tabela `follow_ups`.
   - Marcação rápida de confirmação de recebimento/conclusão.

## Tabelas no Supabase (`https://cmvkanmyrhoxuprlpexh.supabase.co`)

- `customers`: `id`, `user_id`, `name`, `phone`, `email`, `address`, `notes`, `created_at`, `updated_at`
- `deals`: `id`, `user_id`, `customer_id`, `customer_name`, `title`, `value`, `stage`, `created_at`
- `invoices`: `id`, `user_id`, `customer_id`, `customer_name`, `value`, `due_date`, `status`, `created_at`
- `cash_flow`: `id`, `user_id`, `description`, `value`, `type`, `date`, `created_at`
- `follow_ups`: `id`, `user_id`, `customer_id`, `deal_id`, `title`, `description`, `scheduled_date`, `status`, `satisfaction_score`, `is_received`, `received_date`, `created_at`

---

## Migração Fase 1 (Ordem de Implantação Segura)

Siga rigorosamente a ordem abaixo ao implantar em qualquer ambiente Supabase:

1. **Backup Preventivo**:
   - No painel do Supabase (**Database -> Backups**) ou via `pg_dump`, realize um snapshot/backup completo do esquema `public` antes de qualquer alteração.
2. **Diagnóstico Inicial (`rls_check.sql`)**:
   - Execute [`supabase/tests/rls_check.sql`](supabase/tests/rls_check.sql) no SQL Editor para inspecionar o estado de RLS (`rowsecurity`), policies ativas (`pg_policies`), nullability de `user_id` e contagem de registros sem proprietário.
3. **Aplicação da Migration (`20261112202500_fase1_integridade.sql`)**:
   - Execute [`supabase/migrations/20261112202500_fase1_integridade.sql`](supabase/migrations/20261112202500_fase1_integridade.sql) no SQL Editor.
   - A migration é idempotente e transacional: adiciona `user_id` onde ausente, converte `invoices.customer_id` para `uuid`, remove a policy aberta de `follow_ups`, cria policies estritas `FOR ALL TO authenticated USING ((select auth.uid()) = user_id) WITH CHECK ((select auth.uid()) = user_id)`, configura FKs `ON DELETE RESTRICT`, cria a função RPC `public.delete_customer_safe(uuid)` e valida as `CHECK` constraints.
   - Em caso de necessidade de reversão, utilize [`supabase/migrations/20261112202500_fase1_rollback.sql`](supabase/migrations/20261112202500_fase1_rollback.sql).
4. **Validação com Roteiro de 2 Usuários (`rls_two_users.md`)**:
   - Execute o roteiro descrito em [`supabase/tests/rls_two_users.md`](supabase/tests/rls_two_users.md) (com Usuário A e Usuário B) confirmando o isolamento total entre contas nas 5 tabelas e o bloqueio de exclusão de cliente que possua faturas ou follow-ups (`CLIENTE_COM_VINCULOS`).
5. **Publicação do App Flutter**:
   - Com o banco validado, gere o build de produção (`flutter build web` / `flutter build apk`) a partir da branch revisada e publique a aplicação.
