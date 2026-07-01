import 'package:flutter/material.dart';

@immutable
class AppColors {
  // Reverting to the original Light Blue color scheme while keeping keys for UI compatibility
  static const Color background = Color(0xffffffff);
  static const Color surface = Color(0xfff5f5f5);
  static const Color accent = Color(0xff27aae1); // Original Blue

  static const Color primaryColor = Color(0xff27aae1);
  static const Color secondaryColor = Color(0xff566D7E);
  static const Color buttonsColor = Color(0xff1DC3F7);

  static const Color incomeColor = Color(0xff00A86B);
  static const Color expenseColor = Color(0xffFD3C4A);

  static const Color textPrimary = Color(0xff000000);
  static const Color textSecondary = Color(0xff566D7E);

  static const Color color_green = incomeColor;
  static const Color color_red = expenseColor;

  static const Map<String, Color> categoryColors = {
    'Groceries': Color(0xff27aae1),
    'Health': Color(0xffFD3C4A),
    'Education': Color(0xffC77DFF),
    'Transport': Color(0xffFFD93D),
    'Bills': Color(0xff1DC3F7),
    'Rent': Color(0xff00A86B),
    'Salaries': Color(0xff4D96FF),
    'Charity': Color(0xff6BCB77),
    'Shopping': Color(0xffFF6B6B),
    'Maintenance': Color(0xff566D7E),
    'Household': Color(0xffA0522D),
    'Pets': Color(0xffFF9A3C),
    'Sports': Color(0xff00CED1),
    'Entertainment': Color(0xffFF1493),
    'Gifts': Color(0xffFFD700),
    'Vacations': Color(0xff1E90FF),
    'Restaurant': Color(0xffFF4500),
    'Others': Color(0xff808080),
  };

  static Color getCategoryColor(String name) {
    return categoryColors[name] ?? Colors.grey;
  }
}
