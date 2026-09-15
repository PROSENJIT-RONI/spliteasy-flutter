class GroupModel {
  final String id;
  final String name;
  final String icon; // Emoji or icon name
  final String description;
  final String category; // Trip, Home, Couple, Other
  final List<String> memberIds;
  final String createdBy;
  final DateTime createdAt;

  GroupModel({
    required this.id,
    required this.name,
    required this.icon,
    this.description = '',
    required this.category,
    required this.memberIds,
    required this.createdBy,
    required this.createdAt,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String? ?? '📁',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'Other',
      memberIds: List<String>.from(json['member_ids'] ?? []),
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'description': description,
      'category': category,
      'member_ids': memberIds,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
