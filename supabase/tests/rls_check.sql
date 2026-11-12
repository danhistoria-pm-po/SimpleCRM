-- supabase/tests/rls_check.sql
-- Script de diagnóstico e verificação de baseline (Fase 0) para as 5 tabelas do SimpleCRM:
-- customers, deals, invoices, cash_flow, follow_ups

-- 1. Verificar existência das tabelas e se o RLS (rowsecurity) está ativo
SELECT
  schemaname,
  tablename,
  rowsecurity AS rls_enabled
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN ('customers', 'deals', 'invoices', 'cash_flow', 'follow_ups')
ORDER BY tablename;

-- 2. Listar todas as policies existentes para as 5 tabelas
SELECT
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual AS using_expression,
  with_check AS with_check_expression
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename IN ('customers', 'deals', 'invoices', 'cash_flow', 'follow_ups')
ORDER BY tablename, policyname;

-- 3. Verificar existência, tipo, nullability e default da coluna user_id nas 5 tabelas
SELECT
  table_name,
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name IN ('customers', 'deals', 'invoices', 'cash_flow', 'follow_ups')
  AND column_name = 'user_id'
ORDER BY table_name;

-- 4. Contagem de linhas totais e linhas com user_id IS NULL em cada tabela
SELECT
  'customers' AS table_name,
  COUNT(*) AS total_rows,
  COUNT(*) FILTER (WHERE user_id IS NULL) AS null_user_id_rows
FROM public.customers
UNION ALL
SELECT
  'deals' AS table_name,
  COUNT(*) AS total_rows,
  COUNT(*) FILTER (WHERE user_id IS NULL) AS null_user_id_rows
FROM public.deals
UNION ALL
SELECT
  'invoices' AS table_name,
  COUNT(*) AS total_rows,
  COUNT(*) FILTER (WHERE user_id IS NULL) AS null_user_id_rows
FROM public.invoices
UNION ALL
SELECT
  'cash_flow' AS table_name,
  COUNT(*) AS total_rows,
  COUNT(*) FILTER (WHERE user_id IS NULL) AS null_user_id_rows
FROM public.cash_flow
UNION ALL
SELECT
  'follow_ups' AS table_name,
  COUNT(*) AS total_rows,
  COUNT(*) FILTER (WHERE user_id IS NULL) AS null_user_id_rows
FROM public.follow_ups;
