import '../../domain/entities/report_summary_entity.dart';

class ReportSummaryModel extends ReportSummaryEntity {
  const ReportSummaryModel({
    required super.id,
    required super.title,
    required super.description,
    required super.status,
    required super.priority,
    super.categoryName,
    super.governorate,
    super.city,
    required super.createdAt,
    required super.updatedAt,
    super.assignedToName,
    super.mediaCount = 0,
    super.commentsCount = 0,
  });

  factory ReportSummaryModel.fromJson(Map<String, dynamic> json) {
    return ReportSummaryModel(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: ReportStatusExtension.fromString(json['status'] ?? 'pending'),
      priority: ReportPriorityExtension.fromString(
        json['priority'] ?? 'medium',
      ),
      categoryName: json['category_name'],
      governorate: json['governorate'],
      city: json['city'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      assignedToName: json['assigned_to_name'],
      mediaCount: json['media_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status.value,
      'priority': priority.value,
      'category_name': categoryName,
      'governorate': governorate,
      'city': city,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'assigned_to_name': assignedToName,
      'media_count': mediaCount,
      'comments_count': commentsCount,
    };
  }
}
