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
