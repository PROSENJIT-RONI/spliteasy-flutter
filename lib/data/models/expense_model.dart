enum SplitType { equal, unequal, percentage }

class ExpenseModel {
  final String id;
  final String? groupId;
  final String description;
  final double amount;
  final String paidByUserId;
  final SplitType splitType;
  final Map<String, double> splitDetails;
  final String category;
  final String? receiptPath;
  final DateTime createdAt;
  final List<String> participantIds;

  ExpenseModel({
    required this.id,
    this.groupId,
    required this.description,
    required this.amount,
    required this.paidByUserId,
    required this.splitType,
    required this.splitDetails,
    required this.category,
    this.receiptPath,
    required this.createdAt,
    required this.participantIds,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] as String,
      groupId: json['group_id'] as String?,
      description: json['description'] as String? ?? '',
      amount: (json['amount'] as num).toDouble(),
      paidByUserId: (json['paid_by_user_id'] ?? json['paid_by'] ?? '') as String,
      splitType: SplitType.values.firstWhere(
        (e) => e.name == json['split_type'],
        orElse: () => SplitType.equal,
      ),
      splitDetails: Map<String, double>.from(
        (json['split_details'] as Map? ?? {}).map(
          (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
        ),
      ),
      category: json['category'] as String? ?? 'Other',
      receiptPath: (json['receipt_path'] ?? json['receipt_url']) as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      participantIds: List<String>.from(json['participant_ids'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_id': groupId,
      'description': description,
      'amount': amount,
      'paid_by_user_id': paidByUserId,
      'paid_by': paidByUserId,
      'split_type': splitType.name,
      'split_details': splitDetails,
      'category': category,
      'receipt_path': receiptPath,
      'created_at': createdAt.toIso8601String(),
      'participant_ids': participantIds,
    };
  }
}
