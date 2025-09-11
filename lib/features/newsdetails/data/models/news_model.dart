class NewsModel {
  final String id;
  final String title;
  final String date;
  final String image;
  final String content;
  final String category;
  NewsModel({
    required this.id,
    required this.title,
    required this.date,
    required this.image,
    required this.content,
    this.category = '',
  });

  factory NewsModel.fromJson(
      Map<String, dynamic> json) {
    return NewsModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      date: json['date'] ?? '',
      image: json['image'] ?? '',
      content: json['content'] ?? '',
      category: json['category'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date,
      'image': image,
      'content': content,
      'category': category,
    };
  }

  NewsModel copyWith({
    String? id,
    String? title,
    String? date,
    String? image,
    String? content,
    String? category,
  }) {
    return NewsModel(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      image: image ?? this.image,
      content: content ?? this.content,
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
        other.category == category;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        date.hashCode ^
        image.hashCode ^
        content.hashCode ^
        category.hashCode;
  }

  @override
  String toString() {
    return 'NewsModel(id: $id, title: $title, date: $date, category: $category)';
  }
}
