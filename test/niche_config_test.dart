// test/niche_config_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_crm/config/niche_config.dart';
import 'package:simple_crm/core/theme/app_theme.dart';
import 'package:simple_crm/models/user_profile.dart';
import 'package:simple_crm/modules/pipeline/models/deal_entity.dart';

void main() {
  group('Sprint 3 & 5 — Motor Camaleão (NicheConfig)', () {
    test('mapeia corretamente os 5 nichos oficiais da suite Prisma Gestao', () {
      expect(NicheConfig.all.length, 5);

      // 1. SimpleCRM
      final simplecrm = NicheConfig.fromKey('simplecrm');
      expect(simplecrm.niche, PrismaNiche.simplecrm);
      expect(simplecrm.appName, 'Prisma Gestão | SimpleCRM');
      expect(simplecrm.primaryColor, const Color(0xFF006D68));
      expect(simplecrm.monthlyPriceLabel, 'R\$ 49,00/mês');
      expect(simplecrm.planTier, 'comercio_49');
      expect(simplecrm.customersTabLabel, 'Clientes');
      expect(simplecrm.pipelineTabLabel, 'Pipeline');
      expect(simplecrm.pipelineEntityPlural, 'Oportunidades');
      expect(simplecrm.billingTabLabel, 'Faturamento');
      expect(simplecrm.cashFlowTabLabel, 'Caixa');
      expect(simplecrm.followUpTabLabel, 'Pós-Venda');
      expect(simplecrm.newDealButtonLabel, 'Nova Oportunidade');
      expect(simplecrm.customerSingular, 'Cliente');
      expect(simplecrm.newCustomerLabel, 'Novo Cliente');
      expect(simplecrm.dealSingular, 'Oportunidade');
      expect(simplecrm.invoiceSingular, 'Fatura');
      expect(simplecrm.stageLabel(DealStage.activeClient), 'Cliente Ativo');

      // 2. Clínica
      final clinica = NicheConfig.fromKey('clinica');
      expect(clinica.niche, PrismaNiche.clinica);
      expect(clinica.appName, 'Prisma Gestão | Clínica');
      expect(clinica.primaryColor, const Color(0xFF1565C0));
      expect(clinica.monthlyPriceLabel, 'R\$ 97,00/mês');
      expect(clinica.planTier, 'especializado_97');
      expect(clinica.customersTabLabel, 'Pacientes');
      expect(clinica.pipelineTabLabel, 'Atendimentos');
      expect(clinica.pipelineEntityPlural, 'Tratamentos');
      expect(clinica.billingTabLabel, 'Recibos / Faturas');
      expect(clinica.cashFlowTabLabel, 'Caixa');
      expect(clinica.followUpTabLabel, 'Retornos');
      expect(clinica.newDealButtonLabel, 'Novo Orçamento');
      expect(clinica.customerSingular, 'Paciente');
      expect(clinica.newCustomerLabel, 'Novo Paciente');
      expect(clinica.dealSingular, 'Orçamento / Tratamento');
      expect(clinica.invoiceSingular, 'Recibo / Fatura');
      expect(clinica.stageLabel(DealStage.activeClient), 'Em Tratamento');

      // 3. Vet&Pet
      final vetPet = NicheConfig.fromKey('vet_pet');
      expect(vetPet.niche, PrismaNiche.vetPet);
      expect(vetPet.appName, 'Prisma Gestão | Vet&Pet');
      expect(vetPet.primaryColor, const Color(0xFF2E7D32));
      expect(vetPet.monthlyPriceLabel, 'R\$ 97,00/mês');
      expect(vetPet.planTier, 'especializado_97');
      expect(vetPet.customersTabLabel, 'Pets & Tutores');
      expect(vetPet.pipelineTabLabel, 'Agenda / Fluxo');
      expect(vetPet.pipelineEntityPlural, 'Consultas & Serviços');
      expect(vetPet.billingTabLabel, 'Faturamento');
      expect(vetPet.cashFlowTabLabel, 'Caixa');
      expect(vetPet.followUpTabLabel, 'Vacinas & Retornos');
      expect(vetPet.newDealButtonLabel, 'Novo Atendimento');
      expect(vetPet.customerSingular, 'Pet / Tutor');
      expect(vetPet.newCustomerLabel, 'Novo Pet / Tutor');
      expect(vetPet.dealSingular, 'Atendimento');
      expect(vetPet.invoiceSingular, 'Fatura / Atendimento');
      expect(vetPet.stageLabel(DealStage.activeClient), 'Em Atendimento');

      // 4. Imobiliária
      final imobiliaria = NicheConfig.fromKey('imobiliaria');
      expect(imobiliaria.niche, PrismaNiche.imobiliaria);
      expect(imobiliaria.appName, 'Prisma Gestão | Imobiliária');
      expect(imobiliaria.primaryColor, const Color(0xFF1E3A8A));
      expect(imobiliaria.monthlyPriceLabel, 'R\$ 97,00/mês');
      expect(imobiliaria.planTier, 'especializado_97');
      expect(imobiliaria.customersTabLabel, 'Interessados');
      expect(imobiliaria.pipelineTabLabel, 'Negociações');
      expect(imobiliaria.pipelineEntityPlural, 'Propostas & Visitas');
      expect(imobiliaria.billingTabLabel, 'Comissões / Contratos');
      expect(imobiliaria.cashFlowTabLabel, 'Caixa');
      expect(imobiliaria.followUpTabLabel, 'Pós-Venda');
      expect(imobiliaria.newDealButtonLabel, 'Nova Proposta');
      expect(imobiliaria.customerSingular, 'Interessado');
      expect(imobiliaria.newCustomerLabel, 'Novo Interessado');
      expect(imobiliaria.dealSingular, 'Proposta');
      expect(imobiliaria.invoiceSingular, 'Comissão / Contrato');
      expect(imobiliaria.stageLabel(DealStage.activeClient), 'Contrato Fechado');

      // 5. Curso
      expect(PrismaNiche.fromString('curso'), PrismaNiche.curso);
      final curso = NicheConfig.fromKey('curso');
      expect(curso.niche, PrismaNiche.curso);
      expect(curso.id, 'curso');
      expect(curso.productName, 'Prisma Gestão | Curso');
      expect(curso.shortName, 'Curso');
      expect(curso.primaryColor, const Color(0xFF4F46E5));
      expect(curso.priceLabel, 'R\$ 97,00/mês');
      expect(curso.planTier, 'especializado_97');
      expect(curso.icon, Icons.school_rounded);
      expect(curso.pipelineTabLabel, 'Matrículas');
      expect(curso.customersTabLabel, 'Alunos');
      expect(curso.billingTabLabel, 'Mensalidades');
      expect(curso.cashFlowTabLabel, 'Caixa');
      expect(curso.followUpTabLabel, 'Renovação & Retenção');
      expect(curso.customerSingular, 'Aluno');
      expect(curso.newCustomerLabel, 'Novo Aluno');
      expect(curso.dealSingular, 'Matrícula');
      expect(curso.dealTitleFieldLabel, 'Curso / Turma / Matrícula');
      expect(curso.invoiceSingular, 'Mensalidade / Fatura');
      expect(curso.newInvoiceLabel, 'Nova Mensalidade');
      expect(curso.primaryActionLabel, '+ Nova Matrícula');
      expect(curso.stageLabel(DealStage.potential), 'Interessado');
      expect(curso.stageLabel(DealStage.inNegotiation), 'Aula / Avaliação');
      expect(curso.stageLabel(DealStage.proposalSent), 'Proposta / Plano');
      expect(curso.stageLabel(DealStage.activeClient), 'Matriculado');
      expect(curso.stageLabel(DealStage.lost), 'Desistente');
    });

    test('fallback seguro para simplecrm e integracao com UserProfile e AppTheme.forNiche', () {
      expect(NicheConfig.fromKey(null).niche, PrismaNiche.simplecrm);
      expect(NicheConfig.fromKey('desconhecido').niche, PrismaNiche.simplecrm);

      for (final config in NicheConfig.all) {
        // Todos os 5 estágios do Kanban possuem rótulo preenchido
        for (final stage in DealStage.values) {
          expect(config.stageLabel(stage).trim().isNotEmpty, isTrue);
        }

        // AppTheme.forNiche aplica exatamente a cor primária do nicho
        final theme = AppTheme.forNiche(config);
        expect(theme.colorScheme.primary, config.primaryColor);
        expect(theme.appBarTheme.backgroundColor, config.primaryColor);
      }

      final profile = UserProfile.fromMap({
        'id': 'user-1',
        'email': 'vet@prisma.com',
        'niche': 'vet_pet',
        'plan_tier': 'especializado_97',
        'is_subscribed': true,
      });
      expect(profile.nicheConfig.niche, PrismaNiche.vetPet);
      expect(profile.isComercioPlan, isFalse);
      expect(profile.hasActiveAccess, isTrue);

      // Valida ActiveNicheContext para isolamento de dados por nicho
      ActiveNicheContext.set('curso');
      expect(ActiveNicheContext.current, 'curso');
      ActiveNicheContext.set('clinica');
      expect(ActiveNicheContext.current, 'clinica');
      ActiveNicheContext.reset();
      expect(ActiveNicheContext.current, 'simplecrm');
    });
  });
}
