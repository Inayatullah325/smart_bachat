import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:smart_bachat/core/constant_colors.dart';
import 'package:smart_bachat/core/app_utils.dart';
import 'package:smart_bachat/database_model_class/expense_data_model.dart';
import 'package:smart_bachat/l10n/app_localizations.dart';

/// A reusable update expense dialog used across the app.
void showUpdateExpenseDialog({
  required BuildContext context,
  required int id,
  required String categoryName,
  required String date,
  required int expense,
  required Future<void> Function(int id, ExpenseDataModel model) onUpdate,
  String? successMessage,
}) {
  final updateExpenseController = TextEditingController(
    text: expense.toString(),
  );
  final dateController = TextEditingController(text: date);
  final formKey = GlobalKey<FormState>();
  String? selectedValue = categoryName;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      final l10n = AppLocalizations.of(context)!;
      final msg = successMessage ?? l10n.updatedSuccessfully;
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 8.h),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Title ──
                      Center(
                        child: Text(
                          l10n.editExpense,
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      SizedBox(height: 3.5.h),

                      // ── Select Category ──
                      Text(
                        l10n.selectCategory,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 0.8.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 0.2.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1.5,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                            dropdownColor: Colors.white,
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppColors.primaryColor,
                            ),
                            value: selectedValue,
                            isExpanded: true,
                            hint: Row(
                              children: [
                                const Icon(
                                  Icons.grid_view_rounded,
                                  color: AppColors.primaryColor,
                                  size: 20,
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  l10n.selectCategory,
                                  style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ],
                            ),
                            selectedItemBuilder: (context) {
                              return AppUtils.allCategoriesList.map((item) {
                                return Row(
                                  children: [
                                    Icon(
                                      item['icon'] as IconData,
                                      color: AppColors.primaryColor,
                                      size: 20,
                                    ),
                                    SizedBox(width: 2.w),
                                    Text(
                                      AppUtils.getCategoryLocalizedName(
                                        item['name'] as String,
                                        context,
                                      ),
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                );
                              }).toList();
                            },
                            items: AppUtils.allCategoriesList.map((item) {
                              return DropdownMenuItem<String>(
                                value: item['value'] as String,
                                child: Row(
                                  children: [
                                    Icon(
                                      item['icon'] as IconData,
                                      color: AppColors.primaryColor,
                                      size: 20,
                                    ),
                                    SizedBox(width: 2.w),
                                    Text(
                                      AppUtils.getCategoryLocalizedName(
                                        item['name'] as String,
                                        context,
                                      ),
                                      style: TextStyle(fontSize: 14.sp),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              selectedValue = val;
                              setDialogState(() {});
                            },
                            validator: (v) =>
                                v == null ? l10n.pleaseSelectCategory : null,
                          ),
                        ),
                      ),
                      SizedBox(height: 2.h),

                      // ── Amount ──
                      Text(
                        l10n.amount,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 0.8.h),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1.5,
                          ),
                        ),
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: updateExpenseController,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 3.w,
                              vertical: 1.8.h,
                            ),
                            prefixIcon: const Icon(
                              Icons.payments_outlined,
                              color: AppColors.primaryColor,
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
                      ),
                      SizedBox(height: 2.h),

                      // ── Date ──
                      Text(
                        l10n.date,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 0.8.h),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1.5,
                          ),
                        ),
                        child: TextFormField(
                          controller: dateController,
                          readOnly: true,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 3.w,
                              vertical: 1.8.h,
                            ),
                            prefixIcon: const Icon(
                              Icons.calendar_month_outlined,
                              color: AppColors.primaryColor,
                            ),
                          ),
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n.pleaseSelectDate;
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 4.h),

                      // ── Update Button ──
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            padding: EdgeInsets.symmetric(vertical: 2.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 4,
                            shadowColor: AppColors.primaryColor.withValues(alpha: 
                              0.4,
                            ),
                          ),
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              try {
                                await onUpdate(
                                  id,
                                  ExpenseDataModel(
                                    id: id,
                                    name: selectedValue ?? categoryName,
                                    date: dateController.text.trim(),
                                    expense: int.parse(
                                      updateExpenseController.text.trim(),
                                    ),
                                  ),
                                );
                                if (context.mounted) Navigator.pop(context);
                                Fluttertoast.showToast(
                                  msg: msg,
                                  backgroundColor: AppColors.primaryColor,
                                );
                              } catch (e) {
                                debugPrint('Error updating expense: $e');
                              }
                            }
                          },
                          child: Text(
                            l10n.updateExpense,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
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
