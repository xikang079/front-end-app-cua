class Trader {
  final String id;
  final String name;
  final String phone;

  Trader({
    required this.id,
    required this.name,
    required this.phone,
  });

  factory Trader.fromJson(Map<String, dynamic> json) {
    return Trader(
      id: json['_id'],
      name: json['name'],
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'phone': phone,
    };
  }
}
