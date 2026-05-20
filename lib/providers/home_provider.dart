import 'package:flutter/material.dart';
import 'package:smart_bachat/database_handler/database_handler.dart';
import 'package:smart_bachat/database_model_class/expense_data_model.dart';
import 'package:smart_bachat/database_model_class/income_data_model.dart';

class HomeProvider with ChangeNotifier {
  final DatabaseHandler _dbHandler = DatabaseHandler();

  int _totalIncome = 0;
  int _totalExpense = 0;
  List<ExpenseDataModel> _recentExpenses = [];
  bool _isLoading = false;

  // Getters
  int get totalIncome => _totalIncome;
  int get totalExpense => _totalExpense;
  List<ExpenseDataModel> get recentExpenses => _recentExpenses;
  bool get isLoading => _isLoading;
  int get balance => _totalIncome - _totalExpense;

  // Fetch all home data (Total Income, Expenses, and Recent Transactions)
  Future<void> fetchHomeData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _totalIncome = await _dbHandler.getTotalIncome();
      _totalExpense = await _dbHandler.getTotalExpense();
      _recentExpenses = await _dbHandler.readLastFiveCurrentMonthExpenses();
    } catch (e) {
      debugPrint("Error fetching home data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add Income
  Future<void> addIncome(IncomeDataModel model) async {
    await _dbHandler.insertIncomeData(model);
    await fetchHomeData(); // Auto refresh totals after insert
  }

  // Update Expense
  Future<void> updateExpense(int id, ExpenseDataModel model) async {
    await _dbHandler.updateExpenseData(id, model);
    await fetchHomeData(); // Auto refresh totals after update
  }

  // Delete Expense
  Future<void> deleteExpense(int id) async {
    await _dbHandler.deleteExpenseData(id);
    await fetchHomeData(); // Auto refresh totals after delete
  }
}
