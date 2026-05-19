class RightsAnalysis {
  final bool violationDetected;
  final String violationType;
  final String legalBasis;
  final double maxAllowed;
  final double actualCharged;
  final double amountOwed;
  final int haqScore;
  final String haqReasoning;
  final String precedents;
  final String confidenceLevel;

  RightsAnalysis({
    required this.violationDetected,
    required this.violationType,
    required this.legalBasis,
    required this.maxAllowed,
    required this.actualCharged,
    required this.amountOwed,
    required this.haqScore,
    required this.haqReasoning,
    required this.precedents,
    required this.confidenceLevel,
  });

  factory RightsAnalysis.fromJson(Map<String, dynamic> json) {
    return RightsAnalysis(
      violationDetected: json['violationDetected'] ?? false,
      violationType: json['violationType'] ?? 'None',
      legalBasis: json['legalBasis'] ?? 'N/A',
      maxAllowed: (json['maxAllowed'] ?? 0.0).toDouble(),
      actualCharged: (json['actualCharged'] ?? 0.0).toDouble(),
      amountOwed: (json['amountOwed'] ?? 0.0).toDouble(),
      haqScore: json['haqScore'] ?? 0,
      haqReasoning: json['haqReasoning'] ?? '',
      precedents: json['precedents'] ?? '',
      confidenceLevel: json['confidenceLevel'] ?? 'LOW',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'violationDetected': violationDetected,
      'violationType': violationType,
      'legalBasis': legalBasis,
      'maxAllowed': maxAllowed,
      'actualCharged': actualCharged,
      'amountOwed': amountOwed,
      'haqScore': haqScore,
      'haqReasoning': haqReasoning,
      'precedents': precedents,
      'confidenceLevel': confidenceLevel,
    };
  }
}
