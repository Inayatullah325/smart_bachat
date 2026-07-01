import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:smart_bachat/core/constant_colors.dart';
import 'package:smart_bachat/database_model_class/category_expense_as_chart.dart';
import 'package:smart_bachat/providers/reports_provider.dart';

class YearExpandableSection extends StatelessWidget {
  final YearData yearData;
  final List<String> monthNames;
  final Color Function(String, int) colorMapper;

  const YearExpandableSection({
    super.key,
    required this.yearData,
    required this.monthNames,
    required this.colorMapper,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 1.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('${yearData.year} Summary'),
              SizedBox(height: 1.h),
              Container(
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
                    _yearSummaryItem(
                      'Total In',
                      yearData.totalIncome,
                      AppColors.color_green,
                    ),
                    _yearSummaryItem(
                      'Total Out',
                      yearData.totalExpense,
                      AppColors.color_red,
                    ),
                    _yearSummaryItem(
                      'Saving',
                      yearData.totalIncome - yearData.totalExpense,
                      (yearData.totalIncome - yearData.totalExpense) >= 0
                          ? Colors.blue
                          : Colors.orange,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        ...yearData.months.reversed.map(
          (m) => MonthExpandableCard(
            data: m,
            monthNames: monthNames,
            colorMapper: colorMapper,
          ),
        ),
      ],
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

  Widget _yearSummaryItem(String label, int value, Color color) {
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
}

class MonthExpandableCard extends StatefulWidget {
  final MonthData data;
  final List<String> monthNames;
  final Color Function(String, int) colorMapper;

  const MonthExpandableCard({
    super.key,
    required this.data,
    required this.monthNames,
    required this.colorMapper,
  });

  @override
  State<MonthExpandableCard> createState() => _MonthExpandableCardState();
}

class _MonthExpandableCardState extends State<MonthExpandableCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final balance = widget.data.income - widget.data.expense;
    return Card(
      margin: EdgeInsets.only(bottom: 1.h),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          ListTile(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            dense: true,
            leading: CircleAvatar(
              radius: 15,
              backgroundColor: AppColors.buttonsColor,
              child: Text(
                '${widget.data.month}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              widget.monthNames[widget.data.month],
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
            ),
            subtitle: Text(
              ' Bal: Rs $balance',
              style: TextStyle(
                color: balance >= 0
                    ? AppColors.color_green
                    : AppColors.color_red,
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: Icon(
              _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              size: 20,
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 2.h),
              child: Column(
                children: [
                  const Divider(),
                  _statRow('Income', widget.data.income, AppColors.color_green),
                  _statRow('Expense', widget.data.expense, AppColors.color_red),
                  _statRow(
                    'Total Saving',
                    widget.data.income - widget.data.expense,
                    (widget.data.income - widget.data.expense) >= 0
                        ? AppColors.color_green
                        : AppColors.color_red,
                  ),
                  if (widget.data.categories.isNotEmpty) ...[
                    SizedBox(height: 1.5.h),
                    ...widget.data.categories.map(
                      (c) => Padding(
                        padding: EdgeInsets.symmetric(vertical: 0.4.h),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: widget.colorMapper(c.name, 0),
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Expanded(
                              child: Text(
                                c.name,
                                style: TextStyle(fontSize: 16.sp),
                              ),
                            ),
                            Text(
                              'Rs ${c.totalExpense.toInt()}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15.sp,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 1.h),
                    SizedBox(
                      height: 18.h,
                      child: SfCircularChart(
                        series: <CircularSeries>[
                          PieSeries<CategoryExpense, String>(
                            dataSource: widget.data.categories,
                            xValueMapper: (d, _) => d.name,
                            yValueMapper: (d, _) => d.totalExpense,
                            pointColorMapper: (cat, index) =>
                                widget.colorMapper(cat.name, index),
                            dataLabelSettings: const DataLabelSettings(
                              isVisible: true,
                              labelPosition: ChartDataLabelPosition.outside,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _statRow(String label, int val, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Text(
            'Rs $val',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
