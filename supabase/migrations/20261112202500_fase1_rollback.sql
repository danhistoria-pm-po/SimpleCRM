-- supabase/migrations/20261112202500_fase1_rollback.sql
-- Script de Rollback da Fase 1 (Integridade e Segurança)
-- Não destrutivo: preserva dados e mantém o RLS ativo nas 5 tabelas
-- (NÃO recria a policy aberta "Enable all access for follow_ups" por segurança).

BEGIN;

-- 1. Remover CHECK constraints adicionadas na Fase 1
ALTER TABLE public.invoices   DROP CONSTRAINT IF EXISTS chk_invoices_status;
ALTER TABLE public.invoices   DROP CONSTRAINT IF EXISTS chk_invoices_value_positive;
ALTER TABLE public.cash_flow  DROP CONSTRAINT IF EXISTS chk_cash_flow_type;
ALTER TABLE public.cash_flow  DROP CONSTRAINT IF EXISTS chk_cash_flow_value_positive;
ALTER TABLE public.follow_ups DROP CONSTRAINT IF EXISTS chk_follow_ups_status;
ALTER TABLE public.follow_ups DROP CONSTRAINT IF EXISTS chk_follow_ups_satisfaction_score;

-- 2. Remover função RPC delete_customer_safe
DROP FUNCTION IF EXISTS public.delete_customer_safe(uuid);

-- 3. Reverter Foreign Keys e tipo de invoices.customer_id
-- Nota: Originalmente invoices.customer_id era TEXT (sem FK para customers.id UUID).
-- Ao remover fk_invoices_customer_id, convertemos invoices.customer_id de volta para TEXT
-- e recriamos as FKs ON DELETE CASCADE em follow_ups e deals (que são UUID).
ALTER TABLE public.invoices   DROP CONSTRAINT IF EXISTS fk_invoices_customer_id;
ALTER TABLE public.follow_ups DROP CONSTRAINT IF EXISTS fk_follow_ups_customer_id;
ALTER TABLE public.deals      DROP CONSTRAINT IF EXISTS fk_deals_customer_id;

ALTER TABLE public.invoices
  ALTER COLUMN customer_id TYPE text USING customer_id::text;

ALTER TABLE public.follow_ups
  ADD CONSTRAINT fk_follow_ups_customer_id
  FOREIGN KEY (customer_id) REFERENCES public.customers(id) ON DELETE CASCADE;

ALTER TABLE public.deals
  ADD CONSTRAINT fk_deals_customer_id
  FOREIGN KEY (customer_id) REFERENCES public.customers(id) ON DELETE CASCADE;

-- 4. Remover índices adicionados na Fase 1
DROP INDEX IF EXISTS public.idx_customers_user_id;
DROP INDEX IF EXISTS public.idx_deals_user_id;
DROP INDEX IF EXISTS public.idx_invoices_user_id;
DROP INDEX IF EXISTS public.idx_cash_flow_user_id;
DROP INDEX IF EXISTS public.idx_follow_ups_user_id;

DROP INDEX IF EXISTS public.idx_deals_customer_id;
DROP INDEX IF EXISTS public.idx_invoices_customer_id;
DROP INDEX IF EXISTS public.idx_follow_ups_customer_id;

DROP INDEX IF EXISTS public.idx_cash_flow_date;
DROP INDEX IF EXISTS public.idx_follow_ups_scheduled_date;
DROP INDEX IF EXISTS public.idx_invoices_due_date;

-- 5. Remover policies da Fase 1 e restaurar policies anteriores de customers e deals
DROP POLICY IF EXISTS "customers_owner_policy"  ON public.customers;
DROP POLICY IF EXISTS "deals_owner_policy"      ON public.deals;
DROP POLICY IF EXISTS "invoices_owner_policy"   ON public.invoices;
DROP POLICY IF EXISTS "cash_flow_owner_policy"  ON public.cash_flow;
DROP POLICY IF EXISTS "follow_ups_owner_policy" ON public.follow_ups;

CREATE POLICY "Users manage own customers" ON public.customers
  FOR ALL TO public
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users manage own deals" ON public.deals
  FOR ALL TO public
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- 6. Remover coluna user_id de invoices, cash_flow e follow_ups APENAS se estiverem vazias (não destrutivo)
DO $$
BEGIN
  IF (SELECT COUNT(*) FROM public.invoices) = 0 THEN
    ALTER TABLE public.invoices DROP COLUMN IF EXISTS user_id;
  ELSE
    ALTER TABLE public.invoices ALTER COLUMN user_id DROP NOT NULL;
  END IF;

  IF (SELECT COUNT(*) FROM public.cash_flow) = 0 THEN
    ALTER TABLE public.cash_flow DROP COLUMN IF EXISTS user_id;
  ELSE
    ALTER TABLE public.cash_flow ALTER COLUMN user_id DROP NOT NULL;
  END IF;

  IF (SELECT COUNT(*) FROM public.follow_ups) = 0 THEN
    ALTER TABLE public.follow_ups DROP COLUMN IF EXISTS user_id;
  ELSE
    ALTER TABLE public.follow_ups ALTER COLUMN user_id DROP NOT NULL;
  END IF;
END $$;

COMMIT;
