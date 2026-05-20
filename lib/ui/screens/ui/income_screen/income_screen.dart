import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:smart_bachat/database_model_class/income_data_model.dart';
import 'package:smart_bachat/providers/transaction_provider.dart';
import '../../../../core/constant_colors.dart';

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({super.key});

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  int? id;

  // these variables have used to update the database records
  String? databaseDate;
  int? databaseIncome;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransactionProvider>(
        context,
        listen: false,
      ).fetchAllIncomes();
    });
  }

  showIncomeDelUpBtmSht() {
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
                      showUpdateIncomeBtmSht(
                        context,
                        id!,
                        databaseDate!,
                        databaseIncome!,
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
                      ).deleteIncome(id!);
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

  String? selectedValue;
  TextEditingController updateIncomeController = TextEditingController();
  TextEditingController updateDateController = TextEditingController();

  // Define the form key
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void showUpdateIncomeBtmSht(
    BuildContext context,
    int id,
    String updateDate,
    int income,
  ) {
    // Initialize the controllers only when the bottom sheet is opened
    updateIncomeController.text = income.toString();
    updateDateController.text = updateDate;

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
              height: MediaQuery.of(context).size.height * 0.3,
              width: MediaQuery.of(context).size.width * 1,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Form(
                key: _formKey, // Attach the form key
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
                            'Update Income',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Text field for income entry
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 1.h,
                        horizontal: 5.w,
                      ),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        controller: updateIncomeController,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: 'Income',
                          prefixIcon: const Icon(
                            Icons.account_balance_wallet,
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
                            return 'Please enter an income amount';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                    ),

                    // Update income button
                    InkWell(
                      onTap: () async {
                        if (_formKey.currentState!.validate()) {
                          var updatedDate = updateDateController.text.trim();
                          var updatedIncomeText = updateIncomeController.text
                              .trim();
                          int? updatedIncome = int.tryParse(updatedIncomeText);

                          await Provider.of<TransactionProvider>(
                            context,
                            listen: false,
                          ).updateIncome(
                            id,
                            IncomeDataModel(
                              date: updatedDate,
                              income: updatedIncome,
                            ),
                          );

                          if (mounted) {
                            Navigator.pop(context); // Close update bottom sheet
                            Navigator.pop(
                              context,
                            ); // Close details bottom sheet
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
                              'Update Income',
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

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Text(
          'Income Screen',
          style: TextStyle(
            fontSize: 19.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: transactionProvider.isLoadingIncomes
          ? const Center(child: CircularProgressIndicator())
          : transactionProvider.incomes.isEmpty
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
          : _buildIncomeList(transactionProvider.incomes),
    );
  }
  Widget _buildIncomeList(List<IncomeDataModel> incomesList) {
    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;

    List<IncomeDataModel> thisMonth = [];
    List<IncomeDataModel> thisYear = [];
    Map<int, List<IncomeDataModel>> previousYearsMap = {};

    for (var item in incomesList) {
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
      (sum, item) => sum + (item.income ?? 0),
    );
    int thisYearTotal = thisYear.fold(
      0,
      (sum, item) => sum + (item.income ?? 0),
    );

    final sortedYears = previousYearsMap.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView(
      children: [
        if (thisMonth.isNotEmpty) ...[
          _sectionHeader('This Month', thisMonthTotal),
          ...thisMonth.asMap().entries.map((entry) {
            return _buildIncomeItem(entry.value, entry.key);
          }),
        ],
        if (thisYear.isNotEmpty) ...[
          _sectionHeader('This Year ($currentYear)', thisYearTotal),
          ...thisYear.asMap().entries.map((entry) {
            return _buildIncomeItem(entry.value, entry.key);
          }),
        ],
        for (var year in sortedYears) ...[
          if (previousYearsMap[year]!.isNotEmpty) ...[
            _sectionHeader(
              year == 0 ? 'Unknown Year' : 'Year $year',
              previousYearsMap[year]!.fold(0, (sum, item) => sum + (item.income ?? 0)),
            ),
            ...previousYearsMap[year]!.asMap().entries.map((entry) {
              return _buildIncomeItem(entry.value, entry.key);
            }),
          ]
        ]
      ],
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
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: const Border(
              left: BorderSide(color: Colors.green, width: 4),
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
                  color: Colors.green[800],
                ),
              ),
              Text(
                'Total: Rs $total',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.color_green,
                ),
              ),
            ],
          ),
        ),
        const Divider(thickness: 1, indent: 15, endIndent: 15),
      ],
    );
  }

  Widget _buildIncomeItem(IncomeDataModel item, int index) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h, horizontal: 2.w),
      child: Card(
        elevation: 3,
        child: ListTile(
          onTap: () {
            id = item.id;
            databaseDate = item.date.toString();
            databaseIncome = item.income;
            showIncomeDelUpBtmSht();
          },
          leading: CircleAvatar(
            backgroundColor: Colors.primaries[index % Colors.primaries.length],
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            'Rs ${item.income}',
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.color_green,
            ),
          ),
          subtitle: Text(
            item.date.toString(),
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          trailing: const Icon(Icons.more_vert, color: AppColors.primaryColor),
        ),
      ),
    );
  }
}
