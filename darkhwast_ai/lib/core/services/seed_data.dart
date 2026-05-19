import '../models/collective_cluster.dart';

class SeedData {
  static Map<String, dynamic>? knowledgeFor(String docType) {
    for (final entry in knowledgeBase) {
      if (entry['docType'] == docType) {
        return Map<String, dynamic>.from(entry);
      }
    }
    // Fallback: return generic entry for unknown/other doc types
    return _genericKnowledge;
  }

  static CollectiveCluster? collectiveFor(
    String authority,
    String violationType,
  ) {
    for (final entry in collectiveClusters) {
      if (entry['authority'] == authority &&
          entry['violationType'] == violationType) {
        return CollectiveCluster(
          id: 'cluster_${authority}_${violationType}_local',
          authority: authority,
          violationType: violationType,
          area: entry['area'] as String? ?? 'Islamabad',
          count: entry['count'] as int? ?? 1,
          status: entry['status'] as String? ?? 'Open',
          collectivePetitionDrafted:
              entry['collectivePetitionDrafted'] as bool? ?? false,
        );
      }
    }
    return null;
  }

  /// Generic knowledge entry for any document type not in the specific list.
  static final Map<String, dynamic> _genericKnowledge = {
    "docType": "GENERAL",
    "authority": "Government of Pakistan",
    "regulation": "Pakistan Citizen Rights Framework",
    "section": "General Consumer Protection",
    "rule":
        "Every citizen has the right to accurate documentation, fair charges, and timely response from government authorities",
    "complaintAuthority": "Pakistan Citizens Portal",
    "responseWindow": 14,
  };

  static final List<Map<String, dynamic>> knowledgeBase = [
    {
      "docType": "ELECTRICITY_BILL",
      "authority": "NEPRA",
      "regulation": "Quarterly Tariff Adjustment Circular May 2025",
      "section": "4(b)",
      "rule": "FCA charges cannot exceed approved rate per consumption slab",
      "slabs": {
        "B1_0_100": {"maxFCA": 800},
        "B1_101_200": {"maxFCA": 1200},
        "B1_201_300": {"maxFCA": 1600},
        "B2_301_500": {"maxFCA": 2200},
        "B2_500plus": {"maxFCA": 3100}
      },
      "complaintAuthority": "NEPRA Consumer Affairs",
      "responseWindow": 14
    },
    {
      "docType": "GAS_BILL",
      "authority": "OGRA",
      "regulation": "OGRA Consumer Protection Regulations 2018",
      "section": "12(a)",
      "rule": "Meter reading must match actual reading within 5% variance",
      "complaintAuthority": "OGRA Complaint Cell",
      "responseWindow": 21
    },
    {
      "docType": "BISP_LETTER",
      "authority": "BISP",
      "regulation": "BISP Grievance Redressal Mechanism 2023",
      "section": "Section 6",
      "rule": "Every rejected applicant has right to appeal within 60 days",
      "complaintAuthority": "BISP Tehsil Office + Portal",
      "responseWindow": 30
    },
    {
      "docType": "TAX_NOTICE",
      "authority": "FBR",
      "regulation": "Income Tax Ordinance 2001",
      "section": "122",
      "rule": "Assessment notice must be responded to within 30 days",
      "complaintAuthority": "FBR Facilitation Center",
      "responseWindow": 7,
      "urgency": "HIGH"
    },
    {
      "docType": "WATER_BILL",
      "authority": "WASA",
      "regulation": "WASA Consumer Protection Rules",
      "section": "Section 15",
      "rule":
          "Water charges must be based on actual meter reading; estimated billing requires prior notice",
      "complaintAuthority": "WASA Complaint Center",
      "responseWindow": 14
    },
    {
      "docType": "PROPERTY_TAX",
      "authority": "Excise & Taxation",
      "regulation": "Punjab Urban Immovable Property Tax Act 1958",
      "section": "Section 5",
      "rule":
          "Property tax assessment must reflect actual property value; citizen can challenge within 30 days",
      "complaintAuthority": "Excise & Taxation Office",
      "responseWindow": 30
    },
    {
      "docType": "PENSION_NOTICE",
      "authority": "Accountant General",
      "regulation": "Civil Service Pension Rules",
      "section": "Section 12",
      "rule":
          "Pension must be processed within 60 days of retirement; delays are actionable",
      "complaintAuthority": "Federal Ombudsman / AG Office",
      "responseWindow": 30
    },
    {
      "docType": "NADRA_DOCUMENT",
      "authority": "NADRA",
      "regulation": "NADRA Ordinance 2000",
      "section": "Section 9",
      "rule":
          "Every citizen has the right to accurate CNIC data; corrections must be processed within 30 days",
      "complaintAuthority": "NADRA Regional Office",
      "responseWindow": 30
    },
    {
      "docType": "POLICE_CHALLAN",
      "authority": "Police Department",
      "regulation": "National Highways Safety Ordinance 2000",
      "section": "Section 89",
      "rule":
          "Traffic challan must specify exact violation and fine amount; citizen can challenge in traffic court",
      "complaintAuthority": "Traffic Police / Session Court",
      "responseWindow": 15
    },
    {
      "docType": "SCHOOL_FEE",
      "authority": "Private Educational Institutions Regulatory Authority",
      "regulation": "PEIRA Act 2018",
      "section": "Section 7",
      "rule":
          "Fee increase cannot exceed 5% annually without regulatory approval",
      "complaintAuthority": "PEIRA Complaint Cell",
      "responseWindow": 21
    },
    {
      "docType": "MUNICIPAL_NOTICE",
      "authority": "Municipal Corporation",
      "regulation": "Local Government Act",
      "section": "Various",
      "rule":
          "Municipal notices must provide 15 days response window; citizen has right to hearing",
      "complaintAuthority": "Municipal Corporation / DC Office",
      "responseWindow": 15
    },
    {
      "docType": "LEGAL_NOTICE",
      "authority": "Judiciary",
      "regulation": "Code of Civil Procedure 1908",
      "section": "Section 80",
      "rule":
          "Legal notices require 60-day response window; failure to respond does not constitute acceptance",
      "complaintAuthority": "District Court / Bar Council",
      "responseWindow": 60,
      "urgency": "HIGH"
    },
  ];

  static final List<Map<String, dynamic>> collectiveClusters = [
    {
      "authority": "IESCO",
      "violationType": "FCA_Overcharge",
      "area": "Islamabad",
      "month": "May 2026",
      "count": 29,
      "status": "Open",
      "collectivePetitionDrafted": true
    }
  ];
}
