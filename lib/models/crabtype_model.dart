// models/crab_type_model.dart
class CrabType {
  final String id;
  final String name;
  final double pricePerKg;

  CrabType({
    required this.id,
    required this.name,
    required this.pricePerKg,
  });

  factory CrabType.fromJson(Map<String, dynamic> json) {
    return CrabType(
      id: json['_id'],
      name: json['name'],
      pricePerKg: json['pricePerKg'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'pricePerKg': pricePerKg,
    };
  }
}
