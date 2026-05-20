import 'package:flutter/material.dart';
import 'package:smart_bachat/database_handler/database_handler.dart';
import 'package:smart_bachat/database_model_class/category_expense_as_chart.dart';

class MonthData {
  final int month;
  final int year;
  final int income;
  final int expense;
  final List<CategoryExpense> categories;

  MonthData({
    required this.month,
    required this.year,
    required this.income,
    required this.expense,
    required this.categories,
  });
}

class YearData {
  final int year;
  final int totalIncome;
  final int totalExpense;
  final List<MonthData> months;
  final List<CategoryExpense> categories;

  YearData({
    required this.year,
    required this.totalIncome,
    required this.totalExpense,
    required this.months,
    required this.categories,
  });
}

class ReportsProvider with ChangeNotifier {
  final DatabaseHandler _db = DatabaseHandler();

  bool _isLoading = false;
  String? _errorMessage;

  List<CategoryExpense> _allTimeCategories = [];
  List<MonthData> _currentYearMonths = [];
  List<int> _availableYears = [];
  Map<int, YearData> _historyData = {};

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<CategoryExpense> get allTimeCategories => _allTimeCategories;
  List<MonthData> get currentYearMonths => _currentYearMonths;
  List<int> get availableYears => _availableYears;
  Map<int, YearData> get historyData => _historyData;

  int _currentYear = DateTime.now().year;
  int _currentMonth = DateTime.now().month;

  int get currentYear => _currentYear;
  int get currentMonth => _currentMonth;

  Future<void> loadData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Load current month's category summary
      final summary = await _db.getCategoryExpensesForMonth(_currentMonth, _currentYear);
      _allTimeCategories = summary
          .map(
            (c) => CategoryExpense(
              (c['name'] ?? 'Unknown').toString(),
              (c['totalExpense'] as num?)?.toDouble() ?? 0.0,
            ),
          )
          .toList();

      // 2. Load current year's month-wise breakdown
      List<MonthData> currentMonths = [];
      for (int m = 1; m <= _currentMonth; m++) {
        final inc = await _db.getMonthlyIncomeForMonth(m, _currentYear);
        final exp = await _db.getSummarizedExpensesForMonthAndYear(m, _currentYear);
        final cats = await _db.getCategoryExpensesForMonth(m, _currentYear);

        currentMonths.add(
          MonthData(
            month: m,
            year: _currentYear,
            income: inc,
            expense: exp,
            categories: cats
                .map(
                  (c) => CategoryExpense(
                    (c['name'] ?? 'Unknown').toString(),
                    (c['totalExpense'] as num?)?.toDouble() ?? 0.0,
                  ),
                )
                .toList(),
          ),
        );
      }
      _currentYearMonths = currentMonths;

      // 3. Load previous years data
      final years = await _db.getYearsWithData();
      _availableYears = years..sort((a, b) => b.compareTo(a));

      _historyData.clear();
      for (int year in _availableYears) {
        if (year == _currentYear && currentMonths.isNotEmpty) continue;

        final yInc = await _db.getYearlyIncome(year);
        final yExp = await _db.getYearlyExpense(year);
        final yCats = await _db.getSummarizedExpensesForYear(year);

        List<MonthData> yMonths = [];
        for (int m = 1; m <= 12; m++) {
          final mInc = await _db.getMonthlyIncomeForMonth(m, year);
          final mExp = await _db.getSummarizedExpensesForMonthAndYear(m, year);
          if (mInc > 0 || mExp > 0) {
            final mCats = await _db.getCategoryExpensesForMonth(m, year);
            yMonths.add(
              MonthData(
                month: m,
                year: year,
                income: mInc,
                expense: mExp,
                categories: mCats
                    .map(
                      (c) => CategoryExpense(
                        (c['name'] ?? 'Unknown').toString(),
                        (c['totalExpense'] as num?)?.toDouble() ?? 0.0,
                      ),
                    )
                    .toList(),
              ),
            );
          }
        }

        _historyData[year] = YearData(
          year: year,
          totalIncome: yInc,
          totalExpense: yExp,
          months: yMonths,
          categories: yCats
              .map(
                (c) => CategoryExpense(
                  (c['name'] ?? 'Unknown').toString(),
                  (c['totalExpense'] as num?)?.toDouble() ?? 0.0,
                ),
              )
              .toList(),
        );
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint("Error loading statistics: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
