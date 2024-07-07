class SummaryDetail {
  String crabType;
  double totalWeight;
  double totalCost;

  SummaryDetail({
    required this.crabType,
    required this.totalWeight,
    required this.totalCost,
  });

  factory SummaryDetail.fromJson(Map<String, dynamic> json) {
    return SummaryDetail(
      crabType: json['crabType'] ?? '',
      totalWeight: (json['totalWeight'] ?? 0).toDouble(),
      totalCost: (json['totalCost'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'crabType': crabType,
      'totalWeight': totalWeight,
      'totalCost': totalCost,
    };
  }
}

class DailySummary {
  String id;
  String depot;
  List<SummaryDetail> details;
  double totalAmount;
  DateTime createdAt;
  DateTime updatedAt;

  DailySummary({
    required this.id,
    required this.depot,
    required this.details,
    required this.totalAmount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DailySummary.fromJson(Map<String, dynamic> json) {
    return DailySummary(
      id: json['_id'] ?? '',
      depot: json['depot'] ?? '',
      details: (json['details'] as List<dynamic>?)
              ?.map((e) => SummaryDetail.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'depot': depot,
      'details': details.map((e) => e.toJson()).toList(),
      'totalAmount': totalAmount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
