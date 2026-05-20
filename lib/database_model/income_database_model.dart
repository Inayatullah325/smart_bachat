class IncomeDatabaseModel{
  final int? id;
  final DateTime date;
  final int income;

  IncomeDatabaseModel({
    this.id,
    required this.date,
    required this.income
  });


  factory IncomeDatabaseModel.fromMap(Map<String, dynamic>map){
    return IncomeDatabaseModel(
        id: map['id'],
        date: map['date'],
        income: map['income']);
  }

  Map<String, Object?> toMap(){
    return {
      'id'     : id,
      'date'   : date,
      'income' : income
    };
  }
}