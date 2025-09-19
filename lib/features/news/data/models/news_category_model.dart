class NewsCategoryModel {
  final int id;
  final String name;
  final String nameAr;
  final String? description;
  final String? iconUrl;
  final String? color;
  final bool isActive;
  final DateTime? createdAt;

  NewsCategoryModel({
    required this.id,
    required this.name,
    required this.nameAr,
    this.description,
    this.iconUrl,
    this.color,
    this.isActive = true,
    this.createdAt,
  });

  factory NewsCategoryModel.fromJson(Map<String, dynamic> json) {
    return NewsCategoryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      nameAr: json['name_ar'] ?? '',
      description: json['description'],
      iconUrl: json['icon'],
      color: json['color'],
      isActive: json['is_active'] ?? true,
      createdAt:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_ar': nameAr,
      'description': description,
      'icon': iconUrl,
      'color': color,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  NewsCategoryModel copyWith({
    int? id,
    String? name,
    String? nameAr,
    String? description,
    String? iconUrl,
    String? color,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return NewsCategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      description: description ?? this.description,
      iconUrl: iconUrl ?? this.iconUrl,
      color: color ?? this.color,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NewsCategoryModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'NewsCategoryModel(id: $id, name: $name, nameAr: $nameAr)';
  }
}
