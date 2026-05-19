class CollectiveCluster {
  final String? id;
  final String authority;
  final String violationType;
  final String area;
  final int count;
  final String status;
  final bool collectivePetitionDrafted;

  CollectiveCluster({
    this.id,
    required this.authority,
    required this.violationType,
    required this.area,
    required this.count,
    required this.status,
    required this.collectivePetitionDrafted,
  });

  factory CollectiveCluster.fromJson(Map<String, dynamic> json) {
    return CollectiveCluster(
      id: json['id'] as String?,
      authority: json['authority'] ?? '',
      violationType: json['violationType'] ?? '',
      area: json['area'] ?? '',
      count: json['count'] ?? 0,
      status: json['status'] ?? 'Open',
      collectivePetitionDrafted: json['collectivePetitionDrafted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'authority': authority,
      'violationType': violationType,
      'area': area,
      'count': count,
      'status': status,
      'collectivePetitionDrafted': collectivePetitionDrafted,
    };
  }
}
