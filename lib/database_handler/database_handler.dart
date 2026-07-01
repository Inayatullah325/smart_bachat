import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../database_model_class/expense_data_model.dart';
import '../database_model_class/income_data_model.dart';

class DatabaseHandler {
  Database? _database;

  Future<Database?> get dataBase async {
    if (_database != null) {
      return _database;
    }

    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(
      directory.path,
      'smartBachat_v2.db',
    ); // Changed DB name for fresh schema
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute(''' CREATE TABLE IncomeTable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_email TEXT,
        date TEXT,
        income INTEGER)
      ''');

        db.execute(''' CREATE TABLE ExpenseTable(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_email TEXT,
          name TEXT,
          date TEXT,
          expense INTEGER)
          ''');
      },
    );

    return _database;
  }

  Future<String> _getUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('loggedInUID') ?? 'default';
  }

  insertExpenseData(ExpenseDataModel expenseDataModel) async {
    Database? db = await dataBase;
    String email = await _getUserEmail();
    Map<String, dynamic> map = expenseDataModel.toMap();
    map['user_email'] = email;
    db!.insert('ExpenseTable', map);
  }

  Future<List<ExpenseDataModel>> readExpenseData() async {
    Database? db = await dataBase;
    String email = await _getUserEmail();
    final expenseDataList = await db!.query(
      'ExpenseTable',
      where: 'user_email = ?',
      whereArgs: [email],
      orderBy: 'id DESC',
    );
    return expenseDataList
        .map((item) => ExpenseDataModel.fromMap(item))
        .toList();
  }

  deleteExpenseData(int id) async {
    Database? db = await dataBase;
    if (db == null) return;
    String email = await _getUserEmail();
    await db.delete(
      'ExpenseTable',
      where: 'id = ? AND user_email = ?',
      whereArgs: [id, email],
    );
  }

  updateExpenseData(int id, ExpenseDataModel expenseDataModel) async {
    Database? db = await dataBase;
    if (db == null) return;
    String email = await _getUserEmail();
    await db.update(
      'ExpenseTable',
      expenseDataModel.toMap(),
      where: 'id = ? AND user_email = ?',
      whereArgs: [id, email],
    );
  }

  // income table methods
  insertIncomeData(IncomeDataModel incomeDataModel) async {
    Database? db = await dataBase;
    String email = await _getUserEmail();
    Map<String, dynamic> map = incomeDataModel.toMap();
    map['user_email'] = email;
    db!.insert('IncomeTable', map);
  }

  Future<List<IncomeDataModel>> readIncomeData() async {
    Database? db = await dataBase;
    String email = await _getUserEmail();
    final incomeDataList = await db!.query(
      'IncomeTable',
      where: 'user_email = ?',
      whereArgs: [email],
      orderBy: 'id DESC',
    );
    return incomeDataList.map((item) => IncomeDataModel.fromMap(item)).toList();
  }

  deleteIncomeData(int id) async {
    Database? db = await dataBase;
    if (db == null) return;
    String email = await _getUserEmail();
    await db.delete(
      'IncomeTable',
      where: 'id = ? AND user_email = ?',
      whereArgs: [id, email],
    );
  }

  updateIncomeData(int id, IncomeDataModel incomeDataModel1) async {
    Database? db = await dataBase;
    if (db == null) return;
    String email = await _getUserEmail();
    await db.update(
      'IncomeTable',
      incomeDataModel1.toMap(),
      where: 'id = ? AND user_email = ?',
      whereArgs: [id, email],
    );
  }

  // get last five transactions of the CURRENT MONTH ONLY
  Future<List<ExpenseDataModel>> readLastFiveCurrentMonthExpenses() async {
    final db = await dataBase;
    if (db == null) throw Exception('Database is not initialized');
    String email = await _getUserEmail();

    final now = DateTime.now();
    final monthStr = now.month.toString().padLeft(2, '0');
    final yearStr = now.year.toString();

    final List<Map<String, dynamic>> maps = await db.query(
      'ExpenseTable',
      where:
          'substr(date, 4, 2) = ? AND substr(date, 7, 4) = ? AND user_email = ?',
      whereArgs: [monthStr, yearStr, email],
      orderBy: 'id DESC',
    );

    return List.generate(maps.length, (i) {
      return ExpenseDataModel(
        id: maps[i]['id'] as int?,
        name: maps[i]['name'] as String,
        date: maps[i]['date'] as String,
        expense: maps[i]['expense'] as int,
      );
    });
  }

  // Get total expense for home screen
  Future<int> getSummarizedExpensesForMonthAndYear(int month, int year) async {
    Database? db = await dataBase;
    if (db == null) return 0;
    String email = await _getUserEmail();

    try {
      final result = await db.rawQuery(
        '''
      SELECT SUM(expense) as totalExpense 
      FROM ExpenseTable 
      WHERE substr(date, 4, 2) = ? 
      AND substr(date, 7, 4) = ?
      AND user_email = ?
    ''',
        [month.toString().padLeft(2, '0'), year.toString(), email],
      );

      if (result.isEmpty || result[0]['totalExpense'] == null) return 0;
      return (result[0]['totalExpense'] as num).toInt();
    } catch (e) {
      return 0;
    }
  }

  // Get total income (All time)
  Future<int> getTotalIncome() async {
    Database? db = await dataBase;
    if (db == null) return 0;
    String email = await _getUserEmail();
    try {
      final result = await db.rawQuery(
        'SELECT SUM(income) as total FROM IncomeTable WHERE user_email = ?',
        [email],
      );
      return (result[0]['total'] as num?)?.toInt() ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // Get total expense (All time)
  Future<int> getTotalExpense() async {
    Database? db = await dataBase;
    if (db == null) return 0;
    String email = await _getUserEmail();
    try {
      final result = await db.rawQuery(
        'SELECT SUM(expense) as total FROM ExpenseTable WHERE user_email = ?',
        [email],
      );
      return (result[0]['total'] as num?)?.toInt() ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // Get yearly income for a specific year
  Future<int> getYearlyIncome(int year) async {
    Database? db = await dataBase;
    if (db == null) return 0;
    String email = await _getUserEmail();
    try {
      final result = await db.rawQuery(
        '''
      SELECT SUM(income) as total 
      FROM IncomeTable 
      WHERE substr(date, 7, 4) = ? AND user_email = ?
    ''',
        [year.toString(), email],
      );
      return (result[0]['total'] as num?)?.toInt() ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // Get yearly expense for a specific year
  Future<int> getYearlyExpense(int year) async {
    Database? db = await dataBase;
    if (db == null) return 0;
    String email = await _getUserEmail();
    try {
      final result = await db.rawQuery(
        '''
      SELECT SUM(expense) as total 
      FROM ExpenseTable 
      WHERE substr(date, 7, 4) = ? AND user_email = ?
    ''',
        [year.toString(), email],
      );
      return (result[0]['total'] as num?)?.toInt() ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // Get summarized expenses for a specific year grouped by category
  Future<List<Map<String, dynamic>>> getSummarizedExpensesForYear(
    int year,
  ) async {
    Database? db = await dataBase;
    if (db == null) return [];
    String email = await _getUserEmail();
    try {
      final result = await db.rawQuery(
        '''
      SELECT TRIM(name) as name, SUM(expense) as totalExpense 
      FROM ExpenseTable 
      WHERE substr(date, 7, 4) = ? AND user_email = ?
      GROUP BY TRIM(name)
    ''',
        [year.toString(), email],
      );
      return result;
    } catch (e) {
      return [];
    }
  }

  // Get category-wise expenses for a specific month and year
  Future<List<Map<String, dynamic>>> getCategoryExpensesForMonth(
    int month,
    int year,
  ) async {
    Database? db = await dataBase;
    if (db == null) return [];
    String email = await _getUserEmail();
    try {
      final result = await db.rawQuery(
        '''
      SELECT TRIM(name) as name, SUM(expense) as totalExpense 
      FROM ExpenseTable 
      WHERE substr(date, 4, 2) = ? AND substr(date, 7, 4) = ? AND user_email = ?
      GROUP BY TRIM(name)
    ''',
        [month.toString().padLeft(2, '0'), year.toString(), email],
      );
      return result;
    } catch (e) {
      return [];
    }
  }

  // Get all distinct years that have data in expense or income tables
  Future<List<int>> getYearsWithData() async {
    Database? db = await dataBase;
    if (db == null) return [];
    String email = await _getUserEmail();
    try {
      final result = await db.rawQuery(
        '''
      SELECT DISTINCT substr(date, 7, 4) as year FROM ExpenseTable WHERE user_email = ?
      UNION
      SELECT DISTINCT substr(date, 7, 4) as year FROM IncomeTable WHERE user_email = ?
      ORDER BY year DESC
    ''',
        [email, email],
      );
      return result
          .map((r) => int.tryParse(r['year']?.toString() ?? '') ?? 0)
          .where((y) => y > 0)
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Get income for a specific month and year
  Future<int> getMonthlyIncomeForMonth(int month, int year) async {
    Database? db = await dataBase;
    if (db == null) return 0;
    String email = await _getUserEmail();
    try {
      final result = await db.rawQuery(
        '''
      SELECT SUM(income) as total 
      FROM IncomeTable 
      WHERE substr(date, 4, 2) = ? AND substr(date, 7, 4) = ? AND user_email = ?
    ''',
        [month.toString().padLeft(2, '0'), year.toString(), email],
      );
      return (result[0]['total'] as num?)?.toInt() ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // Update user email for all associated expenses and income
  Future<void> updateUserEmailInDatabase(
    String oldEmail,
    String newEmail,
  ) async {
    Database? db = await dataBase;
    if (db == null) return;
    await db.update(
      'IncomeTable',
      {'user_email': newEmail},
      where: 'user_email = ?',
      whereArgs: [oldEmail],
    );
    await db.update(
      'ExpenseTable',
      {'user_email': newEmail},
      where: 'user_email = ?',
      whereArgs: [oldEmail],
    );
  }
}
