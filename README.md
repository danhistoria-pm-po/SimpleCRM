# Prisma Gestão — Suíte Modular de Gestão Comercial & Serviços

> **Gestão simples e direta ao ponto para o seu negócio.**  
> Evolução modular do **SimpleCRM** para uma suíte multi-nicho em **Flutter + Supabase**, projetada para PMEs, profissionais liberais e negócios de serviços que precisam controlar relacionamento, funil Kanban, faturamento, fluxo de caixa e pós-venda em uma única plataforma.

---

## 1. Visão do Produto e Portfólio de Módulos

O **Prisma Gestão** combina uma base única de engenharia com uma camada dinâmica de adaptação de marca, paleta de cores, terminologia e isolamento de dados por segmento (**Motor Camaleão**). Em vez de manter cinco bases de código separadas, a suíte opera **5 produtos verticais** sobre o mesmo núcleo de produtividade:

| Módulo | Chave (`niche`) | Público-Alvo | Cor Primária | Plano / Preço |
| :--- | :--- | :--- | :--- | :--- |
| **Prisma Gestão \| SimpleCRM** | `simplecrm` | Comércio local, PMEs e vendas B2B/B2C | Verde-petróleo (`#006D68`) | `comercio_49` — **R$ 49,00/mês** |
| **Prisma Gestão \| Clínica** | `clinica` | Clínicas médicas, odontológicas e estética | Azul Clínico (`#1565C0`) | `especializado_97` — **R$ 97,00/mês** |
| **Prisma Gestão \| Vet&Pet** | `vet_pet` | Clínicas veterinárias e pet shops | Esmeralda (`#2E7D32`) | `especializado_97` — **R$ 97,00/mês** |
| **Prisma Gestão \| Imobiliária** | `imobiliaria` | Corretores autônomos e imobiliárias | Azul Corporativo (`#1E3A8A`) | `especializado_97` — **R$ 97,00/mês** |
| **Prisma Gestão \| Curso** | `curso` | Cursos livres, idiomas, cursinhos e mentorias | Índigo Educacional (`#4F46E5`) | `especializado_97` — **R$ 97,00/mês** |

---

## 2. Arquitetura do Motor Camaleão (`NicheConfig`)

O comportamento multi-nicho é centralizado em [`lib/config/niche_config.dart`](lib/config/niche_config.dart) e propagado para toda a árvore de widgets via `InheritedWidget` ([`lib/widgets/niche_scope.dart`](lib/widgets/niche_scope.dart)):

- **Tema Dinâmico (`AppTheme.forNiche`):** Aplica automaticamente a paleta primária, escura e suave do nicho ativo na `AppBar`, `BottomNavigationBar`, botões, badges, banner de trial e tutorial.
- **Vocabulário Adaptativo:** Adapta títulos de tela, abas, botões flutuantes, formulários, placeholders e as 5 colunas do Kanban sem alterar os valores internos persistidos no banco (`DealStage`):
  - *SimpleCRM:* Clientes, Pipeline (Oportunidades), Faturamento, Caixa, Pós-Venda.
  - *Clínica:* Pacientes, Atendimentos (Tratamentos), Recibos / Faturas, Caixa, Retornos.
  - *Vet&Pet:* Pets & Tutores, Agenda / Fluxo (Consultas & Serviços), Faturamento, Caixa, Vacinas & Retornos.
  - *Imobiliária:* Interessados, Negociações (Propostas & Visitas), Comissões / Contratos, Caixa, Pós-Venda.
  - *Curso:* Alunos, Matrículas, Mensalidades (`+ Nova Mensalidade`), Caixa, Renovação & Retenção.
- **Troca de Módulo em Tempo Real:** O seletor `NicheSwitcherAction` na `AppBar` atualiza `niche` e `plan_tier` em `public.profiles`, redefine o tema e recarrega os módulos imediatamente.

---

## 3. Isolamento de Dados por Usuário e por Nicho

A segurança e a separação de dados operam em **duas camadas complementares** no Supabase (PostgreSQL):

1. **Isolamento por Conta (RLS):** Todas as tabelas de negócio possuem `user_id NOT NULL DEFAULT auth.uid()` com Row Level Security ativo (`USING ((select auth.uid()) = user_id)` para `authenticated`), além de FKs `ON DELETE RESTRICT` e RPC atômica `delete_customer_safe(uuid)`.
2. **Isolamento por Nicho (`ActiveNicheContext`):** As 5 tabelas de negócio gravam e filtram explicitamente a coluna `niche` em todas as operações de leitura (`select().eq('niche', activeNiche)`) e escrita (`insert({'niche': activeNiche, ...})`), impedindo vazamento de registros ao alternar entre módulos:
   - `customers` — Cadastro de clientes / pacientes / pets & tutores / interessados / alunos.
   - `deals` — Cards do funil Kanban em 5 etapas com busca em tempo real e filtro por etapa.
   - `invoices` — Cobranças, recibos e mensalidades com cópia rápida formatada para Recibo/NF (`Icons.copy_rounded`).
   - `cash_flow` — Entradas, saídas e saldo líquido do dia.
   - `follow_ups` — Pós-venda, retornos, confirmação de recebimento e avaliação de satisfação (1 a 5 estrelas).

