import 'package:flutter/material.dart';
import 'package:smart_bachat/database_handler/database_handler.dart';
import 'package:smart_bachat/database_model_class/expense_data_model.dart';
import 'package:smart_bachat/database_model_class/income_data_model.dart';

class TransactionProvider with ChangeNotifier {
  final DatabaseHandler _db = DatabaseHandler();
  
  List<ExpenseDataModel> _expenses = [];
  List<IncomeDataModel> _incomes = [];
  
  bool _isLoadingExpenses = false;
  bool _isLoadingIncomes = false;

  List<ExpenseDataModel> get expenses => _expenses;
  List<IncomeDataModel> get incomes => _incomes;
  
  bool get isLoadingExpenses => _isLoadingExpenses;
  bool get isLoadingIncomes => _isLoadingIncomes;

  // FETCH ALL EXPENSES
  Future<void> fetchAllExpenses() async {
    _isLoadingExpenses = true;
    notifyListeners();
    try {
      _expenses = await _db.readExpenseData();
    } catch (e) {
      debugPrint("Error fetching expenses: $e");
    } finally {
      _isLoadingExpenses = false;
      notifyListeners();
    }
  }

  // ADD EXPENSE
  Future<void> addExpense(ExpenseDataModel expense) async {
    try {
      await _db.insertExpenseData(expense);
      await fetchAllExpenses();
    } catch (e) {
      debugPrint("Error adding expense: $e");
      rethrow;
    }
  }

  // UPDATE EXPENSE
  Future<void> updateExpense(int id, ExpenseDataModel expense) async {
    try {
      await _db.updateExpenseData(id, expense);
      await fetchAllExpenses();
    } catch (e) {
      debugPrint("Error updating expense: $e");
      rethrow;
    }
  }

  // DELETE EXPENSE
  Future<void> deleteExpense(int id) async {
    try {
      await _db.deleteExpenseData(id);
      await fetchAllExpenses();
    } catch (e) {
      debugPrint("Error deleting expense: $e");
      rethrow;
    }
  }

  // FETCH ALL INCOMES
  Future<void> fetchAllIncomes() async {
    _isLoadingIncomes = true;
    notifyListeners();
    try {
      _incomes = await _db.readIncomeData();
    } catch (e) {
      debugPrint("Error fetching incomes: $e");
    } finally {
      _isLoadingIncomes = false;
      notifyListeners();
    }
  }

  // ADD INCOME
  Future<void> addIncome(IncomeDataModel income) async {
    try {
      await _db.insertIncomeData(income);
      await fetchAllIncomes();
    } catch (e) {
      debugPrint("Error adding income: $e");
      rethrow;
    }
  }

  // UPDATE INCOME
  Future<void> updateIncome(int id, IncomeDataModel income) async {
    try {
      await _db.updateIncomeData(id, income);
      await fetchAllIncomes();
    } catch (e) {
      debugPrint("Error updating income: $e");
      rethrow;
    }
  }

  // DELETE INCOME
  Future<void> deleteIncome(int id) async {
    try {
      await _db.deleteIncomeData(id);
      await fetchAllIncomes();
    } catch (e) {
      debugPrint("Error deleting income: $e");
      rethrow;
    }
  }
}
