class PatientModel {
  final String id;
  final String patientId;
  final String name;
  final DateTime dateOfBirth;
  final String gender;
  final String phone;
  final String? additionalInformation;
  final int photoCount;
  final DateTime? latestDocumentationDate;
  final DateTime? createdAt;

  PatientModel({
    required this.id,
    required this.patientId,
    required this.name,
    required this.dateOfBirth,
    required this.gender,
    required this.phone,
    this.additionalInformation,
    this.photoCount = 0,
    this.latestDocumentationDate,
    this.createdAt,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: json['_id'] ?? json['id'] ?? '',
      patientId: json['patientId'] ?? '',
      name: json['name'] ?? '',
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth']) ?? DateTime.now()
          : DateTime.now(),
      gender: json['gender'] ?? 'Other',
      phone: json['phone'] ?? '',
      additionalInformation: json['additionalInformation'],
      photoCount: json['photoCount'] ?? 0,
      latestDocumentationDate: json['latestDocumentationDate'] != null
          ? DateTime.tryParse(json['latestDocumentationDate'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'gender': gender,
      'phone': phone,
      if (additionalInformation != null) 'additionalInformation': additionalInformation,
    };
  }

  PatientModel copyWith({
    String? id,
    String? patientId,
    String? name,
    DateTime? dateOfBirth,
    String? gender,
    String? phone,
    String? additionalInformation,
    int? photoCount,
    DateTime? latestDocumentationDate,
    DateTime? createdAt,
  }) {
    return PatientModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      phone: phone ?? this.phone,
      additionalInformation: additionalInformation ?? this.additionalInformation,
      photoCount: photoCount ?? this.photoCount,
      latestDocumentationDate: latestDocumentationDate ?? this.latestDocumentationDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
