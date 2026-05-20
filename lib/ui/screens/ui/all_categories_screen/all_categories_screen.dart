import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:smart_bachat/database_model_class/expense_data_model.dart';
import 'package:smart_bachat/providers/all_categories_provider.dart';
import 'package:smart_bachat/providers/transaction_provider.dart';
import '../../../../core/constant_colors.dart';

class AllCategoriesScreen extends StatefulWidget {
  const AllCategoriesScreen({super.key});

  @override
  State<AllCategoriesScreen> createState() => _AllCategoriesScreenState();
}

class _AllCategoriesScreenState extends State<AllCategoriesScreen> {
  final objColors = AppColors();
  // Controllers for text fields
  TextEditingController dateController = TextEditingController();
  TextEditingController addExpenseController = TextEditingController();

  String? categoryName;
  var selectedDate;
  var formattedDate;
  int? expense;

  @override
  Widget build(BuildContext context) {
    final objColor = AppColors();
    final objAllCategoriesProvider = Provider.of<AllCategoriesProvider>(
      context,
    );

    return Scaffold(
      backgroundColor: Color(0xffF2F3F5),
      appBar: AppBar(
        title: Text(
          'Categories',
          style: TextStyle(
            fontSize: 19.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.h),
        child: GridView.builder(
          itemCount: objAllCategoriesProvider.allCategoriesList.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 2 / 2,
          ),
          itemBuilder: (context, int index) {
            return InkWell(
              onTap: () {
                showExpenseBtmSht(
                  context,
                  objAllCategoriesProvider.allCategoriesList[index]['icon'],
                  objAllCategoriesProvider.allCategoriesList[index]['name'],
                );
              },
              child: Card(
                elevation: 5,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.07,
                  width: MediaQuery.of(context).size.width * 0.07,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 0.5.h,
                            horizontal: 2.w,
                          ),
                          child: Icon(
                            objAllCategoriesProvider
                                .allCategoriesList[index]['icon'],
                            size: 4.h,
                            color: objAllCategoriesProvider
                                .allCategoriesList[index]['color'],
                          ),
                        ),

                        //divider
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 0.5.h,
                            horizontal: 2.w,
                          ),
                          child: Divider(
                            height: 0.2.h,
                            thickness: 0.2.h,
                            color: objAllCategoriesProvider
                                .allCategoriesList[index]['color'],
                          ),
                        ),

                        //category name
                        Padding(
                          padding: EdgeInsets.all(0.5.h),
                          child: Center(
                            child: Text(
                              categoryName = objAllCategoriesProvider
                                  .allCategoriesList[index]['name'],
                              style: TextStyle(fontSize: 15.sp),
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
        ),
      ),
    );
  }

  // Function to show date picker
  Future<void> _selectDate(BuildContext context) async {
    DateTime now = DateTime.now();
    // Show the date picker with restricted dates
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          selectedDate ?? now, // Default to selected date or today's date
      firstDate: DateTime(2020), // Allow selection from previous years
      lastDate: now, // Allow selection only until today
    );

    // If a date is selected
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        formattedDate = DateFormat(
          'dd-MM-yyyy',
        ).format(selectedDate!); // Format the date
        dateController.text =
            formattedDate; // Set the formatted date in the controller
      });
    }
  }

  // bottom sheet
  final _expenseFormKey = GlobalKey<FormState>(); // Form key for validation

  void showExpenseBtmSht(
    BuildContext context,
    IconData icon,
    String categoryName,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Allows the bottom sheet to expand when the keyboard appears
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false, // Makes the sheet draggable and scrollable
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller:
                  scrollController, // Ensures the content inside the sheet can scroll
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(
                    context,
                  ).viewInsets.bottom, // Adjust for the keyboard
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Form(
                    key: _expenseFormKey, // Form key for validation
                    child: Column(
                      mainAxisSize: MainAxisSize
                          .min, // Makes the column take minimal space
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height * 0.07,
                          width: MediaQuery.of(context).size.width * 1,
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(25),
                              topRight: Radius.circular(25),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Add Expense',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Icon and Category Name Container
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 1.h),
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.12,
                            width: MediaQuery.of(context).size.width * 0.28,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Icon(
                                  icon,
                                  size: 5.h,
                                  color: AppColors.primaryColor,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 0.5.h,
                                    horizontal: 2.w,
                                  ),
                                  child: Divider(
                                    height: 1.0,
                                    thickness: 0.3.h,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                                Text(
                                  categoryName,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Date Input Field with Validation
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 1.h,
                            horizontal: 2.w,
                          ),
                          child: TextFormField(
                            controller: dateController,
                            readOnly:
                                true, // Prevents manual editing of the date
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Select Date',
                              prefixIcon: Icon(
                                Icons.date_range_outlined,
                                color: Colors.blue,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
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
                              _selectDate(context); // Opens the date picker
                            },
                          ),
                        ),

                        // Expense Entry Field with Validation
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 1.h,
                            horizontal: 2.w,
                          ),
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            controller: addExpenseController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Enter expense here',
                              prefixIcon: Icon(
                                Icons.credit_score_outlined,
                                color: Colors.blue,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.lightBlueAccent,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a valid expense amount';
                              }
                              if (int.tryParse(value) == null ||
                                  int.tryParse(value)! <= 0) {
                                return 'Please enter a valid positive number';
                              }
                              return null;
                            },
                          ),
                        ),

                        // Add Expense Button with Form Validation
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 1.h),
                          child: InkWell(
                            onTap: () {
                              if (_expenseFormKey.currentState!.validate()) {
                                var id = 1;
                                id += 1;

                                var expenseText = addExpenseController.text
                                    .trim();
                                int? expense = int.tryParse(expenseText);

                                Provider.of<TransactionProvider>(
                                  context,
                                  listen: false,
                                ).addExpense(
                                  ExpenseDataModel(
                                    id: id,
                                    name: categoryName,
                                    date: formattedDate.toString(),
                                    expense: expense!,
                                  ),
                                );

                                dateController.clear();
                                addExpenseController.clear();
                                selectedDate = null;
                                formattedDate = null;

                                Fluttertoast.showToast(
                                  msg: "Expense Added",
                                  toastLength: Toast.LENGTH_LONG,
                                  gravity: ToastGravity.TOP,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: AppColors.primaryColor,
                                  textColor: Colors.white,
                                  fontSize: 16.0,
                                );
                                Navigator.pop(context);
                              }
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 0.5.h,
                                horizontal: 2.w,
                              ),
                              child: Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.06,
                                decoration: BoxDecoration(
                                  color: AppColors.buttonsColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    'Add Expense',
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
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
