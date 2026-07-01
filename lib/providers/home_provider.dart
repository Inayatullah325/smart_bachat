import 'package:flutter/material.dart';
import 'package:smart_bachat/database_handler/database_handler.dart';
import 'package:smart_bachat/database_model_class/expense_data_model.dart';
import 'package:smart_bachat/database_model_class/income_data_model.dart';

class HomeProvider with ChangeNotifier {
  final DatabaseHandler _dbHandler = DatabaseHandler();

  int _totalIncome = 0;
  int _totalExpense = 0;
  int _currentMonthIncome = 0;
  int _currentMonthExpense = 0;
  int _currentYearIncome = 0;
  int _currentYearExpense = 0;
  List<ExpenseDataModel> _recentExpenses = [];
  bool _isLoading = false;

  // Getters
  int get totalIncome => _totalIncome;
  int get totalExpense => _totalExpense;
  int get currentMonthIncome => _currentMonthIncome;
  int get currentMonthExpense => _currentMonthExpense;
  int get currentYearIncome => _currentYearIncome;
  int get currentYearExpense => _currentYearExpense;
  List<ExpenseDataModel> get recentExpenses => _recentExpenses;
  bool get isLoading => _isLoading;
  int get balance => _totalIncome - _totalExpense;
  int get currentYearBalance => _currentYearIncome - _currentYearExpense;
  int get currentMonthBalance => _currentMonthIncome - _currentMonthExpense;

  // True only if current month has any income or expense
  bool get hasCurrentMonthData =>
      _currentMonthIncome > 0 || _currentMonthExpense > 0;

  bool get usesCurrentMonthForAnalytics => _currentMonthIncome > 0;

  double get _incomeBaseForRatio {
    if (_currentMonthIncome > 0) return _currentMonthIncome.toDouble();
    return _totalIncome.toDouble();
  }

  double get savingsRatio {
    final base = _incomeBaseForRatio;
    if (base == 0) return 0;
    return currentMonthBalance / base;
  }

  double get spendingRatio {
    final base = _incomeBaseForRatio;
    if (base == 0) return 0;
    return _currentMonthExpense / base;
  }

  // Fetch all home data (Total Income, Expenses, and Recent Transactions)
  Future<void> fetchHomeData() async {
    _isLoading = true;
    notifyListeners();

    final now = DateTime.now();
    final month = now.month;
    final year = now.year;

    try {
      _totalIncome = await _dbHandler.getTotalIncome();
      _totalExpense = await _dbHandler.getTotalExpense();
      _recentExpenses = await _dbHandler.readLastFiveCurrentMonthExpenses();

      // Current year specific data
      _currentYearIncome = await _dbHandler.getYearlyIncome(year);
      _currentYearExpense = await _dbHandler.getYearlyExpense(year);

      // Current month specific data for the summary card
      _currentMonthIncome = await _dbHandler.getMonthlyIncomeForMonth(
        month,
        year,
      );
      _currentMonthExpense = await _dbHandler
          .getSummarizedExpensesForMonthAndYear(month, year);
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
