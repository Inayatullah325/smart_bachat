import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:smart_bachat/core/constant_colors.dart';
import 'package:smart_bachat/l10n/app_localizations.dart';

/// A reusable confirmation dialog used across the app for delete/update confirmations.
/// This replaces the duplicated dialog code that was in home_screen, all_expenses_screen,
/// and income_screen.
///
/// Usage:
/// ```dart
/// showConfirmationDialog(
///   context: context,
///   message: 'Do you really want to delete this record?',
///   onConfirm: () async {
///     await provider.deleteExpense(id);
///   },
/// );
/// ```
Future<void> showConfirmationDialog({
  required BuildContext context,
  required String message,
  required Future<void> Function() onConfirm,
  String? title,
  String? confirmText,
  String? cancelText,
  Color? confirmColor,
  Color? cancelColor,
  List<Color>? gradientColors,
}) {
  final l10n = AppLocalizations.of(context)!;
  final displayTitle = title ?? l10n.appTitle;
  final displayConfirm = confirmText ?? l10n.yes;
  final displayCancel = cancelText ?? l10n.no;
  final displayConfirmColor = confirmColor ?? AppColors.expenseColor;
  final displayCancelColor = cancelColor ?? AppColors.incomeColor;
  final displayGradient =
      gradientColors ?? [AppColors.primaryColor, AppColors.buttonsColor];

  return showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.3,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: displayGradient),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: Row(
                children: [
                  Text(
                    displayTitle,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      message,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              child: const Divider(thickness: 2, color: Colors.white),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.0.h),
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.05,
                      width: MediaQuery.of(context).size.width * 0.3,
                      decoration: BoxDecoration(
                        color: displayCancelColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          displayCancel,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.0.h),
                  child: InkWell(
                    onTap: () async {
                      Navigator.pop(context);
                      await onConfirm();
                    },
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.05,
                      width: MediaQuery.of(context).size.width * 0.3,
                      decoration: BoxDecoration(
                        color: displayConfirmColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          displayConfirm,
                          style: TextStyle(
                            fontSize: 18.sp,
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
          ],
        ),
      ),
    ),
  );
}