### Automação de Fechamento no Kanban
Ao mover um card para a etapa de fechamento/conversão (`DealStage.activeClient`), o `PipelineController` executa automaticamente, mantendo o `niche` ativo:
1. Geração da cobrança/fatura no módulo de **Faturamento**.
2. Registro da entrada financeira do dia no **Fluxo de Caixa**.
3. Agendamento automático de acompanhamento (+7 dias) no **Pós-Venda**.

---

## 4. Fluxo de Acesso, 30 Dias Grátis (`PRISMA30`) e Assinatura

O controle de acesso é gerenciado por [`AccessGate`](lib/widgets/access_gate.dart), [`UserProfile`](lib/models/user_profile.dart) e [`SubscriptionService`](lib/services/subscription_service.dart) integrados à tabela `public.profiles`:

- **Cadastro com Segmento e LGPD:** Na tela de cadastro (`RegisterPage`), o usuário escolhe seu módulo inicial, aceita os Termos de Uso e Política de Privacidade (LGPD — Lei nº 13.709/2018) e tem `niche` e `plan_tier` registrados em `public.profiles`.
- **Período Gratuito de 30 Dias:** Na [`TrialAndPaywallScreen`](lib/screens/trial_and_paywall_screen.dart), usuários com código promocional (ex.: **`PRISMA30`**) validam o cupom via RPC `redeem_promo_code` no Supabase, liberando 30 dias de acesso imediato e exibindo no topo do painel o banner dinâmico `"Período gratuito ativo: restam X dias"`.
- **Assinatura por Plano:** A tela identifica automaticamente o plano do nicho (`R$ 49,00/mês` para `comercio_49` ou `R$ 97,00/mês` para `especializado_97`), abre o checkout externo via `url_launcher` e oferece revalidação imediata com o botão **"Já paguei / Verificar acesso"**.

---

## 5. Stack Técnica

- **Frontend:** Flutter (Web & Mobile) · Dart 3 · Material 3 · `ChangeNotifier` + `InheritedWidget`
- **Backend & Banco de Dados:** Supabase (Auth, PostgreSQL, Row Level Security, RPCs PL/pgSQL)
- **Localização e Formatação:** `flutter_localizations` + `intl` (`pt-BR`, moeda `R$` e datas `dd/MM/yyyy`)
- **Links Externos & Web:** `url_launcher` · deploy contínuo via **Vercel** ([`vercel.json`](vercel.json))

---

## 6. Como Executar e Validar Localmente

### Pré-requisitos
- Flutter SDK (`stable`, Dart >= 3.x)
- Conta/projeto Supabase configurado com as migrations em [`supabase/migrations/`](supabase/migrations/)

### Comandos Essenciais

```bash
# 1. Instalar dependências
flutter pub get

# 2. Executar análise estática (0 erros e 0 avisos)
flutter analyze

# 3. Rodar toda a suíte de testes unitários e de widgets
flutter test

# 4. Executar localmente no navegador (Chrome)
flutter run -d chrome

# 5. Gerar build de produção para Web
flutter build web --release
```

---

## 7. Estrutura Principal do Repositório

```text
lib/
├── config/
│   └── niche_config.dart          # Motor Camaleão (5 nichos + ActiveNicheContext)
├── core/
│   ├── theme/                     # AppColors (WCAG AA) e AppTheme.forNiche
│   ├── utils/                     # Formatadores pt-BR e abertura de URLs
│   └── widgets/                   # LogoutAction e TutorialHelpAction
├── models/
│   └── user_profile.dart          # Modelo de perfil, trial e assinatura
├── services/
│   └── subscription_service.dart  # Integração com public.profiles e RPC redeem_promo_code
├── screens/
│   └── trial_and_paywall_screen.dart  # Ativação de cupom PRISMA30 e assinatura
├── widgets/
│   ├── access_gate.dart           # Portão de acesso e sincronização de nicho
│   └── niche_scope.dart           # InheritedWidget e NicheSwitcherAction
├── modules/                       # Auth, Pipeline, Customers, Billing, CashFlow
└── features/follow_up/            # Pós-Venda, Retornos e Avaliação 1–5 estrelas
```
