enum ActivityType { expenseAdded, settlement, groupCreated, memberAdded }

class ActivityModel {
  final String id;
  final ActivityType type;
  final String title;
  final String subtitle;
  final double? amount;
  final String? groupId;
  final String? groupName;
  final DateTime createdAt;
  final String createdByUserName;

  ActivityModel({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    this.amount,
    this.groupId,
    this.groupName,
    required this.createdAt,
    required this.createdByUserName,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    ActivityType type = ActivityType.expenseAdded;
    final typeStr = (json['type'] as String? ?? '').toLowerCase();
    if (typeStr.contains('settle')) {
      type = ActivityType.settlement;
    } else if (typeStr.contains('group')) {
      type = ActivityType.groupCreated;
    }

    return ActivityModel(
      id: json['id'] as String? ?? 'act_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      title: json['title'] as String? ?? 'Activity',
      subtitle: json['subtitle'] as String? ?? '',
      amount: json['amount'] != null ? (json['amount'] as num).toDouble() : null,
      groupId: json['group_id'] as String?,
      groupName: json['group_name'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      createdByUserName: json['created_by_user_name'] as String? ?? 'User',
    );
  }
}
