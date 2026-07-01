import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

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
  String title = 'Smart Bachat',
  String confirmText = 'Yes',
  String cancelText = 'No',
  Color confirmColor = Colors.red,
  Color cancelColor = Colors.green,
  List<Color> gradientColors = const [Colors.blue, Colors.lightBlueAccent],
}) {
  return showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.3,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradientColors),
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
                    title,
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
                        color: cancelColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          cancelText,
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
                        color: confirmColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          confirmText,
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
