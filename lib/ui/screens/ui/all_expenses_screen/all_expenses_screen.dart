import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../../core/constant_colors.dart';
import '../../../../database_model_class/expense_data_model.dart';
import 'package:smart_bachat/providers/transaction_provider.dart';

class AllExpensesScreen extends StatefulWidget {
  const AllExpensesScreen({super.key});

  @override
  State<AllExpensesScreen> createState() => _AllExpensesScreenState();
}

class _AllExpensesScreenState extends State<AllExpensesScreen> {
  // controllers
  TextEditingController dateController = TextEditingController();
  TextEditingController addExpenseController = TextEditingController();

  // variables for operations
  String? categoryName;
  var selectedDate;
  var formattedDate;
  int? expense;

  var name;
  int? id;

  String? databaseDate;
  int? databaseExpense;

  var expenseToController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransactionProvider>(
        context,
        listen: false,
      ).fetchAllExpenses();
    });
  }

  showExpenseDelUpBtmSht() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.25,
          width: MediaQuery.of(context).size.width * 1,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.07,
                width: MediaQuery.of(context).size.width * 1,
                decoration: const BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(width: 33.w),
                    Text(
                      'Make Changes',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 2.h),

              // update expense
              Padding(
                padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 5.w),
                child: InkWell(
                  onTap: () {
                    try {
                      showUpdateExpenseBtmSht(
                        context,
                        id!,
                        name!,
                        databaseDate!,
                        databaseExpense!,
                      );
                    } catch (e) {
                      Fluttertoast.showToast(
                        msg: "$id",
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.blue,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Update',
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Icon(
                        Icons.edit,
                        size: 3.5.h,
                        color: Colors.lightBlueAccent,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 0.5.h, horizontal: 5.w),
                child: Divider(
                  height: 2.h,
                  thickness: 1,
                  color: Colors.lightBlueAccent,
                ),
              ),

              // delete expense
              Padding(
                padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 5.w),
                child: InkWell(
                  onTap: () async {
                    try {
                      await Provider.of<TransactionProvider>(
                        context,
                        listen: false,
                      ).deleteExpense(id!);
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                      Fluttertoast.showToast(
                        msg: "Record Deleted",
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.TOP,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.blue,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    } catch (e) {
                      print(e);
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Delete',
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Icon(
                        Icons.delete,
                        color: Colors.lightBlueAccent,
                        size: 3.5.h,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 2.h),
            ],
          ),
        );
      },
    );
  }

  // update expense sheet variables
  String? selectedValue;
  TextEditingController updateExpenseController = TextEditingController();
  TextEditingController updateDateController = TextEditingController();

  List<String> listItems = [
    'Groceries',
    'Health',
    'Education',
    'Transport',
    'Bills',
    'Rent',
    'Salaries',
    'Charity',
    'Shopping',
    'Maintenance',
    'Household',
    'Pets',
    'Sports',
    'Entertainment',
    'Gifts',
    'Vacations',
    'Restaurant',
    'Others',
  ];

  // Define the form key
  final GlobalKey<FormState> _updateExpenseFormKey = GlobalKey<FormState>();

  void showUpdateExpenseBtmSht(
    BuildContext context,
    int id,
    String catgName,
    String updateDate,
    int expenseVal,
  ) {
    // Initialize the controllers only when the bottom sheet is opened
    updateExpenseController.text = expenseVal.toString();
    updateDateController.text = updateDate;
    selectedValue = catgName;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(
              context,
            ).viewInsets.bottom, // Adjust for the keyboard
          ),
          child: SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.38,
              width: MediaQuery.of(context).size.width * 1,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Form(
                key: _updateExpenseFormKey, // Attach the form key
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.07,
                      width: MediaQuery.of(context).size.width * 1,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25),
                        ),
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: 33.w),
                          Text(
                            'Update Expense',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Dropdown for Category
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 0.5.h,
                        horizontal: 5.w,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.lightBlueAccent),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.transparent,
                                ),
                              ),
                            ),
                            value: selectedValue,
                            items: listItems.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedValue = newValue;
                              });
                            },
                          ),
                        ),
                      ),
                    ),

                    // Text field for expense entry with validator
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 1.h,
                        horizontal: 5.w,
                      ),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        controller: updateExpenseController,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: 'Expense',
                          prefixIcon: const Icon(
                            Icons.credit_score_outlined,
                            color: Colors.blue,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: Colors.blue),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Colors.lightBlueAccent,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an expense amount';
                          }
                          if (int.tryParse(value) == null ||
                              int.tryParse(value)! <= 0) {
                            return 'Please enter a valid positive number';
                          }
                          return null;
                        },
                      ),
                    ),

                    // Update expense button with form validation
                    InkWell(
                      onTap: () async {
                        if (_updateExpenseFormKey.currentState!.validate()) {
                          var updatedName = selectedValue;
                          var updatedDate = updateDateController.text.trim();
                          var updatedExpenseText = updateExpenseController.text
                              .trim();
                          int? updatedExpense = int.tryParse(
                            updatedExpenseText,
                          );

                          try {
                            await Provider.of<TransactionProvider>(
                              context,
                              listen: false,
                            ).updateExpense(
                              id!,
                              ExpenseDataModel(
                                id: id,
                                name: updatedName ?? catgName,
                                date: updatedDate,
                                expense: updatedExpense!,
                              ),
                            );
                            if (mounted) {
                              Navigator.pop(context); // Close update sheet
                              Navigator.pop(context); // Close actions sheet
                            }
                          } catch (e) {
                            print('Error updating expense: $e');
                          }
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 20,
                        ),
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.06,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Text(
                              'Update Expense',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _sectionHeader(String title, int total) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border(
              left: BorderSide(color: AppColors.primaryColor, width: 4),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
              Text(
                'Total: Rs $total',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.color_red,
                ),
              ),
            ],
          ),
        ),
        const Divider(thickness: 1, indent: 15, endIndent: 15),
      ],
    );
  }

  Widget _buildExpenseItem(ExpenseDataModel transaction, int index) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h, horizontal: 3.w),
      child: Card(
        elevation: 3,
        child: ListTile(
          onTap: () {
            id = transaction.id;
            name = transaction.name.toString();
            databaseDate = transaction.date.toString();
            databaseExpense = transaction.expense;
            showExpenseDelUpBtmSht();
          },
          leading: CircleAvatar(
            backgroundColor: AppColors.getCategoryColor(transaction.name),
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            transaction.name.toString(),
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.getCategoryColor(transaction.name),
            ),
          ),
          subtitle: Text(
            transaction.date.toString(),
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          trailing: Text(
            'Rs ${transaction.expense}',
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.color_red,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xffF2F3F5),
      appBar: AppBar(
        title: Text(
          'All Expenses',
          style: TextStyle(
            fontSize: 19.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
      ),
      body: transactionProvider.isLoadingExpenses
          ? const Center(child: CircularProgressIndicator())
          : transactionProvider.expenses.isEmpty
          ? Center(
              child: Text(
                'No data available.',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            )
          : _buildExpenseList(transactionProvider.expenses),
    );
  }
  Widget _buildExpenseList(List<ExpenseDataModel> expensesList) {
    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;

    List<ExpenseDataModel> thisMonth = [];
    List<ExpenseDataModel> thisYear = [];
    Map<int, List<ExpenseDataModel>> previousYearsMap = {};

    for (var item in expensesList) {
      final parts = item.date?.split('-') ?? [];
      if (parts.length == 3) {
        final m = int.tryParse(parts[1]) ?? 0;
        final y = int.tryParse(parts[2]) ?? 0;
        if (y == currentYear) {
          if (m == currentMonth) {
            thisMonth.add(item);
          } else {
            thisYear.add(item);
          }
        } else {
          previousYearsMap.putIfAbsent(y, () => []).add(item);
        }
      } else {
        previousYearsMap.putIfAbsent(0, () => []).add(item);
      }
    }

    int thisMonthTotal = thisMonth.fold(
      0,
      (sum, item) => sum + (item.expense ?? 0),
    );
    int thisYearTotal = thisYear.fold(
      0,
      (sum, item) => sum + (item.expense ?? 0),
    );

    final sortedYears = previousYearsMap.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView(
      children: [
        if (thisMonth.isNotEmpty) ...[
          _sectionHeader('This Month', thisMonthTotal),
          ...thisMonth.asMap().entries.map((entry) {
            return _buildExpenseItem(entry.value, entry.key);
          }),
        ],
        if (thisYear.isNotEmpty) ...[
          _sectionHeader('This Year ($currentYear)', thisYearTotal),
          ...thisYear.asMap().entries.map((entry) {
            return _buildExpenseItem(entry.value, entry.key);
          }),
        ],
        for (var year in sortedYears) ...[
          if (previousYearsMap[year]!.isNotEmpty) ...[
            _sectionHeader(
              year == 0 ? 'Unknown Year' : 'Year $year',
              previousYearsMap[year]!.fold(0, (sum, item) => sum + (item.expense ?? 0)),
            ),
            ...previousYearsMap[year]!.asMap().entries.map((entry) {
              return _buildExpenseItem(entry.value, entry.key);
            }),
          ]
        ]
      ],
    );
  }
}
