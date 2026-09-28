import 'expense_split_model.dart';

enum SplitType { equal, unequal, percentage }

class TripExpenseModel {
  final String id;
  final String tripId;
  final String description;
  final double totalAmount;
  final String paidByPersonId;
  final String category;
  final SplitType splitType;
  final DateTime expenseDate;
  final String note;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ExpenseSplitModel> splits;

  TripExpenseModel({
    required this.id,
    required this.tripId,
    required this.description,
    required this.totalAmount,
    required this.paidByPersonId,
    this.category = 'Food',
    required this.splitType,
    required this.expenseDate,
    this.note = '',
    required this.createdAt,
    required this.updatedAt,
    this.splits = const [],
  });

  factory TripExpenseModel.fromJson(Map<String, dynamic> json) {
    List<ExpenseSplitModel> parsedSplits = [];
    if (json['expense_splits'] != null && json['expense_splits'] is List) {
      parsedSplits = (json['expense_splits'] as List)
          .map((s) => ExpenseSplitModel.fromJson(s as Map<String, dynamic>))
          .toList();
    }

    return TripExpenseModel(
      id: json['id'] as String,
      tripId: json['trip_id'] as String? ?? '',
      description: json['description'] as String? ?? '',
      totalAmount: (json['total_amount'] as num).toDouble(),
      paidByPersonId: json['paid_by_person_id'] as String? ?? '',
      category: json['category'] as String? ?? 'Food',
      splitType: SplitType.values.firstWhere(
        (e) => e.name == json['split_type'],
        orElse: () => SplitType.equal,
      ),
      expenseDate: json['expense_date'] != null
          ? DateTime.parse(json['expense_date'] as String)
          : DateTime.now(),
      note: json['note'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      splits: parsedSplits,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trip_id': tripId,
      'description': description,
      'total_amount': totalAmount,
      'paid_by_person_id': paidByPersonId,
      'category': category,
      'split_type': splitType.name,
      'expense_date': expenseDate.toIso8601String(),
      'note': note,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  TripExpenseModel copyWith({
    String? id,
    String? tripId,
    String? description,
    double? totalAmount,
    String? paidByPersonId,
    String? category,
    SplitType? splitType,
    DateTime? expenseDate,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<ExpenseSplitModel>? splits,
  }) {
    return TripExpenseModel(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      description: description ?? this.description,
      totalAmount: totalAmount ?? this.totalAmount,
      paidByPersonId: paidByPersonId ?? this.paidByPersonId,
      category: category ?? this.category,
      splitType: splitType ?? this.splitType,
      expenseDate: expenseDate ?? this.expenseDate,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      splits: splits ?? this.splits,
    );
  }
}
