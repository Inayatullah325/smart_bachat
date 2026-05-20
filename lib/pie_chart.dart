import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class PieChartSample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SfCircularChart(
        title: ChartTitle(text: 'Sales distribution of products'),
        legend: Legend(isVisible: true),
        series: <PieSeries<_PieData, String>>[
          PieSeries<_PieData, String>(
            dataSource: _getPieData(),
            xValueMapper: (_PieData data, _) => data.category,
            yValueMapper: (_PieData data, _) => data.sales,
            dataLabelMapper: (_PieData data, _) => data.category,
            dataLabelSettings: DataLabelSettings(isVisible: true),
          ),
        ],
      ),
    );


  }

  List<_PieData> _getPieData() {
    final List<_PieData> pieData = [
      _PieData('Electronics', 35),
      _PieData('Clothing', 28),
      _PieData('Groceries', 34),
      _PieData('Footwear', 52),
      _PieData('Accessories', 40)
    ];
    return pieData;
  }
}

class _PieData {
  _PieData(this.category, this.sales);

  final String category;
  final double sales;
}