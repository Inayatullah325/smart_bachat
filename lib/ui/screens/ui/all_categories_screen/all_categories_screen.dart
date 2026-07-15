import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:smart_bachat/core/app_utils.dart';
import 'package:smart_bachat/core/constant_colors.dart';
import 'package:smart_bachat/database_model_class/expense_data_model.dart';
import 'package:smart_bachat/providers/transaction_provider.dart';
import 'package:smart_bachat/l10n/app_localizations.dart';

class AllCategoriesScreen extends StatefulWidget {
  const AllCategoriesScreen({super.key});

  @override
  State<AllCategoriesScreen> createState() => _AllCategoriesScreenState();
}

class _AllCategoriesScreenState extends State<AllCategoriesScreen> {
  final TextEditingController dateController = TextEditingController();
  final TextEditingController addExpenseController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final GlobalKey<FormState> _expenseFormKey = GlobalKey<FormState>();

  String searchQuery = '';
  String? _selectedDate;

  @override
  void dispose() {
    dateController.dispose();
    addExpenseController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final filteredCategories = AppUtils.allCategoriesList
        .where(
          (cat) => cat['name'].toString().toLowerCase().contains(
            searchQuery.toLowerCase(),
          ),
        )
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xffF2F3F5),
      appBar: AppBar(
        title: Text(
          l10n.categorySelection,
          style: TextStyle(
            fontSize: 19.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 1.h),

              // Search Bar
              Container(
                height: 5.5.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(horizontal: 2.w),
                child: TextField(
                  controller: searchController,
                  cursorColor: AppColors.primaryColor,
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.trim();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: l10n.searchCategories,
                    hintStyle: TextStyle(
                      color: Colors.black54,
                      fontSize: 15.sp,
                    ),
                    border: InputBorder.none,
                    prefixIcon: const Icon(Icons.search, color: Colors.black54),
                  ),
                ),
              ),
              SizedBox(height: 3.h),

              // Grid
              Expanded(
                child: filteredCategories.isEmpty
                    ? Center(
                        child: Text(
                          l10n.noCategoriesFound,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    : GridView.builder(
                        itemCount: filteredCategories.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.82,
                            ),
                        itemBuilder: (context, int index) {
                          final item = filteredCategories[index];
                          final Color catColor = item['color'];
                          final String catKey =
                              item['name'] as String; // English DB key
                          final String catDisplayName =
                              AppUtils.getCategoryLocalizedName(
                                catKey,
                                context,
                              );
                          final IconData catIcon = item['icon'];

                          return InkWell(
                            onTap: () {
                              showExpenseDialog(
                                context,
                                catIcon,
                                catKey,
                                catDisplayName,
                              );
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: LinearGradient(
                                  colors: [
                                    catColor.withValues(alpha: 0.4),
                                    catColor.withValues(alpha: 0.05),
                                    Colors.transparent,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                border: Border.all(
                                  color: catColor.withValues(alpha: 0.25),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: catColor.withValues(alpha: 0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  Positioned(
                                    top: 1.h,
                                    left: 0,
                                    right: 0,
                                    child: Center(
                                      child: Text(
                                        catDisplayName,
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 14.5.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Padding(
                                      padding: EdgeInsets.only(top: 1.h),
                                      child: Icon(
                                        catIcon,
                                        size: 4.5.h,
                                        color: catColor,
                                        shadows: [
                                          Shadow(
                                            color: catColor.withValues(alpha: 0.4),
                                            blurRadius: 15,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 1.h,
                                    left: 2.w,
                                    right: 2.w,
                                    child: Text(
                                      l10n.tapToSelect,
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 12.sp,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await AppUtils.selectDate(context, lastDate: DateTime.now());
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        dateController.text = picked;
      });
    }
  }

  void showExpenseDialog(
    BuildContext context,
    IconData icon,
    String categoryName, // English value saved to DB
    String displayName, // Localized label shown in UI
  ) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(4.w),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Form(
              key: _expenseFormKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.addExpense,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: AppColors.primaryColor.withValues(alpha: 0.1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, size: 4.h, color: AppColors.primaryColor),
                          SizedBox(width: 3.w),
                          Text(
                            displayName,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 3.h),
                    TextFormField(
                      controller: dateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: l10n.selectDate,
                        prefixIcon: const Icon(
                          Icons.date_range_outlined,
                          color: AppColors.primaryColor,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: AppColors.primaryColor,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: AppColors.buttonsColor,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.pleaseSelectDate;
                        }
                        return null;
                      },
                      onTap: () => _selectDate(context),
                    ),
                    SizedBox(height: 2.h),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      controller: addExpenseController,
                      decoration: InputDecoration(
                        labelText: l10n.enterExpenseHere,
                        prefixIcon: const Icon(
                          Icons.credit_score_outlined,
                          color: AppColors.primaryColor,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: AppColors.primaryColor,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: AppColors.buttonsColor,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.pleaseEnterExpense;
                        }
                        if (int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return l10n.pleaseEnterPositiveNumber;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 3.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          padding: EdgeInsets.symmetric(vertical: 1.8.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          if (_expenseFormKey.currentState!.validate()) {
                            final expenseText = addExpenseController.text
                                .trim();
                            final expense = int.tryParse(expenseText);
                            if (expense == null || _selectedDate == null) {
                              return;
                            }

                            Provider.of<TransactionProvider>(
                              context,
                              listen: false,
                            ).addExpense(
                              ExpenseDataModel(
                                name: categoryName,
                                date: _selectedDate!,
                                expense: expense,
                              ),
                            );

                            dateController.clear();
                            addExpenseController.clear();
                            _selectedDate = null;

                            Fluttertoast.showToast(
                              msg: l10n.expenseAdded,
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.TOP,
                              backgroundColor: AppColors.primaryColor,
                              textColor: Colors.white,
                            );
                            Navigator.pop(context);
                          }
                        },
                        child: Text(
                          l10n.addExpense,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
}
