class ExpenseDataModel {
  final int? id;
  final String name;
  final String date;
  final int expense;

  ExpenseDataModel({
    this.id,
    required this.name,
    required this.date,
    required this.expense
  });

  factory ExpenseDataModel.fromMap(Map<String, dynamic>map){
    return ExpenseDataModel(
        id: map['id'],
        name: map['name'],
        date: map['date'],
        expense: map['expense']
    );
  }

  Map<String, Object?> toMap() {
    return {
      //'id'     : id,
      'name': name,
      'date': date,
      'expense': expense
    };
  }
}
