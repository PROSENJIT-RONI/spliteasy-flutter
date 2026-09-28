import 'dart:math';
import 'package:get/get.dart';
import '../models/trip_person_model.dart';
import '../models/trip_expense_model.dart';
import '../models/balance_model.dart';

class _Party {
  final TripPersonModel person;
  double amount;
  _Party(this.person, this.amount);
}

class BalanceService extends GetxService {
  List<PersonBalanceModel> calculatePersonBalances(
    List<TripPersonModel> people,
    List<TripExpenseModel> expenses,
  ) {
    Map<String, double> paidMap = {for (var p in people) p.id: 0.0};
    Map<String, double> shareMap = {for (var p in people) p.id: 0.0};

    for (var exp in expenses) {
      if (paidMap.containsKey(exp.paidByPersonId)) {
        paidMap[exp.paidByPersonId] =
            paidMap[exp.paidByPersonId]! + exp.totalAmount;
      }

      for (var split in exp.splits) {
        if (shareMap.containsKey(split.personId)) {
          shareMap[split.personId] =
              shareMap[split.personId]! + split.shareAmount;
        }
      }
    }

    List<PersonBalanceModel> result = [];
    for (var p in people) {
      final totalPaid = double.parse((paidMap[p.id] ?? 0.0).toStringAsFixed(2));
      final totalShare =
          double.parse((shareMap[p.id] ?? 0.0).toStringAsFixed(2));
      final netBalance =
          double.parse((totalPaid - totalShare).toStringAsFixed(2));

      result.add(PersonBalanceModel(
        person: p,
        totalPaid: totalPaid,
        totalShare: totalShare,
        netBalance: netBalance,
      ));
    }

    return result;
  }

  List<SettlementSuggestionModel> calculateSettlementSuggestions(
    List<PersonBalanceModel> balances,
  ) {
    List<_Party> debtors = [];
    List<_Party> creditors = [];

    for (var b in balances) {
      if (b.netBalance < -0.009) {
        debtors.add(_Party(b.person, b.netBalance.abs()));
      } else if (b.netBalance > 0.009) {
        creditors.add(_Party(b.person, b.netBalance));
      }
    }

    debtors.sort((a, b) => b.amount.compareTo(a.amount));
    creditors.sort((a, b) => b.amount.compareTo(a.amount));

    List<SettlementSuggestionModel> suggestions = [];

    int dIndex = 0;
    int cIndex = 0;

    while (dIndex < debtors.length && cIndex < creditors.length) {
      final debtor = debtors[dIndex];
      final creditor = creditors[cIndex];

      final settleAmount = min(debtor.amount, creditor.amount);
      final roundedAmount = double.parse(settleAmount.toStringAsFixed(2));

      if (roundedAmount > 0) {
        suggestions.add(SettlementSuggestionModel(
          fromPerson: debtor.person,
          toPerson: creditor.person,
          amount: roundedAmount,
        ));
      }

      debtor.amount = double.parse((debtor.amount - roundedAmount).toStringAsFixed(2));
      creditor.amount = double.parse((creditor.amount - roundedAmount).toStringAsFixed(2));

      if (debtor.amount <= 0.009) {
        dIndex++;
      }
      if (creditor.amount <= 0.009) {
        cIndex++;
      }
    }

    return suggestions;
  }
}
