-- supabase/migrations/20261112202500_fase1_integridade.sql
-- Fase 1: Integridade e Segurança (ajustada para o estado real verificado do banco)
-- Contexto verificado:
--   - RLS já ativo nas 5 tabelas.
--   - customers (6 linhas) e deals (6 linhas): possuem coluna user_id e policy (auth.uid() = user_id) para {public}.
--   - invoices, cash_flow e follow_ups: 0 linhas, SEM coluna user_id.
--   - follow_ups possui policy aberta "Enable all access for follow_ups" (true/true).
--   - invoices e cash_flow não possuem policies.

BEGIN;

-- ============================================================================
-- 1. GARANTIR RLS ATIVO NAS 5 TABELAS
-- ============================================================================
ALTER TABLE public.customers  ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.deals      ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.invoices   ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cash_flow  ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.follow_ups ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 2. COLUNA user_id NAS TABELAS VAZIAS (invoices, cash_flow, follow_ups)
-- ============================================================================
ALTER TABLE public.invoices
  ADD COLUMN IF NOT EXISTS user_id uuid NOT NULL DEFAULT auth.uid()
  REFERENCES auth.users(id) ON DELETE CASCADE;

ALTER TABLE public.cash_flow
  ADD COLUMN IF NOT EXISTS user_id uuid NOT NULL DEFAULT auth.uid()
  REFERENCES auth.users(id) ON DELETE CASCADE;

ALTER TABLE public.follow_ups
  ADD COLUMN IF NOT EXISTS user_id uuid NOT NULL DEFAULT auth.uid()
  REFERENCES auth.users(id) ON DELETE CASCADE;

-- Garantir DEFAULT e NOT NULL caso a coluna já tenha sido criada parcialmente em tentativa anterior
ALTER TABLE public.invoices   ALTER COLUMN user_id SET DEFAULT auth.uid();
ALTER TABLE public.invoices   ALTER COLUMN user_id SET NOT NULL;

ALTER TABLE public.cash_flow  ALTER COLUMN user_id SET DEFAULT auth.uid();
ALTER TABLE public.cash_flow  ALTER COLUMN user_id SET NOT NULL;

ALTER TABLE public.follow_ups ALTER COLUMN user_id SET DEFAULT auth.uid();
ALTER TABLE public.follow_ups ALTER COLUMN user_id SET NOT NULL;

-- 2.1 Converter invoices.customer_id de TEXT para UUID (abortando se houver linhas)
DO $$
DECLARE
  v_invoices_count bigint;
BEGIN
  SELECT COUNT(*) INTO v_invoices_count FROM public.invoices;
  IF v_invoices_count > 0 THEN
    RAISE EXCEPTION 'ABORT_INVOICES_NOT_EMPTY: public.invoices possui % linhas. Conversão de customer_id (text -> uuid) abortada para revisão.', v_invoices_count;
  END IF;
END $$;

ALTER TABLE public.invoices
  ALTER COLUMN customer_id TYPE uuid USING customer_id::uuid;

-- ============================================================================
-- 3. VERIFICAR NULOS EM customers E deals ANTES DO NOT NULL (SEM APAGAR DADOS)
-- ============================================================================
DO $$
DECLARE
  v_null_customers bigint;
  v_null_deals     bigint;
BEGIN
  SELECT COUNT(*) INTO v_null_customers FROM public.customers WHERE user_id IS NULL;
  IF v_null_customers > 0 THEN
    RAISE EXCEPTION 'ABORT_NULL_USER_ID_CUSTOMERS: Existem % linhas em public.customers com user_id IS NULL. Migração abortada para revisão manual.', v_null_customers;
  END IF;

  SELECT COUNT(*) INTO v_null_deals FROM public.deals WHERE user_id IS NULL;
  IF v_null_deals > 0 THEN
    RAISE EXCEPTION 'ABORT_NULL_USER_ID_DEALS: Existem % linhas em public.deals com user_id IS NULL. Migração abortada para revisão manual.', v_null_deals;
  END IF;
END $$;

