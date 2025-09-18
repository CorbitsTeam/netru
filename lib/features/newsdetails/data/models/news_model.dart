class NewsModel {
  final int id;
  final String title;
  final String date;
  final String? image;
  final String content;
  final String summary;
  final String? detailsUrl;
  final String category;

  NewsModel({
    required this.id,
    required this.title,
    required this.date,
    this.image,
    required this.content,
    required this.summary,
    this.detailsUrl,
    this.category = '',
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    // Generate a hash-based ID if the original ID is null
    int generateId() {
      final title = json['title'] ?? '';
      final date = json['date'] ?? '';
      return (title + date).hashCode.abs();
    }

    return NewsModel(
      id: json['id'] ?? generateId(),
      title: json['title'] ?? '',
      date: json['date'] ?? '',
      image: json['image'],
      content: json['content_text'] ?? '',
      summary: json['summary'] ?? '',
      detailsUrl: json['details_url'],
      category: json['category'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date,
      'image': image,
      'content_text': content,
      'summary': summary,
      'details_url': detailsUrl,
      'category': category,
    };
  }

  NewsModel copyWith({
    int? id,
    String? title,
    String? date,
    String? image,
    String? content,
    String? summary,
    String? detailsUrl,
    String? category,
  }) {
    return NewsModel(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      image: image ?? this.image,
      content: content ?? this.content,
      summary: summary ?? this.summary,
      detailsUrl: detailsUrl ?? this.detailsUrl,
      category: category ?? this.category,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NewsModel &&
        other.id == id &&
        other.title == title &&
        other.date == date &&
        other.image == image &&
        other.content == content &&
        other.summary == summary &&
        other.detailsUrl == detailsUrl &&
        other.category == category;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        date.hashCode ^
        image.hashCode ^
        content.hashCode ^
        summary.hashCode ^
        detailsUrl.hashCode ^
        category.hashCode;
  }

  @override
  String toString() {
    return 'NewsModel(id: $id, title: $title, date: $date, category: $category)';
  }
}
