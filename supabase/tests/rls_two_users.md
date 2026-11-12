# Roteiro de Teste de Isolamento RLS (2 Usuários) e Exclusão Segura

Arquivo: `supabase/tests/rls_two_users.md`  
Objetivo: Validar manualmente (no app e/ou via SQL Editor simulando claims JWT) que o **Usuário B** não lê, não altera e não exclui registros do **Usuário A** nas 5 tabelas (`customers`, `deals`, `invoices`, `cash_flow`, `follow_ups`), e que a exclusão de cliente com fatura ou follow-up é bloqueada por `delete_customer_safe`.

---

## Parte 1 — Roteiro no App (UI)

### Pré-requisitos
1. Migration `20261112202500_fase1_integridade.sql` aplicada no projeto Supabase.
2. Duas contas criadas no app:
   - **Usuário A**: `usuario.a@teste.com`
   - **Usuário B**: `usuario.b@teste.com`

### Passo a Passo
1. **Login como Usuário A**:
   - Na aba **Clientes**, crie o cliente `"Cliente A1"`.
   - Na aba **Pipeline**, crie a oportunidade `"Deal A1"` vinculada ao `"Cliente A1"` (R$ 1.500,00).
   - Na aba **Faturamento**, crie uma fatura para `"Cliente A1"` (R$ 1.500,00).
   - Na aba **Caixa**, crie um lançamento de entrada `"Receita A1"` (R$ 500,00).
   - Na aba **Pós-Venda**, crie um follow-up `"Follow-up A1"` vinculado ao `"Cliente A1"`.
2. **Teste de Bloqueio de Exclusão com Vínculos (Usuário A)**:
   - Vá na aba **Clientes** e clique no ícone de lixeira ao lado de `"Cliente A1"`.
   - Confirme no diálogo de confirmação.
   - **Resultado esperado**: A exclusão é bloqueada e o app exibe um `SnackBar` vermelho com a mensagem exata:
     > `"Este cliente possui faturas ou follow-ups. Exclua-os antes de remover o cliente."`
   - O `"Cliente A1"` e o `"Deal A1"` permanecem intactos.
3. **Isolamento entre Contas (Login como Usuário B)**:
   - Faça logout do Usuário A e entre como **Usuário B** (`usuario.b@teste.com`).
   - Navegue pelas 5 abas (**Pipeline**, **Clientes**, **Faturamento**, **Caixa**, **Pós-Venda**).
   - **Resultado esperado**: Todas as listas estão vazias para o Usuário B (nenhum dado do Usuário A é visível).
   - Cadastre um `"Cliente B1"` e um `"Deal B1"`.
4. **Exclusão Atômica de Cliente sem Faturas/Follow-ups (Usuário B)**:
   - Com `"Cliente B1"` possuindo apenas `"Deal B1"` (sem faturas e sem follow-ups), exclua `"Cliente B1"` na aba **Clientes** e confirme no diálogo.
   - **Resultado esperado**: `"Cliente B1"` e `"Deal B1"` são removidos atomicamente via `delete_customer_safe`.

---

## Parte 2 — Roteiro Automatizável no SQL Editor do Supabase (Simulação JWT)

Execute o bloco abaixo no **SQL Editor** do Supabase (ele usa uma transação com `ROLLBACK` ao final para não deixar lixo no banco):

```sql
BEGIN;

-- Simular contexto autenticado do Usuário A (UUID fictício A)
SET LOCAL role TO authenticated;
SELECT set_config(
  'request.jwt.claims',
  json_build_object('sub', '00000000-0000-0000-0000-00000000000a', 'role', 'authenticated')::text,
  true
);

-- Nota: Caso a FK user_id -> auth.users exija usuários reais existentes em auth.users,
-- substitua os dois UUIDs ('...000a' e '...000b') por dois IDs reais de `SELECT id FROM auth.users LIMIT 2;`.

-- 1. Inserir registros como Usuário A
WITH ins_c AS (
  INSERT INTO public.customers (name, email)
  VALUES ('Cliente Teste RLS A', 'rls_a@teste.com')
  RETURNING id
)
INSERT INTO public.deals (customer_id, customer_name, title, value, stage)
SELECT id, 'Cliente Teste RLS A', 'Deal A', 1000, 'potential' FROM ins_c;

INSERT INTO public.invoices (customer_id, customer_name, value, due_date, status)
SELECT id, 'Cliente Teste RLS A', 1000, now(), 'pending'
FROM public.customers WHERE name = 'Cliente Teste RLS A';

INSERT INTO public.cash_flow (description, value, type, date)
VALUES ('Entrada A', 250, 'income', now());

INSERT INTO public.follow_ups (customer_id, title, scheduled_date, status, is_received)
SELECT id, 'FollowUp A', now(), 'pendente', false
FROM public.customers WHERE name = 'Cliente Teste RLS A';

-- 2. Alternar para Usuário B e verificar que nada de A pode ser lido, alterado ou apagado
SELECT set_config(
  'request.jwt.claims',
  json_build_object('sub', '00000000-0000-0000-0000-00000000000b', 'role', 'authenticated')::text,
  true
);

DO $$
DECLARE
  v_visible int;
BEGIN
  SELECT
    (SELECT count(*) FROM public.customers WHERE name = 'Cliente Teste RLS A') +
    (SELECT count(*) FROM public.deals WHERE title = 'Deal A') +
    (SELECT count(*) FROM public.invoices WHERE customer_name = 'Cliente Teste RLS A') +
    (SELECT count(*) FROM public.cash_flow WHERE description = 'Entrada A') +
    (SELECT count(*) FROM public.follow_ups WHERE title = 'FollowUp A')
  INTO v_visible;

  IF v_visible > 0 THEN
    RAISE EXCEPTION 'FALHA RLS: Usuário B conseguiu visualizar % registros do Usuário A!', v_visible;
  END IF;
END $$;

-- 3. Voltar para Usuário A e testar bloqueio de delete_customer_safe com fatura/follow-up
SELECT set_config(
  'request.jwt.claims',
  json_build_object('sub', '00000000-0000-0000-0000-00000000000a', 'role', 'authenticated')::text,
  true
);

DO $$
DECLARE
  v_cid uuid;
  v_blocked boolean := false;
BEGIN
  SELECT id INTO v_cid FROM public.customers WHERE name = 'Cliente Teste RLS A';
  BEGIN
    PERFORM public.delete_customer_safe(v_cid);
  EXCEPTION WHEN OTHERS THEN
    IF SQLERRM LIKE '%CLIENTE_COM_VINCULOS%' THEN
      v_blocked := true;
    ELSE
      RAISE;
    END IF;
  END;

  IF NOT v_blocked THEN
    RAISE EXCEPTION 'FALHA INTEGRIDADE: delete_customer_safe permitiu excluir cliente com vínculos!';
  END IF;
END $$;

ROLLBACK;
```
