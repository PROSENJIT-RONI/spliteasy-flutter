import 'trip_person_model.dart';

class PersonBalanceModel {
  final TripPersonModel person;
  final double totalPaid;
  final double totalShare;
  final double netBalance; // totalPaid - totalShare

  PersonBalanceModel({
    required this.person,
    required this.totalPaid,
    required this.totalShare,
    required this.netBalance,
  });
}

class SettlementSuggestionModel {
  final TripPersonModel fromPerson; // Debtor (owes money)
  final TripPersonModel toPerson;   // Creditor (should receive money)
  final double amount;

  SettlementSuggestionModel({
    required this.fromPerson,
    required this.toPerson,
    required this.amount,
  });
}
