class CaseModel {
  final String id;
  final String title;
  final String? titleAr;
  final String description;
  final String? descriptionAr;
  final String? imageUrl;
  final String location;
  final String? locationAr;
  final DateTime incidentDate;
  final String priority; // high, medium, low, urgent
  final String status; // pending, under_investigation, resolved, closed
  final String? caseNumber;
  final int viewCount;
  final bool isTrending;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const CaseModel({
    required this.id,
    required this.title,
    this.titleAr,
    required this.description,
    this.descriptionAr,
    this.imageUrl,
    required this.location,
    this.locationAr,
    required this.incidentDate,
    this.priority = 'medium',
    this.status = 'pending',
    this.caseNumber,
    this.viewCount = 0,
    this.isTrending = false,
    required this.createdAt,
    this.updatedAt,
  });

  factory CaseModel.fromJson(Map<String, dynamic> json) {
    return CaseModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? json['reporter_first_name'] ?? 'قضية غير محددة',
      titleAr: json['title_ar'],
      description: json['description'] ?? json['report_details'] ?? '',
      descriptionAr: json['description_ar'],
      imageUrl: json['image_url'],
      location:
          json['location'] ?? json['incident_location_address'] ?? 'غير محدد',
      locationAr: json['location_ar'],
      incidentDate:
          _parseDateTime(json['incident_date'] ?? json['incident_datetime']) ??
          DateTime.now(),
      priority: json['priority'] ?? json['priority_level'] ?? 'medium',
      status: json['status'] ?? json['report_status'] ?? 'pending',
      caseNumber: json['case_number'],
      viewCount: json['view_count'] ?? 0,
      isTrending: json['is_trending'] ?? false,
      createdAt: _parseDateTime(json['created_at']) ?? DateTime.now(),
      updatedAt: _parseDateTime(json['updated_at']),
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'title_ar': titleAr,
      'description': description,
      'description_ar': descriptionAr,
      'image_url': imageUrl,
      'location': location,
      'location_ar': locationAr,
      'incident_date': incidentDate.toIso8601String(),
      'priority': priority,
      'status': status,
      'case_number': caseNumber,
      'view_count': viewCount,
      'is_trending': isTrending,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  CaseModel copyWith({
    String? id,
    String? title,
    String? titleAr,
    String? description,
    String? descriptionAr,
    String? imageUrl,
    String? location,
    String? locationAr,
    DateTime? incidentDate,
    String? priority,
    String? status,
    String? caseNumber,
    int? viewCount,
    bool? isTrending,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CaseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      titleAr: titleAr ?? this.titleAr,
      description: description ?? this.description,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      imageUrl: imageUrl ?? this.imageUrl,
      location: location ?? this.location,
      locationAr: locationAr ?? this.locationAr,
      incidentDate: incidentDate ?? this.incidentDate,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      caseNumber: caseNumber ?? this.caseNumber,
      viewCount: viewCount ?? this.viewCount,
      isTrending: isTrending ?? this.isTrending,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper getters for display
  String get displayTitle => titleAr ?? title;
  String get displayDescription => descriptionAr ?? description;
  String get displayLocation => locationAr ?? location;

  String get priorityText {
    switch (priority) {
      case 'urgent':
        return 'عاجل';
      case 'high':
        return 'عالي';
      case 'medium':
        return 'متوسط';
      case 'low':
        return 'منخفض';
      default:
        return 'متوسط';
    }
  }

  String get statusText {
    switch (status) {
      case 'pending':
        return 'في الانتظار';
      case 'under_investigation':
        return 'قيد التحقيق';
      case 'resolved':
        return 'تم الحل';
      case 'closed':
        return 'مغلق';
      case 'rejected':
        return 'مرفوض';
      default:
        return 'في الانتظار';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CaseModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'CaseModel(id: $id, title: $title, status: $status, priority: $priority)';
  }
}
