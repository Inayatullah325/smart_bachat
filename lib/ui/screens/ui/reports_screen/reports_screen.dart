import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:smart_bachat/core/app_utils.dart';
import 'package:smart_bachat/core/constant_colors.dart';
import 'package:smart_bachat/l10n/app_localizations.dart';
import 'package:smart_bachat/providers/settings_provider.dart';
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
    final l10n = AppLocalizations.of(context)!;

    if (reportsProvider.isLoading) {
      return Scaffold(
        appBar: _appBar(l10n),
        body: Center(
          child: CircleAvatar(
            radius: 35,
            backgroundColor: AppColors.primaryColor.withValues(alpha: 0.12),
            child: const SizedBox(
              width: 35,
              height: 35,
              child: CircularProgressIndicator(
                color: AppColors.primaryColor,
                strokeWidth: 3,
              ),
            ),
          ),
        ),
      );
    }

    if (reportsProvider.errorMessage != null) {
      return Scaffold(
        appBar: _appBar(l10n),
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
                child: Text(l10n.retry),
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
            l10n.statistics,
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
            tabs: [
              Tab(icon: const Icon(Icons.bar_chart), text: l10n.figure),
              Tab(icon: const Icon(Icons.pie_chart), text: l10n.chart),
              Tab(icon: const Icon(Icons.calendar_month), text: l10n.monthly),
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

  AppBar _appBar(AppLocalizations l10n) {
    return AppBar(
      backgroundColor: AppColors.primaryColor,
      automaticallyImplyLeading: false,
      title: Text(
        l10n.statistics,
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
    final l10n = AppLocalizations.of(context)!;
    final currencySymbol = Provider.of<SettingsProvider>(
      context,
    ).currencySymbol;
    final categories = provider.allTimeCategories;
    if (categories.isEmpty) return _emptyState(l10n.noExpenseData);

    final double totalExpense = categories.fold(
      0.0,
      (sum, c) => sum + c.totalExpense,
    );

    return Column(
      children: [
        // ── Header summary card ──────────────────────────────────────────
        Container(
          width: double.infinity,
          margin: EdgeInsets.fromLTRB(3.w, 2.h, 3.w, 1.h),
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryColor, AppColors.buttonsColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.totalOut,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    '$currencySymbol${totalExpense.toInt()}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    l10n.figure,
                    style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    '${categories.length} ${l10n.categories}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // ── Category list ────────────────────────────────────────────────
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final Color catColor = _getColorForCategory(cat.name, index);
              final double percent = totalExpense > 0
                  ? cat.totalExpense / totalExpense
                  : 0;

              return Container(
                margin: EdgeInsets.only(bottom: 1.4.h),
                padding: EdgeInsets.all(3.5.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: catColor.withValues(alpha: 0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: catColor.withValues(alpha: 0.18),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    // Name + progress bar
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppUtils.getCategoryLocalizedName(
                              cat.name,
                              context,
                            ),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15.sp,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 0.6.h),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: percent,
                              minHeight: 6,
                              backgroundColor: catColor.withValues(alpha: 0.12),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                catColor,
                              ),
                            ),
                          ),
                          SizedBox(height: 0.4.h),
                          Text(
                            '${(percent * 100).toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 3.w),
                    // Amount
                    Text(
                      '$currencySymbol${cat.totalExpense.toInt()}',
                      style: TextStyle(
                        color: AppColors.color_red,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChartTab(ReportsProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final monthName = _localizedMonthName(provider.currentMonth, locale);
    final categories = provider.allTimeCategories;
    if (categories.isEmpty) return _emptyState(l10n.noDataForCharts);
    return SingleChildScrollView(
      padding: EdgeInsets.all(3.w),
      child: Column(
        children: [
          _sectionTitle('${l10n.expensesDistribution} ($monthName)'),
          SizedBox(height: 1.h),
          _pieChart(categories),
          SizedBox(height: 3.h),
          _sectionTitle('${l10n.comparisonByCategory} ($monthName)'),
          SizedBox(height: 1.h),
          _barChart(categories),
        ],
      ),
    );
  }

  Widget _buildMonthlyTab(ReportsProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    final currencySymbol = Provider.of<SettingsProvider>(
      context,
    ).currencySymbol;
    return SingleChildScrollView(
      padding: EdgeInsets.all(3.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('${l10n.currentYear} (${provider.currentYear})'),
          Padding(
            padding: EdgeInsets.only(top: 0.5.h, bottom: 1.h),
            child: Text(
              l10n.currentYearBreakdown,
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
                color: AppColors.primaryColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.primaryColor.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _summaryItem(
                    l10n.totalIn,
                    totalYearIn,
                    AppColors.color_green,
                    currencySymbol,
                  ),
                  _summaryItem(
                    l10n.totalOut,
                    totalYearOut,
                    AppColors.color_red,
                    currencySymbol,
                  ),
                  _summaryItem(
                    l10n.saving,
                    totalYearSaving,
                    totalYearSaving >= 0 ? Colors.blue : Colors.orange,
                    currencySymbol,
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
              '${l10n.noData.replaceFirst('.', '')} (${provider.currentYear})',
            ),

          if (provider.historyData.isNotEmpty) ...[
            SizedBox(height: 3.h),
            _sectionTitle(l10n.prevYearsHistory),
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

  String _localizedMonthName(int month, String locale) {
    try {
      final date = DateTime(DateTime.now().year, month);
      return DateFormat.MMMM(locale).format(date);
    } catch (_) {
      return AppUtils.monthNames[month];
    }
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
            xValueMapper: (cat, _) =>
                AppUtils.getCategoryLocalizedName(cat.name, context),
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
            xValueMapper: (cat, _) =>
                AppUtils.getCategoryLocalizedName(cat.name, context),
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

  Widget _summaryItem(
    String label,
    int value,
    Color color,
    String currencySymbol,
  ) {
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
          '$currencySymbol$value',
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.primaryColor.withValues(alpha: 0.12),
            child: const Icon(
              Icons.bar_chart_rounded,
              color: AppColors.primaryColor,
              size: 38,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            msg,
            style: TextStyle(color: Colors.grey, fontSize: 14.sp),
          ),
        ],
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
