import 'crabtype_model.dart';
import 'trader_model.dart';

class CrabPurchase {
  String id;
  Trader trader;
  List<CrabDetail> crabs;
  double totalCost;
  DateTime createdAt;
  DateTime updatedAt;

  CrabPurchase({
    required this.id,
    required this.trader,
    required this.crabs,
    required this.totalCost,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CrabPurchase.fromJson(Map<String, dynamic> json) {
    return CrabPurchase(
      id: json['_id'] ?? '',
      trader: Trader.fromJson(json['trader'] ?? {}),
      crabs: List<CrabDetail>.from(
        (json['crabs'] ?? []).map((crab) => CrabDetail.fromJson(crab)),
      ),
      totalCost: (json['totalCost'] ?? 0).toDouble(),
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'trader': trader.toJson(),
      'crabs': crabs.map((crab) => crab.toJson()).toList(),
      'totalCost': totalCost,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class CrabDetail {
  CrabType crabType;
  double weight;
  double pricePerKg;
  double totalCost;

  CrabDetail({
    required this.crabType,
    required this.weight,
    required this.pricePerKg,
    required this.totalCost,
  });

  factory CrabDetail.fromJson(Map<String, dynamic> json) {
    return CrabDetail(
      crabType: CrabType.fromJson(json['crabType'] ?? {}),
      weight: (json['weight'] ?? 0).toDouble(),
      pricePerKg: (json['pricePerKg'] ?? 0).toDouble(),
      totalCost: (json['totalCost'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'crabType': crabType.toJson(),
      'weight': weight,
      'pricePerKg': pricePerKg,
      'totalCost': totalCost,
    };
  }
}
