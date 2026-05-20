class ExpenseDatabaseModel{
  final DateTime date;
  final int income;

  ExpenseDatabaseModel({
    required this.date,
    required this.income
  });


  factory ExpenseDatabaseModel.fromMap(Map<String, dynamic>map){
    return ExpenseDatabaseModel(
        date: map['date'],
        income: map['income']);
  }

  Map<String, Object?> toMap(){
    return {
      'date'   : date,
      'income' : income
    };
  }
}