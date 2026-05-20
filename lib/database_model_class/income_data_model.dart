class IncomeDataModel {
  final int? id;
  final String? date;
  final int? income;

  IncomeDataModel({
    this.id,
    required this.date,
    required this.income,
  });

  factory IncomeDataModel.fromMap(Map<String, dynamic> map) {
    return IncomeDataModel(
        id: map['id'],
        date: map['date'],
        income: map['income']);
  }

  Map<String, Object?> toMap() {
    return {
      //'id'     : id,
      'date': date,
      'income': income
    };
  }
}