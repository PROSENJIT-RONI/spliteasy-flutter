import 'package:flutter_test/flutter_test.dart';
import 'package:spliteasy/data/models/trip_person_model.dart';
import 'package:spliteasy/data/models/trip_expense_model.dart';
import 'package:spliteasy/data/models/expense_split_model.dart';
import 'package:spliteasy/data/models/balance_model.dart';
import 'package:spliteasy/data/services/balance_service.dart';

void main() {
  final balanceService = BalanceService();

  group('Simplify Debts & Financial Engine Tests', () {
    final now = DateTime.now();

    final rahul = TripPersonModel(id: 'p_rahul', tripId: 'trip_1', name: 'Rahul', createdAt: now, updatedAt: now);
    final suman = TripPersonModel(id: 'p_suman', tripId: 'trip_1', name: 'Suman', createdAt: now, updatedAt: now);
    final amit = TripPersonModel(id: 'p_amit', tripId: 'trip_1', name: 'Amit', createdAt: now, updatedAt: now);
    final prosenjit = TripPersonModel(id: 'p_prosenjit', tripId: 'trip_1', name: 'Prosenjit', createdAt: now, updatedAt: now);
    final rohit = TripPersonModel(id: 'p_rohit', tripId: 'trip_1', name: 'Rohit', createdAt: now, updatedAt: now);

    final allPeople = [rahul, suman, amit, prosenjit, rohit];

    test('1. One Creditor + Multiple Debtors (Rahul = +₹3,000)', () {
      final people4 = [rahul, suman, amit, prosenjit];
      final expDinner = TripExpenseModel(
        id: 'exp_dinner',
        tripId: 'trip_1',
        description: 'Dinner',
        totalAmount: 4000.0,
        paidByPersonId: rahul.id,
        splitType: SplitType.equal,
        expenseDate: now,
        createdAt: now,
        updatedAt: now,
        splits: [
          ExpenseSplitModel(id: 's1', expenseId: 'exp_dinner', personId: rahul.id, shareAmount: 1000.0, createdAt: now),
          ExpenseSplitModel(id: 's2', expenseId: 'exp_dinner', personId: suman.id, shareAmount: 1000.0, createdAt: now),
          ExpenseSplitModel(id: 's3', expenseId: 'exp_dinner', personId: amit.id, shareAmount: 1000.0, createdAt: now),
          ExpenseSplitModel(id: 's4', expenseId: 'exp_dinner', personId: prosenjit.id, shareAmount: 1000.0, createdAt: now),
        ],
      );

      final balances = balanceService.calculatePersonBalances(people4, [expDinner]);
      final settlements = balanceService.calculateSettlementSuggestions(balances);

      expect(settlements.length, equals(3));
      double totalSettled = settlements.fold(0.0, (acc, s) => acc + s.amount);
      expect(totalSettled, equals(3000.0));

      for (var s in settlements) {
        expect(s.toPerson.id, equals(rahul.id)); // All payments directed to Rahul
      }
    });

    test('2. Multiple Creditors + Multiple Debtors (Complex Case 8)', () {
      final balances = [
        PersonBalanceModel(person: rahul, totalPaid: 4000.0, totalShare: 1666.67, netBalance: 2333.33),
        PersonBalanceModel(person: amit, totalPaid: 2000.0, totalShare: 1666.67, netBalance: 333.33),
        PersonBalanceModel(person: suman, totalPaid: 0.0, totalShare: 1000.0, netBalance: -1000.00),
        PersonBalanceModel(person: prosenjit, totalPaid: 0.0, totalShare: 1666.66, netBalance: -1666.66),
      ];

      final settlements = balanceService.calculateSettlementSuggestions(balances);

      // Verify no circular transactions
      for (var s in settlements) {
        expect(s.fromPerson.id, isNot(equals(s.toPerson.id)));
      }

      // Verify payment sum matches creditor total
      double totalDebtorPayments = settlements.fold(0.0, (acc, s) => acc + s.amount);
      expect(double.parse(totalDebtorPayments.toStringAsFixed(2)), equals(2666.66));

      // Verify remaining balances after settlements are ₹0.00
      Map<String, double> remainingMap = {
        rahul.id: 2333.33,
        amit.id: 333.33,
        suman.id: -1000.00,
        prosenjit.id: -1666.66,
      };

      for (var s in settlements) {
        remainingMap[s.fromPerson.id] = remainingMap[s.fromPerson.id]! + s.amount;
        remainingMap[s.toPerson.id] = remainingMap[s.toPerson.id]! - s.amount;
      }

      for (var entry in remainingMap.entries) {
        expect(entry.value.abs(), lessThan(0.01)); // Settles to 0.00
      }
    });

    test('3. Zero Balances (No-Debt Case)', () {
      final balances = [
        PersonBalanceModel(person: rahul, totalPaid: 100.0, totalShare: 100.0, netBalance: 0.0),
        PersonBalanceModel(person: suman, totalPaid: 100.0, totalShare: 100.0, netBalance: 0.0),
      ];

      final settlements = balanceService.calculateSettlementSuggestions(balances);
      expect(settlements.isEmpty, isTrue); // "All balances are settled"
    });

    test('4. Participant Subset & Floating Point Safety', () {
      final expSubset = TripExpenseModel(
        id: 'exp_sub',
        tripId: 'trip_1',
        description: 'Lunch',
        totalAmount: 1500.0,
        paidByPersonId: rahul.id,
        splitType: SplitType.equal,
        expenseDate: now,
        createdAt: now,
        updatedAt: now,
        splits: [
          ExpenseSplitModel(id: 's1', expenseId: 'exp_sub', personId: rahul.id, shareAmount: 500.0, createdAt: now),
          ExpenseSplitModel(id: 's2', expenseId: 'exp_sub', personId: suman.id, shareAmount: 500.0, createdAt: now),
          ExpenseSplitModel(id: 's3', expenseId: 'exp_sub', personId: amit.id, shareAmount: 500.0, createdAt: now),
        ],
      );

      final balances = balanceService.calculatePersonBalances(allPeople, [expSubset]);

      final rohitBal = balances.firstWhere((b) => b.person.id == rohit.id);
      expect(rohitBal.netBalance, equals(0.0));

      final settlements = balanceService.calculateSettlementSuggestions(balances);
      expect(settlements.length, equals(2));
    });

    test('5. Expense Edit/Delete Recalculation Verification', () {
      final exp1 = TripExpenseModel(
        id: 'exp_1',
        tripId: 'trip_1',
        description: 'Resort',
        totalAmount: 3000.0,
        paidByPersonId: rahul.id,
        splitType: SplitType.equal,
        expenseDate: now,
        createdAt: now,
        updatedAt: now,
        splits: [
          ExpenseSplitModel(id: 's1', expenseId: 'exp_1', personId: rahul.id, shareAmount: 1500.0, createdAt: now),
          ExpenseSplitModel(id: 's2', expenseId: 'exp_1', personId: suman.id, shareAmount: 1500.0, createdAt: now),
        ],
      );

      // Initial state
      var balances = balanceService.calculatePersonBalances([rahul, suman], [exp1]);
      var settlements = balanceService.calculateSettlementSuggestions(balances);
      expect(settlements.first.amount, equals(1500.0));

      // After deleting expense
      balances = balanceService.calculatePersonBalances([rahul, suman], []);
      settlements = balanceService.calculateSettlementSuggestions(balances);
      expect(settlements.isEmpty, isTrue); // Empty list of settlements
    });
  });
}
