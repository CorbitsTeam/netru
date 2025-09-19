class NewsModel {
  final String id; // Changed to String for UUID
  final String title;
  final String? titleAr;
  final String content;
  final String? contentAr;
  final String summary;
  final String? summaryEn;
  final String? imageUrl;
  final String? externalId;
  final String? externalUrl;
  final String? sourceUrl;
  final String? sourceName;
  final int? categoryId;
  final String? categoryName;
  final String status;
  final bool isPublished;
  final bool isFeatured;
  final int viewCount;
  final DateTime publishedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  NewsModel({
    required this.id,
    required this.title,
    this.titleAr,
    required this.content,
    this.contentAr,
    required this.summary,
    this.summaryEn,
    this.imageUrl,
    this.externalId,
    this.externalUrl,
    this.sourceUrl,
    this.sourceName,
    this.categoryId,
    this.categoryName,
    this.status = 'published',
    this.isPublished = true,
    this.isFeatured = false,
    this.viewCount = 0,
    required this.publishedAt,
    this.createdAt,
    this.updatedAt,
  });

  // Factory constructor for creating from database/API JSON
  factory NewsModel.fromJson(Map<String, dynamic> json) {
    // Generate a UUID if the original ID is null
    String generateId() {
      return json['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString();
    }

    return NewsModel(
      id: json['id']?.toString() ?? generateId(),
      title: json['title'] ?? '',
      titleAr: json['title_ar'],
      content: json['content_text'] ?? json['content'] ?? '',
      contentAr: json['content_text_ar'] ?? json['content_ar'],
      summary: json['summary'] ?? json['title'] ?? '',
      summaryEn: json['summary_en'],
      imageUrl: json['image_url'] ?? json['image'],
      externalId: json['external_id'],
      externalUrl: json['external_url'] ?? json['details_url'],
      sourceUrl: json['source_url'],
      sourceName: json['source_name'] ?? json['author_name'],
      categoryId: json['category_id'],
      categoryName:
          json['category_name'] ?? json['category_name_ar'] ?? json['category'],
      status: json['status'] ?? 'published',
      isPublished: json['is_published'] ?? (json['status'] == 'published'),
      isFeatured: json['is_featured'] ?? false,
      viewCount: json['view_count'] ?? json['views_count'] ?? 0,
      publishedAt:
          _parseDateTime(json['published_at'] ?? json['date']) ??
          DateTime.now(),
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
    );
  }

  // Factory constructor for legacy JSON format (backwards compatibility)
  factory NewsModel.fromLegacyJson(Map<String, dynamic> json) {
    int generateId() {
      final title = json['title'] ?? '';
      final date = json['date'] ?? '';
      return (title + date).hashCode.abs();
    }

    return NewsModel(
      id: json['id'] ?? generateId(),
      title: json['title'] ?? '',
      content: json['content_text'] ?? '',
      summary: json['summary'] ?? '',
      imageUrl: json['image'],
      externalUrl: json['details_url'],
      categoryName: json['category'] ?? '',
      publishedAt: _parseDateTime(json['date']) ?? DateTime.now(),
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      // Try different date formats
      try {
        return DateTime.parse(value);
      } catch (e) {
        // Try parsing different formats like 2025/9/16
        try {
          final parts = value.split('/');
          if (parts.length == 3) {
            return DateTime(
              int.parse(parts[0]),
              int.parse(parts[1]),
              int.parse(parts[2]),
            );
          }
        } catch (e) {
          // Return null if parsing fails
        }
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'title_ar': titleAr,
      'content_text': content,
      'content_text_ar': contentAr,
      'image_url': imageUrl,
      'external_id': externalId,
      'author_name': sourceName,
      'category_id': categoryId,
      'status': status,
      'is_published': isPublished,
      'is_featured': isFeatured,
      'views_count': viewCount,
      'published_at': publishedAt.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }

  NewsModel copyWith({
    String? id,
    String? title,
    String? titleAr,
    String? content,
    String? contentAr,
    String? summary,
    String? summaryEn,
    String? imageUrl,
    String? externalId,
    String? externalUrl,
    String? sourceUrl,
    String? sourceName,
    int? categoryId,
    String? categoryName,
    String? status,
    bool? isPublished,
    bool? isFeatured,
    int? viewCount,
    DateTime? publishedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NewsModel(
      id: id ?? this.id,
      title: title ?? this.title,
      titleAr: titleAr ?? this.titleAr,
      content: content ?? this.content,
      contentAr: contentAr ?? this.contentAr,
      summary: summary ?? this.summary,
      summaryEn: summaryEn ?? this.summaryEn,
      imageUrl: imageUrl ?? this.imageUrl,
      externalId: externalId ?? this.externalId,
      externalUrl: externalUrl ?? this.externalUrl,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      sourceName: sourceName ?? this.sourceName,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      status: status ?? this.status,
      isPublished: isPublished ?? this.isPublished,
      isFeatured: isFeatured ?? this.isFeatured,
      viewCount: viewCount ?? this.viewCount,
      publishedAt: publishedAt ?? this.publishedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Getter methods for backwards compatibility
  String get date => publishedAt.toString().split(' ').first;
  String? get image => imageUrl;
  String? get detailsUrl => externalUrl;
  String get category => categoryName ?? '';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NewsModel &&
        other.id == id &&
        other.title == title &&
        other.publishedAt == publishedAt &&
        other.imageUrl == imageUrl &&
        other.content == content &&
        other.summary == summary &&
        other.externalUrl == externalUrl &&
        other.categoryName == categoryName;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        publishedAt.hashCode ^
        imageUrl.hashCode ^
        content.hashCode ^
        summary.hashCode ^
        externalUrl.hashCode ^
        categoryName.hashCode;
  }

  @override
  String toString() {
    return 'NewsModel(id: $id, title: $title, publishedAt: $publishedAt, categoryName: $categoryName)';
  }
}
