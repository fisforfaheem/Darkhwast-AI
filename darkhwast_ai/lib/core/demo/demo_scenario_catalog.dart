import 'package:flutter/material.dart';

/// Curated judge-demo scenarios with full pipeline metadata.
class DemoScenario {
  const DemoScenario({
    required this.id,
    required this.titleUrdu,
    required this.titleEn,
    required this.authority,
    required this.hook,
    required this.haqScore,
    required this.urgencyBadge,
    required this.urgencyColor,
    required this.demoOcrText,
    required this.icon,
    this.hasCollective = false,
    this.hasGhostDeadline = false,
  });

  final String id;
  final String titleUrdu;
  final String titleEn;
  final String authority;
  final String hook;
  final int haqScore;
  final String urgencyBadge;
  final Color urgencyColor;
  final String demoOcrText;
  final IconData icon;
  final bool hasCollective;
  final bool hasGhostDeadline;
}

class DemoScanLaunch {
  const DemoScanLaunch({
    required this.scenarioId,
    this.runDemoImmediately = false,
  });

  final String scenarioId;
  final bool runDemoImmediately;
}

class DemoScenarioCatalog {
  DemoScenarioCatalog._();

  static const scenarios = [
    DemoScenario(
      id: 'electricity_bill',
      titleUrdu: 'IESCO Bijli Bill',
      titleEn: 'IESCO Electricity Bill',
      authority: 'IESCO / NEPRA',
      hook: 'FCA overcharge — HAQ 81, Rs 1,600 refund, 29 log collective case',
      haqScore: 81,
      urgencyBadge: '6 din — monitor',
      urgencyColor: Color(0xFF0D3B44),
      icon: Icons.bolt_rounded,
      hasCollective: true,
      demoOcrText: '''
IESCO Islamabad Electricity Bill
Consumer: 13 14115 0123456 U
Billing Month: April 2026
Units Consumed: 450 (Slab B2)
Total Amount: Rs 18,500
Fuel Cost Adjustment (FCA): Rs 3,800
Due Date: 20 May 2026
Note: FCA charged above NEPRA slab B2 maximum of Rs 2,200 per QTA Circular May 2025 Section 4(b).
''',
    ),
    DemoScenario(
      id: 'tax_notice',
      titleUrdu: 'FBR Tax Notice',
      titleEn: 'FBR Section 122 Notice',
      authority: 'FBR',
      hook: 'Ghost Deadline Detector — chhupi hui 4-din ki deadline footnote mein',
      haqScore: 55,
      urgencyBadge: 'URGENT — 4 din',
      urgencyColor: Color(0xFFC0392B),
      icon: Icons.account_balance_rounded,
      hasGhostDeadline: true,
      demoOcrText: '''
FBR Income Tax Department
Notice under Section 122 Income Tax Ordinance 2001
NTN: 7654321
Assessment Demand: Rs 125,000
Notice Date: 12 May 2026
Response required within 4 days — see footnote (iii) on page 2 regarding statutory response window.
''',
    ),
    DemoScenario(
      id: 'bisp_letter',
      titleUrdu: 'BISP Status Letter',
      titleEn: 'BISP Rejection Letter',
      authority: 'BISP',
      hook: 'Procedural unfairness — appeal ka poora haq, HAQ 75',
      haqScore: 75,
      urgencyBadge: '32 din — appeal',
      urgencyColor: Color(0xFF0D3B44),
      icon: Icons.family_restroom_rounded,
      demoOcrText: '''
Benazir Income Support Programme
Application Status: REJECTED
CNIC: 37405-1234567-1
Reason cited: Missing socio-economic survey data
Letter Date: 15 April 2026
Appeal window open until 15 June 2026 per BISP Grievance Redressal Mechanism 2023 Section 6.
''',
    ),
  ];

  static DemoScenario? byId(String id) {
    for (final s in scenarios) {
      if (s.id == id) return s;
    }
    return null;
  }
}
