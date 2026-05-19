enum UrgencyLevel {
  low,
  medium,
  high,
  critical
}

class DeadlineAlert {
  final String label;
  final String date;
  final int daysRemaining;
  final bool isHidden;
  final UrgencyLevel urgencyLevel;

  DeadlineAlert({
    required this.label,
    required this.date,
    required this.daysRemaining,
    required this.isHidden,
    required this.urgencyLevel,
  });

  factory DeadlineAlert.fromJson(Map<String, dynamic> json) {
    return DeadlineAlert(
      label: json['label'] ?? 'Deadline',
      date: json['date'] ?? '',
      daysRemaining: json['daysRemaining'] ?? 0,
      isHidden: json['isHidden'] ?? false,
      urgencyLevel: UrgencyLevel.values.firstWhere(
        (e) => e.name == json['urgencyLevel'],
        orElse: () => UrgencyLevel.low,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'date': date,
      'daysRemaining': daysRemaining,
      'isHidden': isHidden,
      'urgencyLevel': urgencyLevel.name,
    };
  }
}
