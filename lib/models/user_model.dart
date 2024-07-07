class User {
  final String id;
  final String fullname;
  final String username;
  final String role;
  final bool status;
  final String depotName;
  final String address;
  final String phone;
  final String? resetPasswordToken;
  final DateTime? resetPasswordExpires;
  String accessToken;
  String refreshToken;

  User({
    required this.id,
    required this.fullname,
    required this.username,
    required this.role,
    required this.status,
    required this.depotName,
    required this.address,
    required this.phone,
    this.resetPasswordToken,
    this.resetPasswordExpires,
    required this.accessToken,
    required this.refreshToken,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      fullname: json['fullname'],
      username: json['username'],
      role: json['role'],
      status: json['status'],
      depotName: json['depotName'],
      address: json['address'],
      phone: json['phone'],
      resetPasswordToken: json['resetPasswordToken'],
      resetPasswordExpires: json['resetPasswordExpires'] != null
          ? DateTime.parse(json['resetPasswordExpires'])
          : null,
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fullname': fullname,
      'username': username,
      'role': role,
      'status': status,
      'depotName': depotName,
      'address': address,
      'phone': phone,
      'resetPasswordToken': resetPasswordToken,
      'resetPasswordExpires': resetPasswordExpires?.toIso8601String(),
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }
}
