enum DocumentType {
  electricityBill,
  gasBill,
  bispLetter,
  taxNotice,
  courtNotice,
  waterBill,
  propertyTax,
  pensionNotice,
  nadraDocument,
  policeChallan,
  schoolFee,
  municipalNotice,
  governmentForm,
  legalNotice,
  other,
  unknown,
}

extension DocumentTypeKeys on DocumentType {
  String get knowledgeBaseKey {
    switch (this) {
      case DocumentType.electricityBill:
        return 'ELECTRICITY_BILL';
      case DocumentType.gasBill:
        return 'GAS_BILL';
      case DocumentType.bispLetter:
        return 'BISP_LETTER';
      case DocumentType.taxNotice:
        return 'TAX_NOTICE';
      case DocumentType.courtNotice:
        return 'COURT_NOTICE';
      case DocumentType.waterBill:
        return 'WATER_BILL';
      case DocumentType.propertyTax:
        return 'PROPERTY_TAX';
      case DocumentType.pensionNotice:
        return 'PENSION_NOTICE';
      case DocumentType.nadraDocument:
        return 'NADRA_DOCUMENT';
      case DocumentType.policeChallan:
        return 'POLICE_CHALLAN';
      case DocumentType.schoolFee:
        return 'SCHOOL_FEE';
      case DocumentType.municipalNotice:
        return 'MUNICIPAL_NOTICE';
      case DocumentType.governmentForm:
        return 'GOVERNMENT_FORM';
      case DocumentType.legalNotice:
        return 'LEGAL_NOTICE';
      case DocumentType.other:
        return 'OTHER';
      case DocumentType.unknown:
        return 'UNKNOWN';
    }
  }

  String get displayName {
    switch (this) {
      case DocumentType.electricityBill:
        return 'Electricity Bill';
      case DocumentType.gasBill:
        return 'Gas Bill';
      case DocumentType.bispLetter:
        return 'BISP Letter';
      case DocumentType.taxNotice:
        return 'Tax Notice';
      case DocumentType.courtNotice:
        return 'Court Notice';
      case DocumentType.waterBill:
        return 'Water/Sewerage Bill';
      case DocumentType.propertyTax:
        return 'Property Tax Notice';
      case DocumentType.pensionNotice:
        return 'Pension Notice';
      case DocumentType.nadraDocument:
        return 'NADRA Document';
      case DocumentType.policeChallan:
        return 'Police Challan';
      case DocumentType.schoolFee:
        return 'School Fee Slip';
      case DocumentType.municipalNotice:
        return 'Municipal Notice';
      case DocumentType.governmentForm:
        return 'Government Form';
      case DocumentType.legalNotice:
        return 'Legal Notice';
      case DocumentType.other:
        return 'Other Document';
      case DocumentType.unknown:
        return 'Unknown Document';
    }
  }

  String get displayNameUrdu {
    switch (this) {
      case DocumentType.electricityBill:
        return 'بجلی کا بل';
      case DocumentType.gasBill:
        return 'گیس کا بل';
      case DocumentType.bispLetter:
        return 'بی آئی ایس پی خط';
      case DocumentType.taxNotice:
        return 'ٹیکس نوٹس';
      case DocumentType.courtNotice:
        return 'عدالتی نوٹس';
      case DocumentType.waterBill:
        return 'پانی/سیوریج بل';
      case DocumentType.propertyTax:
        return 'پراپرٹی ٹیکس';
      case DocumentType.pensionNotice:
        return 'پنشن نوٹس';
      case DocumentType.nadraDocument:
        return 'نادرا دستاویز';
      case DocumentType.policeChallan:
        return 'پولیس چالان';
      case DocumentType.schoolFee:
        return 'سکول فیس';
      case DocumentType.municipalNotice:
        return 'بلدیاتی نوٹس';
      case DocumentType.governmentForm:
        return 'سرکاری فارم';
      case DocumentType.legalNotice:
        return 'قانونی نوٹس';
      case DocumentType.other:
        return 'دوسری دستاویز';
      case DocumentType.unknown:
        return 'نامعلوم دستاویز';
    }
  }
}

/// Safe label for UI — works even when the receiver is [dynamic].
String documentTypeDisplayName(dynamic type) {
  if (type is DocumentType) return type.displayName;
  return parseDocumentType(type).displayName;
}

DocumentType parseDocumentType(dynamic raw) {
  final normalized =
      raw?.toString().trim().toUpperCase().replaceAll(' ', '_') ?? '';
  switch (normalized) {
    case 'ELECTRICITY_BILL':
      return DocumentType.electricityBill;
    case 'GAS_BILL':
      return DocumentType.gasBill;
    case 'BISP_LETTER':
      return DocumentType.bispLetter;
    case 'TAX_NOTICE':
      return DocumentType.taxNotice;
    case 'COURT_NOTICE':
      return DocumentType.courtNotice;
    case 'WATER_BILL':
      return DocumentType.waterBill;
    case 'PROPERTY_TAX':
      return DocumentType.propertyTax;
    case 'PENSION_NOTICE':
      return DocumentType.pensionNotice;
    case 'NADRA_DOCUMENT':
      return DocumentType.nadraDocument;
    case 'POLICE_CHALLAN':
      return DocumentType.policeChallan;
    case 'SCHOOL_FEE':
      return DocumentType.schoolFee;
    case 'MUNICIPAL_NOTICE':
      return DocumentType.municipalNotice;
    case 'GOVERNMENT_FORM':
      return DocumentType.governmentForm;
    case 'LEGAL_NOTICE':
      return DocumentType.legalNotice;
    case 'OTHER':
      return DocumentType.other;
    default:
      return DocumentType.values.firstWhere(
        (e) => e.name == raw?.toString(),
        orElse: () => DocumentType.unknown,
      );
  }
}

class DocumentEntity {
  final DocumentType type;
  final String authority;
  final String? consumerRef;
  final List<Map<String, dynamic>> amounts;
  final List<Map<String, dynamic>> dates;
  final List<Map<String, dynamic>> deadlines;
  final List<String> keyFacts;
  final Map<String, dynamic> rawAmountsBilled;

  DocumentEntity({
    required this.type,
    required this.authority,
    this.consumerRef,
    required this.amounts,
    required this.dates,
    required this.deadlines,
    required this.keyFacts,
    required this.rawAmountsBilled,
  });

  factory DocumentEntity.fromJson(Map<String, dynamic> json) {
    return DocumentEntity(
      type: parseDocumentType(json['documentType']),
      authority: json['authority'] ?? 'Unknown',
      consumerRef: json['consumerRef'],
      amounts: List<Map<String, dynamic>>.from(json['amounts'] ?? []),
      dates: List<Map<String, dynamic>>.from(json['dates'] ?? []),
      deadlines: List<Map<String, dynamic>>.from(json['deadlines'] ?? []),
      keyFacts: List<String>.from(json['keyFacts'] ?? []),
      rawAmountsBilled: Map<String, dynamic>.from(
        json['rawAmountsBilled'] ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'documentType': type.name,
      'authority': authority,
      'consumerRef': consumerRef,
      'amounts': amounts,
      'dates': dates,
      'deadlines': deadlines,
      'keyFacts': keyFacts,
      'rawAmountsBilled': rawAmountsBilled,
    };
  }
}
