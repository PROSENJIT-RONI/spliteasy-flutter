class ExpenseSplitModel {
  final String id;
  final String expenseId;
  final String personId;
  final double shareAmount;
  final double? sharePercentage;
  final DateTime createdAt;

  ExpenseSplitModel({
    required this.id,
    required this.expenseId,
    required this.personId,
    required this.shareAmount,
    this.sharePercentage,
    required this.createdAt,
  });

  factory ExpenseSplitModel.fromJson(Map<String, dynamic> json) {
    return ExpenseSplitModel(
      id: json['id'] as String,
      expenseId: json['expense_id'] as String? ?? '',
      personId: json['person_id'] as String? ?? '',
      shareAmount: (json['share_amount'] as num).toDouble(),
      sharePercentage: json['share_percentage'] != null
          ? (json['share_percentage'] as num).toDouble()
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'expense_id': expenseId,
      'person_id': personId,
      'share_amount': shareAmount,
      'share_percentage': sharePercentage,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
