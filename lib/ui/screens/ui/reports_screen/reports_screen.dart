import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:smart_bachat/core/app_utils.dart';
import 'package:smart_bachat/core/constant_colors.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:smart_bachat/database_model_class/category_expense_as_chart.dart';
import 'package:smart_bachat/providers/reports_provider.dart';
import 'package:smart_bachat/ui/screens/ui/reports_screen/widgets/reports_widgets.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  Color _getColorForCategory(String name, int index) {
    return AppColors.getCategoryColor(name);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReportsProvider>(context, listen: false).loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final reportsProvider = Provider.of<ReportsProvider>(context);

    if (reportsProvider.errorMessage != null) {
      return Scaffold(
        appBar: _appBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Error: ${reportsProvider.errorMessage}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.sp, color: Colors.red),
              ),
              SizedBox(height: 2.h),
              ElevatedButton(
                onPressed: () {
                  reportsProvider.loadData();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          automaticallyImplyLeading: false,
          title: Text(
            'Statistics',
            style: TextStyle(
              fontSize: 19.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(icon: Icon(Icons.bar_chart), text: 'Figure'),
              Tab(icon: Icon(Icons.pie_chart), text: 'Chart'),
              Tab(icon: Icon(Icons.calendar_month), text: 'Monthly'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildFigureTab(reportsProvider),
            _buildChartTab(reportsProvider),
            _buildMonthlyTab(reportsProvider),
          ],
        ),
      ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      backgroundColor: AppColors.primaryColor,
      automaticallyImplyLeading: false,
      title: Text(
        'Statistics',
        style: TextStyle(
          fontSize: 19.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildFigureTab(ReportsProvider provider) {
    final categories = provider.allTimeCategories;
    if (categories.isEmpty) {
      return _emptyState('No expense data found.');
    }
    return ListView.builder(
      padding: EdgeInsets.all(3.w),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        return Card(
          margin: EdgeInsets.only(bottom: 1.h),
          elevation: 2,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getColorForCategory(cat.name, index),
              child: Text(
                '${index + 1}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              cat.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15.sp,
                color: _getColorForCategory(cat.name, index),
              ),
            ),
            trailing: Text(
              'Rs ${cat.totalExpense.toInt()}',
              style: TextStyle(
                color: AppColors.color_red,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildChartTab(ReportsProvider provider) {
    final categories = provider.allTimeCategories;
    if (categories.isEmpty) return _emptyState('No data for charts.');
    return SingleChildScrollView(
      padding: EdgeInsets.all(3.w),
      child: Column(
        children: [
          _sectionTitle(
            'Expenses Distribution (${AppUtils.monthNames[provider.currentMonth]})',
          ),
          SizedBox(height: 1.h),
          _pieChart(categories),
          SizedBox(height: 3.h),
          _sectionTitle(
            'Comparison by Category (${AppUtils.monthNames[provider.currentMonth]})',
          ),
          SizedBox(height: 1.h),
          _barChart(categories),
        ],
      ),
    );
  }

  Widget _buildMonthlyTab(ReportsProvider provider) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(3.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Current Year (${provider.currentYear})'),
          Padding(
            padding: EdgeInsets.only(top: 0.5.h, bottom: 1.h),
            child: Text(
              'Here is the breakdown of your income, expenses and total savings for each month of the current year.',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Yearly Totals for Current Year
          () {
            int totalYearIn = provider.currentYearMonths.fold(
              0,
              (sum, m) => sum + m.income,
            );
            int totalYearOut = provider.currentYearMonths.fold(
              0,
              (sum, m) => sum + m.expense,
            );
            int totalYearSaving = totalYearIn - totalYearOut;

            return Container(
              margin: EdgeInsets.only(bottom: 2.h),
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.primaryColor.withOpacity(0.2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _summaryItem('Total In', totalYearIn, AppColors.color_green),
                  _summaryItem('Total Out', totalYearOut, AppColors.color_red),
                  _summaryItem(
                    'Saving',
                    totalYearSaving,
                    totalYearSaving >= 0 ? Colors.blue : Colors.orange,
                  ),
                ],
              ),
            );
          }(),
          ...provider.currentYearMonths.reversed
              .where((m) => m.income > 0 || m.expense > 0)
              .map(
                (m) => MonthExpandableCard(
                  data: m,
                  monthNames: AppUtils.monthNames,
                  colorMapper: _getColorForCategory,
                ),
              ),

          if (provider.currentYearMonths.every(
            (m) => m.income == 0 && m.expense == 0,
          ))
            _emptyState(
              'No transactions recorded for ${provider.currentYear} yet.',
            ),

          if (provider.historyData.isNotEmpty) ...[
            SizedBox(height: 3.h),
            _sectionTitle('Previous Years History'),
            SizedBox(height: 1.h),
            ...provider.availableYears
                .where((y) => y < provider.currentYear)
                .map(
                  (y) => YearExpandableSection(
                    yearData: provider.historyData[y]!,
                    monthNames: AppUtils.monthNames,
                    colorMapper: _getColorForCategory,
                  ),
                ),
          ],
        ],
      ),
    );
  }

  Widget _pieChart(List<CategoryExpense> data) {
    return Container(
      height: 32.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: SfCircularChart(
        legend: const Legend(
          isVisible: true,
          position: LegendPosition.bottom,
          overflowMode: LegendItemOverflowMode.wrap,
        ),
        series: <CircularSeries>[
          PieSeries<CategoryExpense, String>(
            dataSource: data,
            xValueMapper: (cat, _) => cat.name,
            yValueMapper: (cat, _) => cat.totalExpense,
            pointColorMapper: (cat, index) =>
                _getColorForCategory(cat.name, index),
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              labelPosition: ChartDataLabelPosition.outside,
            ),
            enableTooltip: true,
          ),
        ],
      ),
    );
  }

  Widget _barChart(List<CategoryExpense> data) {
    return Container(
      height: 35.h,
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: SfCartesianChart(
        primaryXAxis: CategoryAxis(
          interval: 1,
          labelIntersectAction: AxisLabelIntersectAction.rotate45,
          labelStyle: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          arrangeByIndex: true,
        ),
        tooltipBehavior: TooltipBehavior(enable: true),
        series: <CartesianSeries>[
          ColumnSeries<CategoryExpense, String>(
            dataSource: data,
            xValueMapper: (cat, _) => cat.name,
            yValueMapper: (cat, _) => cat.totalExpense,
            pointColorMapper: (cat, index) =>
                _getColorForCategory(cat.name, index),
            dataLabelSettings: DataLabelSettings(
              isVisible: true,
              textStyle: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          'Rs $value',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _emptyState(String msg) {
    return Center(
      child: Text(
        msg,
        style: TextStyle(color: Colors.grey, fontSize: 14.sp),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryColor,
      ),
    );
  }
}
