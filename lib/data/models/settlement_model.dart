class SettlementModel {
  final String id;
  final String? groupId;
  final String payerId;
  final String payeeId;
  final double amount;
  final String? note;
  final DateTime createdAt;

  SettlementModel({
    required this.id,
    this.groupId,
    required this.payerId,
    required this.payeeId,
    required this.amount,
    this.note,
    required this.createdAt,
  });

  factory SettlementModel.fromJson(Map<String, dynamic> json) {
    return SettlementModel(
      id: json['id'] as String,
      groupId: json['group_id'] as String?,
      payerId: json['payer_id'] as String,
      payeeId: json['payee_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_id': groupId,
      'payer_id': payerId,
      'payee_id': payeeId,
      'amount': amount,
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
