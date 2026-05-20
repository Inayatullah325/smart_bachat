import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:smart_bachat/core/constant_colors.dart';
import 'package:smart_bachat/database_model_class/income_data_model.dart';
import 'package:smart_bachat/providers/home_provider.dart';

import 'package:smart_bachat/ui/components/rounded_container.dart';
import 'package:smart_bachat/ui/components/transaction_item.dart';
import 'package:smart_bachat/ui/screens/ui/all_categories_screen/all_categories_screen.dart';
import '../../../../database_model_class/expense_data_model.dart';
import '../navigation_drawer/navigation_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //final objAddExpense = BottomSheetAddExpenses();
  TextEditingController addIncomeController = TextEditingController();
  TextEditingController incomeDateController = TextEditingController();

  String? categoryName;
  DateTime? selectedDate;
  String? formattedDate;
  int? expense;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HomeProvider>(context, listen: false).fetchHomeData();
    });
  }

  // variables for dynamic update/delete
  int? _selectedId;
  String? _selectedName;
  String? _selectedDate;
  int? _selectedExpense;

  // List of items with icon and text for update bottom sheet
  List<Map<String, dynamic>> allCategoriesList = [
    {
      'icon': Icons.fastfood_outlined,
      'name': 'Groceries',
      'value': 'Groceries',
    },
    {
      'icon': Icons.medical_information_outlined,
      'name': 'Health',
      'value': 'Health',
    },
    {
      'icon': Icons.menu_book_outlined,
      'name': 'Education',
      'value': 'Education',
    },
    {
      'icon': Icons.directions_bus_outlined,
      'name': 'Transport',
      'value': 'Transport',
    },
    {
      'icon': Icons.lightbulb_circle_outlined,
      'name': 'Bills',
      'value': 'Bills',
    },
    {'icon': Icons.apartment_outlined, 'name': 'Rent', 'value': 'Rent'},
    {
      'icon': Icons.credit_score_outlined,
      'name': 'Salaries',
      'value': 'Salaries',
    },
    {
      'icon': Icons.volunteer_activism_outlined,
      'name': 'Charity',
      'value': 'Charity',
    },
    {
      'icon': Icons.shopping_cart_outlined,
      'name': 'Shopping',
      'value': 'Shopping',
    },
    {
      'icon': Icons.handyman_outlined,
      'name': 'Maintenance',
      'value': 'Maintenance',
    },
    {'icon': Icons.chair_outlined, 'name': 'Household', 'value': 'Household'},
    {'icon': Icons.pets_outlined, 'name': 'Pets', 'value': 'Pets'},
    {'icon': Icons.sports_tennis_outlined, 'name': 'Sports', 'value': 'Sports'},
    {
      'icon': Icons.movie_filter_outlined,
      'name': 'Entertainment',
      'value': 'Entertainment',
    },
    {'icon': Icons.card_giftcard_outlined, 'name': 'Gifts', 'value': 'Gifts'},
    {'icon': Icons.beach_access, 'name': 'Vacations', 'value': 'Vacations'},
    {
      'icon': Icons.restaurant_menu_outlined,
      'name': 'Restaurant',
      'value': 'Restaurant',
    },
    {'icon': Icons.note_alt_outlined, 'name': 'Others', 'value': 'Others'},
  ];

  String? selectedValue;
  TextEditingController updateExpenseController = TextEditingController();
  TextEditingController updateDateController = TextEditingController();
  final _updateExpenseFormKey = GlobalKey<FormState>();

  void showExpenseDelUpBtmSht() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.25,
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
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.lightBlueAccent,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Make Changes',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 5.w),
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    showUpdateExpenseBtmSht(
                      _selectedId!,
                      _selectedName!,
                      _selectedDate!,
                      _selectedExpense!,
                    );
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
                        color: Colors.lightBlueAccent,
                        size: 3.5.h,
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(
                thickness: 1,
                color: Colors.lightBlueAccent,
                indent: 20,
                endIndent: 20,
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 5.w),
                child: InkWell(
                  onTap: () async {
                    await Provider.of<HomeProvider>(
                      context,
                      listen: false,
                    ).deleteExpense(_selectedId!);
                    Navigator.pop(context);
                    Fluttertoast.showToast(
                      msg: "Record Deleted",
                      backgroundColor: Colors.red,
                    );
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
            ],
          ),
        );
      },
    );
  }

  void showUpdateExpenseBtmSht(
    int id,
    String catgName,
    String updateDate,
    int expense,
  ) {
    updateExpenseController.text = expense.toString();
    updateDateController.text = updateDate;
    selectedValue = null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Form(
              key: _updateExpenseFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.07,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Update Expense',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 1.h,
                      horizontal: 5.w,
                    ),
                    child: DropdownButtonFormField<String>(
                      hint: Text(catgName, style: TextStyle(fontSize: 15.sp)),
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: 'Category',
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
                      value: selectedValue,
                      onChanged: (val) => setState(() => selectedValue = val),
                      items: allCategoriesList.map((item) {
                        return DropdownMenuItem<String>(
                          value: item['value'],
                          child: Row(
                            children: [
                              Icon(item['icon'], color: Colors.lightBlueAccent),
                              SizedBox(width: 2.w),
                              Text(
                                item['name'],
                                style: TextStyle(fontSize: 15.sp),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
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
                      validator: (value) =>
                          (value == null ||
                              value.isEmpty ||
                              int.tryParse(value) == null ||
                              int.tryParse(value)! <= 0)
                          ? 'Enter valid amount'
                          : null,
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      if (_updateExpenseFormKey.currentState!.validate()) {
                        await Provider.of<HomeProvider>(
                          context,
                          listen: false,
                        ).updateExpense(
                          id,
                          ExpenseDataModel(
                            name: selectedValue ?? catgName,
                            date: updateDate,
                            expense: int.parse(updateExpenseController.text),
                          ),
                        );
                        Navigator.pop(context);
                        Fluttertoast.showToast(
                          msg: "Updated successfully",
                          backgroundColor: Colors.green,
                        );
                      }
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 2.h,
                        horizontal: 5.w,
                      ),
                      child: Container(
                        height: 6.h,
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
        );
      },
    );
  }

  // Function to show date picker
  Future<void> _selectDate(BuildContext context) async {
    DateTime now = DateTime.now();
    // Show the date picker with restricted dates
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: DateTime(
        2020,
      ), // Allow selection from previous years (since 2020)
      lastDate: now, // Restrict to current date (no future months/years)
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        formattedDate = DateFormat('dd-MM-yyyy').format(selectedDate!);
        incomeDateController.text = formattedDate ?? '';
      });
    }
  }

  // Bottom sheet to add income
  final _formKey = GlobalKey<FormState>(); // Form key for validation

  void showIncomeBtmSht(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Allows the bottom sheet to take full height and be scrollable.
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(
              context,
            ).viewInsets.bottom, // Adjusts for the keyboard.
          ),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.38,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Form(
              key: _formKey, // Assign the form key
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize
                      .min, // Ensure it adjusts height based on content
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.07,
                      width: MediaQuery.of(context).size.width * 1,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25),
                        ),
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: 33.w),
                          Text(
                            'Add Income',
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

                    // Date input field with validation
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 1.h,
                        horizontal: 3.w,
                      ),
                      child: TextFormField(
                        controller: incomeDateController,
                        readOnly: true,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: 'Select Date',
                          prefixIcon: const Icon(
                            Icons.date_range_rounded,
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
                            return 'Please select a date';
                          }
                          return null;
                        },
                        onTap: () {
                          _selectDate(context);
                        },
                      ),
                    ),
                    // Text field for income entry with validation
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 1.h,
                        horizontal: 3.w,
                      ),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        controller: addIncomeController,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: 'Enter income here',
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
                            return 'Please enter a valid income';
                          }
                          if (int.tryParse(value) == null ||
                              int.tryParse(value)! <= 0) {
                            return 'Please enter a valid positive number';
                          }
                          return null;
                        },
                      ),
                    ),
                    // Add income button with form validation check
                    InkWell(
                      onTap: () async {
                        if (_formKey.currentState!.validate()) {
                          var date = incomeDateController.text;
                          var incomeText = addIncomeController.text;
                          int? income = int.tryParse(incomeText);

                          try {
                            // Await the insertion for reliability and speed perception
                            await Provider.of<HomeProvider>(
                              context,
                              listen: false,
                            ).addIncome(
                              IncomeDataModel(date: date, income: income!),
                            );

                            Fluttertoast.showToast(
                              msg: "Income added to wallet",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Colors.green,
                              textColor: Colors.white,
                              fontSize: 16.0,
                            );

                            // Clear controllers
                            addIncomeController.clear();
                            incomeDateController.clear();
                            selectedDate = null;
                            formattedDate = null;

                            // Close bottom sheet
                            Navigator.pop(context);
                          } catch (e) {
                            Fluttertoast.showToast(
                              msg: "Error: $e",
                              backgroundColor: Colors.red,
                            );
                          }
                        }
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 1.h,
                          horizontal: 2.w,
                        ),
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.06,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Text(
                              'Add Income',
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
    final homeProvider = Provider.of<HomeProvider>(context);

    return Scaffold(
      drawer: const MyNavigationDrawer(),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: AppColors.primaryColor,
        title: Text(
          'Home Screen',
          style: TextStyle(
            fontSize: 19.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.add_event,
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        overlayColor: Colors.white,
        overlayOpacity: 0.5,
        elevation: 20,
        spacing: 10,
        spaceBetweenChildren: 20,
        children: [
          SpeedDialChild(
            backgroundColor: AppColors.color_red,
            label: 'Add Expense',
            elevation: 15,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AllCategoriesScreen()),
              );
              if (mounted) {
                Provider.of<HomeProvider>(
                  context,
                  listen: false,
                ).fetchHomeData();
              }
            },
            child: Icon(
              Icons.credit_score_outlined,
              color: Colors.white,
              size: 3.h,
            ),
          ),
          SpeedDialChild(
            backgroundColor: AppColors.buttonsColor,
            label: 'Add Income',
            elevation: 15,
            onTap: () {
              showIncomeBtmSht(context);
            },
            child: Icon(
              Icons.account_balance_wallet,
              color: Colors.white,
              size: 3.h,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.28,
            decoration: const BoxDecoration(
              //color: Color(0xffE5E4E2),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(height: 1.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RoundedContainer(
                      containerColor: AppColors.buttonsColor,
                      containerIcon: Icons.account_balance_wallet,
                      containerText: 'Income',
                      containerValue: homeProvider.totalIncome,
                    ),
                  ],
                ),

                SizedBox(height: 1.h),
                // Linear progress indicator
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2.w),
                          child: LinearProgressIndicator(
                            minHeight: 0.8.h,
                            borderRadius: BorderRadius.circular(20),
                            value: homeProvider.totalIncome == 0
                                ? 0.0
                                : ((homeProvider.totalIncome -
                                              homeProvider.totalExpense) /
                                          homeProvider.totalIncome)
                                      .clamp(
                                        0.0,
                                        1.0,
                                      ), // Example: 80% of budget used
                            backgroundColor: Colors.grey[400],
                            color: AppColors.color_green,
                          ),
                        ),
                      ),

                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2.w),
                          child: LinearProgressIndicator(
                            minHeight: 0.8.h,
                            borderRadius: BorderRadius.circular(20),
                            value: homeProvider.totalIncome == 0
                                ? 0.0
                                : (homeProvider.totalExpense /
                                          homeProvider.totalIncome)
                                      .clamp(
                                        0.0,
                                        1.0,
                                      ), // Example: 80% of budget used
                            backgroundColor: Colors.grey[400],
                            color: AppColors.color_red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RoundedContainer(
                      containerColor: AppColors.color_green,
                      containerIcon: Icons.fact_check_outlined,
                      containerText: 'Balance',
                      containerValue: homeProvider.balance,
                    ),
                    SizedBox(width: 3.w),
                    RoundedContainer(
                      containerColor: AppColors.color_red,
                      containerIcon: Icons.credit_score_rounded,
                      containerText: 'Expenses',
                      containerValue: homeProvider.totalExpense,
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 1.h),
          Text(
            'Recent Transactions',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),

          Expanded(
            child: homeProvider.recentExpenses.isEmpty
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
                : ListView.builder(
                    itemCount: homeProvider.recentExpenses.length,
                    itemBuilder: (context, index) {
                      final transaction = homeProvider.recentExpenses[index];
                      return SlidableTransactionItem(
                        transaction: transaction,
                        index: index,
                        onDelete: () async {
                          _selectedId = transaction.id;
                          showExpenseDelUpBtmSht();
                        },
                        onUpdate: () {
                          _selectedId = transaction.id;
                          _selectedName = transaction.name;
                          _selectedDate = transaction.date;
                          _selectedExpense = transaction.expense;
                          showUpdateExpenseBtmSht(
                            transaction.id!,
                            transaction.name,
                            transaction.date,
                            transaction.expense,
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