ALTER TABLE public.customers ALTER COLUMN user_id SET DEFAULT auth.uid();
ALTER TABLE public.customers ALTER COLUMN user_id SET NOT NULL;

ALTER TABLE public.deals     ALTER COLUMN user_id SET DEFAULT auth.uid();
ALTER TABLE public.deals     ALTER COLUMN user_id SET NOT NULL;

-- ============================================================================
-- 4. REMOVER POLICY ABERTA DE follow_ups E POLICIES ANTIGAS ({public}),
--    RECRIANDO POLICIES PADRONIZADAS (FOR ALL TO authenticated) NAS 5 TABELAS
-- ============================================================================
-- Dropar explicitamente a policy aberta de follow_ups
DROP POLICY IF EXISTS "Enable all access for follow_ups" ON public.follow_ups;
DROP POLICY IF EXISTS "Enable all access"                ON public.follow_ups;

-- Dropar quaisquer policies anteriores existentes nas 5 tabelas (incluindo as de roles {public} em customers e deals)
DO $$
DECLARE
  r record;
BEGIN
  FOR r IN (
    SELECT tablename, policyname
      FROM pg_policies
     WHERE schemaname = 'public'
       AND tablename IN ('customers', 'deals', 'invoices', 'cash_flow', 'follow_ups')
  ) LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON public.%I', r.policyname, r.tablename);
  END LOOP;
END $$;

CREATE POLICY "customers_owner_policy" ON public.customers
  FOR ALL TO authenticated
  USING ((select auth.uid()) = user_id)
  WITH CHECK ((select auth.uid()) = user_id);

CREATE POLICY "deals_owner_policy" ON public.deals
  FOR ALL TO authenticated
  USING ((select auth.uid()) = user_id)
  WITH CHECK ((select auth.uid()) = user_id);

CREATE POLICY "invoices_owner_policy" ON public.invoices
  FOR ALL TO authenticated
  USING ((select auth.uid()) = user_id)
  WITH CHECK ((select auth.uid()) = user_id);

CREATE POLICY "cash_flow_owner_policy" ON public.cash_flow
  FOR ALL TO authenticated
  USING ((select auth.uid()) = user_id)
  WITH CHECK ((select auth.uid()) = user_id);

CREATE POLICY "follow_ups_owner_policy" ON public.follow_ups
  FOR ALL TO authenticated
  USING ((select auth.uid()) = user_id)
  WITH CHECK ((select auth.uid()) = user_id);

-- ============================================================================
-- 5. ÍNDICES DE PERFORMANCE E INTEGRIDADE
-- ============================================================================
CREATE INDEX IF NOT EXISTS idx_customers_user_id          ON public.customers(user_id);
CREATE INDEX IF NOT EXISTS idx_deals_user_id              ON public.deals(user_id);
CREATE INDEX IF NOT EXISTS idx_invoices_user_id           ON public.invoices(user_id);
CREATE INDEX IF NOT EXISTS idx_cash_flow_user_id          ON public.cash_flow(user_id);
CREATE INDEX IF NOT EXISTS idx_follow_ups_user_id         ON public.follow_ups(user_id);

CREATE INDEX IF NOT EXISTS idx_deals_customer_id          ON public.deals(customer_id);
CREATE INDEX IF NOT EXISTS idx_invoices_customer_id       ON public.invoices(customer_id);
CREATE INDEX IF NOT EXISTS idx_follow_ups_customer_id     ON public.follow_ups(customer_id);

CREATE INDEX IF NOT EXISTS idx_cash_flow_date             ON public.cash_flow(date);
CREATE INDEX IF NOT EXISTS idx_follow_ups_scheduled_date  ON public.follow_ups(scheduled_date);
CREATE INDEX IF NOT EXISTS idx_invoices_due_date          ON public.invoices(due_date);

-- ============================================================================
-- 6. FOREIGN KEYS COM ON DELETE RESTRICT (invoices, follow_ups e deals)
-- ============================================================================
DO $$
DECLARE
  r record;
