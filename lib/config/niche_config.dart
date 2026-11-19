// lib/config/niche_config.dart
import 'package:flutter/material.dart';
import '../modules/pipeline/models/deal_entity.dart';

enum PrismaNiche {
  simplecrm('simplecrm'),
  clinica('clinica'),
  vetPet('vet_pet'),
  imobiliaria('imobiliaria');

  final String key;
  const PrismaNiche(this.key);

  static PrismaNiche fromKey(String? key) {
    switch (key?.trim().toLowerCase()) {
      case 'clinica':
        return PrismaNiche.clinica;
      case 'vet_pet':
        return PrismaNiche.vetPet;
      case 'imobiliaria':
        return PrismaNiche.imobiliaria;
      case 'simplecrm':
      default:
        return PrismaNiche.simplecrm;
    }
  }
}

class NicheConfig {
  final PrismaNiche niche;
  final String shortName;
  final String appName;
  final Color primaryColor;
  final Color primaryDarkColor;
  final Color primaryLightColor;
  final String planTier;
  final String monthlyPriceLabel;
  final String planSubtitle;
  final IconData icon;

  // Rótulos de navegação e módulos
  final String pipelineTabLabel;
  final String pipelineEntityPlural;
  final String customersTabLabel;
  final String billingTabLabel;
  final String cashFlowTabLabel;
  final String followUpTabLabel;
  final String newDealButtonLabel;

  // Rótulos singulares e de formulários
  final String customerSingular;
  final String newCustomerLabel;
  final String dealSingular;
  final String invoiceSingular;
  final String dealTitleFieldLabel;

  // Rótulos das etapas do Kanban (mantendo os mesmos valores internos de DealStage no Supabase)
  final Map<DealStage, String> stageLabels;

  const NicheConfig({
    required this.niche,
    required this.shortName,
    required this.appName,
    required this.primaryColor,
    required this.primaryDarkColor,
    required this.primaryLightColor,
    required this.planTier,
    required this.monthlyPriceLabel,
    required this.planSubtitle,
    required this.icon,
    required this.pipelineTabLabel,
    required this.pipelineEntityPlural,
    required this.customersTabLabel,
    required this.billingTabLabel,
    required this.cashFlowTabLabel,
    required this.followUpTabLabel,
    required this.newDealButtonLabel,
    required this.customerSingular,
    required this.newCustomerLabel,
    required this.dealSingular,
    required this.invoiceSingular,
    required this.dealTitleFieldLabel,
    required this.stageLabels,
  });

  String get key => niche.key;

  bool get isComercioPlan => planTier == 'comercio_49';

  String stageLabel(DealStage stage) => stageLabels[stage] ?? stage.name;

  static const NicheConfig simplecrm = NicheConfig(
    niche: PrismaNiche.simplecrm,
    shortName: 'SimpleCRM',
    appName: 'Prisma Gestão | SimpleCRM',
    primaryColor: Color(0xFF006D68),
    primaryDarkColor: Color(0xFF004D49),
    primaryLightColor: Color(0xFFCCFBF1),
    planTier: 'comercio_49',
    monthlyPriceLabel: 'R\$ 49,00/mês',
    planSubtitle: 'Oferta de Lançamento — Prisma Gestão | SimpleCRM',
    icon: Icons.storefront_rounded,
    pipelineTabLabel: 'Pipeline',
    pipelineEntityPlural: 'Oportunidades',
    customersTabLabel: 'Clientes',
    billingTabLabel: 'Faturamento',
    cashFlowTabLabel: 'Caixa',
    followUpTabLabel: 'Pós-Venda',
    newDealButtonLabel: 'Nova Oportunidade',
    customerSingular: 'Cliente',
    newCustomerLabel: 'Novo Cliente',
    dealSingular: 'Oportunidade',
    invoiceSingular: 'Fatura',
    dealTitleFieldLabel: 'Título da Oportunidade',
    stageLabels: {
      DealStage.potential: 'Potencial',
      DealStage.inNegotiation: 'Em Negociação',
      DealStage.proposalSent: 'Proposta Enviada',
      DealStage.activeClient: 'Cliente Ativo',
      DealStage.lost: 'Perdido',
    },
  );

