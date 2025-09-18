import 'package:equatable/equatable.dart';

class ReportTypeModel extends Equatable {
  final int id;
  final String name;
  final String nameAr;
  final String? description;
  final String priorityLevel;
  final bool isActive;
  final DateTime createdAt;

  const ReportTypeModel({
    required this.id,
    required this.name,
    required this.nameAr,
    this.description,
    required this.priorityLevel,
    required this.isActive,
    required this.createdAt,
  });

  factory ReportTypeModel.fromJson(Map<String, dynamic> json) {
    return ReportTypeModel(
      id: json['id'] as int,
      name: json['name'] as String,
      nameAr: json['name_ar'] as String,
      description: json['description'] as String?,
      priorityLevel: json['priority_level'] as String? ?? 'medium',
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_ar': nameAr,
      'description': description,
      'priority_level': priorityLevel,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    nameAr,
    description,
    priorityLevel,
    isActive,
    createdAt,
  ];

  @override
  String toString() => nameAr; // العرض بالعربية
}
