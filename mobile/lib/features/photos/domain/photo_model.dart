import '../../../core/config/api_config.dart';

class PhotoModel {
  final String id;
  final String patientId;
  final String cloudinaryPublicId;
  final String imageUrl;
  final String category;
  final DateTime documentationDate;
  final String notes;
  final DateTime? createdAt;

  PhotoModel({
    required this.id,
    required this.patientId,
    required this.cloudinaryPublicId,
    required this.imageUrl,
    required this.category,
    required this.documentationDate,
    required this.notes,
    this.createdAt,
  });

  factory PhotoModel.fromJson(Map<String, dynamic> json) {
    // patientId can be an object or string
    String pId = '';
    if (json['patientId'] is Map) {
      pId = json['patientId']['_id'] ?? json['patientId']['patientId'] ?? '';
    } else if (json['patientId'] is String) {
      pId = json['patientId'];
    }

    final rawUrl = json['imageUrl'] ?? '';
    final normalizedUrl = ApiConfig.normalizeImageUrl(rawUrl);

    return PhotoModel(
      id: json['_id'] ?? json['id'] ?? '',
      patientId: pId,
      cloudinaryPublicId: json['cloudinaryPublicId'] ?? '',
      imageUrl: normalizedUrl,
      category: json['category'] ?? 'General',
      documentationDate: json['documentationDate'] != null
          ? DateTime.tryParse(json['documentationDate']) ?? DateTime.now()
          : DateTime.now(),
      notes: json['notes'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }

  PhotoModel copyWith({
    String? id,
    String? patientId,
    String? cloudinaryPublicId,
    String? imageUrl,
    String? category,
    DateTime? documentationDate,
    String? notes,
    DateTime? createdAt,
  }) {
    return PhotoModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      cloudinaryPublicId: cloudinaryPublicId ?? this.cloudinaryPublicId,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      documentationDate: documentationDate ?? this.documentationDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
