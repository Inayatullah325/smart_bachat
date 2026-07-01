import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:smart_bachat/core/constant_colors.dart';
import 'package:smart_bachat/core/app_utils.dart';
import 'package:smart_bachat/database_model_class/income_data_model.dart';

/// Reusable update income dialog — same design as expense dialog.
void showUpdateIncomeDialog({
  required BuildContext context,
  required int id,
  required String date,
  required int income,
  required Future<void> Function(int id, IncomeDataModel model) onUpdate,
  String successMessage = 'Updated successfully',
}) {
  final updateIncomeController = TextEditingController(text: income.toString());
  final dateController = TextEditingController(text: date);
  final formKey = GlobalKey<FormState>();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
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
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Edit Income',
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
                          color: AppColors.incomeColor.withOpacity(0.1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.account_balance_wallet_rounded,
                              size: 4.h,
                              color: AppColors.incomeColor,
                            ),
                            SizedBox(width: 3.w),
                            Text(
                              'Income Entry',
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
                          labelText: 'Select Date',
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
                            return 'Please select a date';
                          }
                          return null;
                        },
                        onTap: () async {
                          final picked = await AppUtils.selectDate(
                            context,
                            lastDate: DateTime(2099),
                          );
                          if (picked != null) {
                            dateController.text = picked;
                            setDialogState(() {});
                          }
                        },
                      ),
                      SizedBox(height: 2.h),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        controller: updateIncomeController,
                        decoration: InputDecoration(
                          labelText: 'Enter income here',
                          prefixIcon: const Icon(
                            Icons.payments_outlined,
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
                            return 'Please enter a valid income amount';
                          }
                          if (int.tryParse(value) == null ||
                              int.tryParse(value)! <= 0) {
                            return 'Please enter a valid positive number';
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
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              try {
                                await onUpdate(
                                  id,
                                  IncomeDataModel(
                                    id: id,
                                    date: dateController.text.trim(),
                                    income: int.parse(
                                      updateIncomeController.text.trim(),
                                    ),
                                  ),
                                );
                                if (context.mounted) Navigator.pop(context);
                                Fluttertoast.showToast(
                                  msg: successMessage,
                                  toastLength: Toast.LENGTH_LONG,
                                  gravity: ToastGravity.TOP,
                                  backgroundColor: AppColors.primaryColor,
                                  textColor: Colors.white,
                                );
                              } catch (e) {
                                debugPrint('Error updating income: $e');
                              }
                            }
                          },
                          child: const Text(
                            'Update Income',
                            style: TextStyle(
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
    },
  );
}
