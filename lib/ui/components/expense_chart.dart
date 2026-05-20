import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../database_handler/database_handler.dart';
import '../../database_model_class/category_expense_as_chart.dart';


class ExpenseChart extends StatefulWidget {
  @override
  _ExpenseChartState createState() => _ExpenseChartState();
}

class _ExpenseChartState extends State<ExpenseChart> {
  List<CategoryExpense> expenses = [];
  bool isLoading = true;
  DatabaseHandler _dbHandler = DatabaseHandler();

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  // Fetch summarized expenses and update state
  Future<void> _loadExpenses() async {
    final result = await _dbHandler.getSummarizedExpenses();
    setState(() {
      expenses = result
          .map((item) => CategoryExpense(
          item['name'],
          (item['totalExpense'] as num).toDouble() // Cast to double
      ))
          .toList();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Expense Summary"),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : expenses.isEmpty
          ? Center(child: Text('No data available'))
          : SfCartesianChart(
        primaryXAxis: CategoryAxis(
          title: AxisTitle(text: 'Categories'),
        ),
        //primaryYAxis: NumericAxis(title: AxisTitle(text: 'Expenses')),
        tooltipBehavior: TooltipBehavior(enable: true),
        series: [
          ColumnSeries<CategoryExpense, String>(
            dataSource: expenses,
            xValueMapper: (data, _) => data.name,
            yValueMapper: (data, _) => data.totalExpense,
            color: Colors.blue,
            dataLabelSettings: DataLabelSettings(isVisible: true),
          )
        ],
      ),
    );
  }
}