BEGIN
  -- Remover FKs existentes em invoices.customer_id -> customers.id
  FOR r IN (
    SELECT tc.constraint_name
      FROM information_schema.table_constraints tc
      JOIN information_schema.key_column_usage kcu
        ON tc.constraint_name = kcu.constraint_name
       AND tc.table_schema = kcu.table_schema
     WHERE tc.table_schema = 'public'
       AND tc.table_name = 'invoices'
       AND tc.constraint_type = 'FOREIGN KEY'
       AND kcu.column_name = 'customer_id'
  ) LOOP
    EXECUTE format('ALTER TABLE public.invoices DROP CONSTRAINT %I', r.constraint_name);
  END LOOP;

  -- Remover FKs existentes em follow_ups.customer_id -> customers.id
  FOR r IN (
    SELECT tc.constraint_name
      FROM information_schema.table_constraints tc
      JOIN information_schema.key_column_usage kcu
        ON tc.constraint_name = kcu.constraint_name
       AND tc.table_schema = kcu.table_schema
     WHERE tc.table_schema = 'public'
       AND tc.table_name = 'follow_ups'
       AND tc.constraint_type = 'FOREIGN KEY'
       AND kcu.column_name = 'customer_id'
  ) LOOP
    EXECUTE format('ALTER TABLE public.follow_ups DROP CONSTRAINT %I', r.constraint_name);
  END LOOP;

  -- Remover FKs existentes em deals.customer_id -> customers.id
  FOR r IN (
    SELECT tc.constraint_name
      FROM information_schema.table_constraints tc
      JOIN information_schema.key_column_usage kcu
        ON tc.constraint_name = kcu.constraint_name
       AND tc.table_schema = kcu.table_schema
     WHERE tc.table_schema = 'public'
       AND tc.table_name = 'deals'
       AND tc.constraint_type = 'FOREIGN KEY'
       AND kcu.column_name = 'customer_id'
  ) LOOP
    EXECUTE format('ALTER TABLE public.deals DROP CONSTRAINT %I', r.constraint_name);
  END LOOP;
END $$;

ALTER TABLE public.invoices
  ADD CONSTRAINT fk_invoices_customer_id
  FOREIGN KEY (customer_id) REFERENCES public.customers(id) ON DELETE RESTRICT;

ALTER TABLE public.follow_ups
  ADD CONSTRAINT fk_follow_ups_customer_id
  FOREIGN KEY (customer_id) REFERENCES public.customers(id) ON DELETE RESTRICT;

ALTER TABLE public.deals
  ADD CONSTRAINT fk_deals_customer_id
  FOREIGN KEY (customer_id) REFERENCES public.customers(id) ON DELETE RESTRICT;