  static const NicheConfig clinica = NicheConfig(
    niche: PrismaNiche.clinica,
    shortName: 'Clínica',
    appName: 'Prisma Gestão | Clínica',
    primaryColor: Color(0xFF1565C0),
    primaryDarkColor: Color(0xFF0D47A1),
    primaryLightColor: Color(0xFFDBEAFE),
    planTier: 'especializado_97',
    monthlyPriceLabel: 'R\$ 97,00/mês',
    planSubtitle: 'Plano Profissional — Prisma Gestão | Clínica',
    icon: Icons.local_hospital_rounded,
    pipelineTabLabel: 'Atendimentos',
    pipelineEntityPlural: 'Tratamentos',
    customersTabLabel: 'Pacientes',
    billingTabLabel: 'Recibos / Faturas',
    cashFlowTabLabel: 'Caixa',
    followUpTabLabel: 'Retornos',
    newDealButtonLabel: 'Novo Orçamento',
    customerSingular: 'Paciente',
    newCustomerLabel: 'Novo Paciente',
    dealSingular: 'Orçamento / Tratamento',
    invoiceSingular: 'Recibo / Fatura',
    dealTitleFieldLabel: 'Título do Orçamento / Tratamento',
    stageLabels: {
      DealStage.potential: 'Triagem / Contato',
      DealStage.inNegotiation: 'Avaliação Agendada',
      DealStage.proposalSent: 'Orçamento Enviado',
      DealStage.activeClient: 'Em Tratamento',
      DealStage.lost: 'Não Aprovado',
    },
  );

  static const NicheConfig vetPet = NicheConfig(
    niche: PrismaNiche.vetPet,
    shortName: 'Vet&Pet',
    appName: 'Prisma Gestão | Vet&Pet',
    primaryColor: Color(0xFF2E7D32),
    primaryDarkColor: Color(0xFF1B5E20),
    primaryLightColor: Color(0xFFDCFCE7),
    planTier: 'especializado_97',
    monthlyPriceLabel: 'R\$ 97,00/mês',
    planSubtitle: 'Plano Profissional — Prisma Gestão | Vet&Pet',
    icon: Icons.pets_rounded,
    pipelineTabLabel: 'Agenda / Fluxo',
    pipelineEntityPlural: 'Consultas & Serviços',
    customersTabLabel: 'Pets & Tutores',
    billingTabLabel: 'Faturamento',
    cashFlowTabLabel: 'Caixa',
    followUpTabLabel: 'Vacinas & Retornos',
    newDealButtonLabel: 'Novo Atendimento',
    customerSingular: 'Pet / Tutor',
    newCustomerLabel: 'Novo Pet / Tutor',
    dealSingular: 'Atendimento',
    invoiceSingular: 'Fatura / Atendimento',
    dealTitleFieldLabel: 'Título do Atendimento',
    stageLabels: {
      DealStage.potential: 'Novo Contato',
      DealStage.inNegotiation: 'Triagem / Agendado',
      DealStage.proposalSent: 'Orçamento / Exames',
      DealStage.activeClient: 'Em Atendimento',
      DealStage.lost: 'Cancelado',
    },
  );

  static const NicheConfig imobiliaria = NicheConfig(
    niche: PrismaNiche.imobiliaria,
    shortName: 'Imobiliária',
    appName: 'Prisma Gestão | Imobiliária',
    primaryColor: Color(0xFF1E3A8A),
    primaryDarkColor: Color(0xFF172554),
    primaryLightColor: Color(0xFFE0E7FF),
    planTier: 'especializado_97',
    monthlyPriceLabel: 'R\$ 97,00/mês',
    planSubtitle: 'Plano Profissional — Prisma Gestão | Imobiliária',
    icon: Icons.apartment_rounded,
    pipelineTabLabel: 'Negociações',
    pipelineEntityPlural: 'Propostas & Visitas',
    customersTabLabel: 'Interessados',
    billingTabLabel: 'Comissões / Contratos',
    cashFlowTabLabel: 'Caixa',
    followUpTabLabel: 'Pós-Venda',
    newDealButtonLabel: 'Nova Proposta',
    customerSingular: 'Interessado',
    newCustomerLabel: 'Novo Interessado',
    dealSingular: 'Proposta',
    invoiceSingular: 'Comissão / Contrato',
    dealTitleFieldLabel: 'Título da Proposta',
    stageLabels: {
      DealStage.potential: 'Novo Lead',
      DealStage.inNegotiation: 'Visita Agendada',
      DealStage.proposalSent: 'Proposta Enviada',
      DealStage.activeClient: 'Contrato Fechado',
      DealStage.lost: 'Desistência',
    },
  );

  static const List<NicheConfig> all = [
    simplecrm,
    clinica,
    vetPet,
    imobiliaria,
  ];

  static NicheConfig fromNiche(PrismaNiche niche) {
    switch (niche) {
      case PrismaNiche.clinica:
        return clinica;
      case PrismaNiche.vetPet:
        return vetPet;
      case PrismaNiche.imobiliaria:
        return imobiliaria;
      case PrismaNiche.simplecrm:
        return simplecrm;
    }
  }

  static NicheConfig fromKey(String? key) =>
      fromNiche(PrismaNiche.fromKey(key));
}
