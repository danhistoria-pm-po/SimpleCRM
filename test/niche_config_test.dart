// test/niche_config_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_crm/config/niche_config.dart';
import 'package:simple_crm/core/theme/app_theme.dart';
import 'package:simple_crm/models/user_profile.dart';
import 'package:simple_crm/modules/pipeline/models/deal_entity.dart';

void main() {
  group('Sprint 3 — Motor Camaleão (NicheConfig)', () {
    test('mapeia corretamente os 4 nichos oficiais da suite Prisma Gestao', () {
      expect(NicheConfig.all.length, 4);

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
      expect(imobiliaria.stageLabel(DealStage.activeClient), 'Contrato Fechado');
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
    });
  });
}