-- ============================================================================
-- 7. FUNÇÃO RPC ATÔMICA: public.delete_customer_safe(p_customer_id uuid)
-- ============================================================================
CREATE OR REPLACE FUNCTION public.delete_customer_safe(p_customer_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = public, pg_temp
AS $$
BEGIN
  -- Bloquear se existirem faturas ou follow-ups vinculados ao cliente
  IF EXISTS (SELECT 1 FROM public.invoices WHERE customer_id = p_customer_id)
     OR EXISTS (SELECT 1 FROM public.follow_ups WHERE customer_id = p_customer_id) THEN
    RAISE EXCEPTION 'CLIENTE_COM_VINCULOS'
      USING DETAIL = 'O cliente possui faturas ou follow-ups vinculados.',
            HINT = 'Exclua as faturas e follow-ups deste cliente antes de removê-lo.';
  END IF;

  -- Remover oportunidades (deals) do cliente atomicamente na mesma transação
  DELETE FROM public.deals WHERE customer_id = p_customer_id;

  -- Remover o cliente
  DELETE FROM public.customers WHERE id = p_customer_id;
END;
$$;

REVOKE ALL ON FUNCTION public.delete_customer_safe(uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.delete_customer_safe(uuid) TO authenticated;

-- ============================================================================
-- 8. CHECK CONSTRAINTS (NOT VALID + VALIDATE COM DIAGNÓSTICO DE OFENSORES)
-- ============================================================================
DO $$
DECLARE
  v_bad_rows text;
BEGIN
  SELECT string_agg(id::text, ', ') INTO v_bad_rows
    FROM public.invoices
   WHERE status NOT IN ('pending', 'paid', 'cancelled') OR value <= 0;
  IF v_bad_rows IS NOT NULL THEN
    RAISE EXCEPTION 'CHECK_VIOLATION_INVOICES: Linhas ofensoras em public.invoices (IDs: %)', v_bad_rows;
  END IF;

  SELECT string_agg(id::text, ', ') INTO v_bad_rows
    FROM public.cash_flow
   WHERE type NOT IN ('income', 'expense') OR value <= 0;
  IF v_bad_rows IS NOT NULL THEN
    RAISE EXCEPTION 'CHECK_VIOLATION_CASH_FLOW: Linhas ofensoras em public.cash_flow (IDs: %)', v_bad_rows;
  END IF;

  SELECT string_agg(id::text, ', ') INTO v_bad_rows
    FROM public.follow_ups
   WHERE status NOT IN ('pendente', 'concluido', 'cancelado')
      OR (satisfaction_score IS NOT NULL AND (satisfaction_score < 1 OR satisfaction_score > 5));
  IF v_bad_rows IS NOT NULL THEN
    RAISE EXCEPTION 'CHECK_VIOLATION_FOLLOW_UPS: Linhas ofensoras em public.follow_ups (IDs: %)', v_bad_rows;
  END IF;
END $$;

ALTER TABLE public.invoices DROP CONSTRAINT IF EXISTS chk_invoices_status;
ALTER TABLE public.invoices
  ADD CONSTRAINT chk_invoices_status
  CHECK (status IN ('pending', 'paid', 'cancelled')) NOT VALID;
ALTER TABLE public.invoices VALIDATE CONSTRAINT chk_invoices_status;

ALTER TABLE public.invoices DROP CONSTRAINT IF EXISTS chk_invoices_value_positive;
ALTER TABLE public.invoices
  ADD CONSTRAINT chk_invoices_value_positive
  CHECK (value > 0) NOT VALID;
ALTER TABLE public.invoices VALIDATE CONSTRAINT chk_invoices_value_positive;

ALTER TABLE public.cash_flow DROP CONSTRAINT IF EXISTS chk_cash_flow_type;
ALTER TABLE public.cash_flow
  ADD CONSTRAINT chk_cash_flow_type
  CHECK (type IN ('income', 'expense')) NOT VALID;
ALTER TABLE public.cash_flow VALIDATE CONSTRAINT chk_cash_flow_type;

ALTER TABLE public.cash_flow DROP CONSTRAINT IF EXISTS chk_cash_flow_value_positive;
ALTER TABLE public.cash_flow
  ADD CONSTRAINT chk_cash_flow_value_positive
  CHECK (value > 0) NOT VALID;
ALTER TABLE public.cash_flow VALIDATE CONSTRAINT chk_cash_flow_value_positive;

ALTER TABLE public.follow_ups DROP CONSTRAINT IF EXISTS chk_follow_ups_status;
ALTER TABLE public.follow_ups
  ADD CONSTRAINT chk_follow_ups_status
  CHECK (status IN ('pendente', 'concluido', 'cancelado')) NOT VALID;
ALTER TABLE public.follow_ups VALIDATE CONSTRAINT chk_follow_ups_status;

ALTER TABLE public.follow_ups DROP CONSTRAINT IF EXISTS chk_follow_ups_satisfaction_score;
ALTER TABLE public.follow_ups
  ADD CONSTRAINT chk_follow_ups_satisfaction_score
  CHECK (satisfaction_score IS NULL OR (satisfaction_score BETWEEN 1 AND 5)) NOT VALID;
ALTER TABLE public.follow_ups VALIDATE CONSTRAINT chk_follow_ups_satisfaction_score;

COMMIT;
