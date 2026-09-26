class DentistModel {
  final String id;
  final String name;
  final String email;

  DentistModel({
    required this.id,
    required this.name,
    required this.email,
  });

  factory DentistModel.fromJson(Map<String, dynamic> json) {
    return DentistModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}
