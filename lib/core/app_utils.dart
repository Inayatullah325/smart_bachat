import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_bachat/core/constant_colors.dart';

/// Shared utility functions used across the application.
/// This file centralizes common logic that was previously duplicated
/// in multiple screen files (home_screen, all_expenses_screen, income_screen, etc).

class AppUtils {
  AppUtils._(); // Prevent instantiation

  // ─── Month Names ───
  static const List<String> monthNames = [
    '',
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  // ─── Currency Formatting ───
  /// Formats an integer amount into a comma-separated string.
  /// Example: 1234567 → "1,234,567"
  static String formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => "${m[1]},",
    );
  }

  // ─── Month Name from Key ───
  /// Converts a "yyyy-MM" key to a readable month name.
  /// Example: "2026-06" → "June 2026"
  static String monthNameFromKey(String key) {
    final parts = key.split('-');
    if (parts.length != 2) return key;
    final month = int.tryParse(parts[1]) ?? 0;
    final year = parts[0];
    return month >= 1 && month <= 12 ? '${monthNames[month]} $year' : key;
  }

  // ─── Transaction Grouping ───
  /// Groups items by month key "yyyy-MM" from a "dd-MM-yyyy" date string.
  /// Returns keys sorted newest first.
  static Map<String, List<T>> groupByMonth<T>(
    List<T> items,
    String Function(T item) getDate,
  ) {
    final Map<String, List<T>> map = {};
    for (final item in items) {
      final parts = getDate(item).split('-');
      if (parts.length == 3) {
        final key = '${parts[2]}-${parts[1]}';
        map.putIfAbsent(key, () => []).add(item);
      }
    }
    final sorted = map.keys.toList()..sort((a, b) => b.compareTo(a));
    return {for (final k in sorted) k: map[k]!};
  }

  // ─── Date Picker ───
  /// Shows a date picker and returns the selected date formatted as "dd-MM-yyyy".
  /// Returns null if the user cancels.
  static Future<String?> selectDate(
    BuildContext context, {
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate: firstDate ?? DateTime(2020),
      lastDate: lastDate ?? now,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.accent,
              onPrimary: Colors.white,
              surface: AppColors.background,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      return DateFormat('dd-MM-yyyy').format(picked);
    }
    return null;
  }

  // ─── Categories List ───
  /// The master categories list used throughout the app.
  /// This is the single source of truth for category data.
  static const List<Map<String, dynamic>> allCategoriesList = [
    {
      'icon': Icons.fastfood_outlined,
      'name': 'Groceries',
      'value': 'Groceries',
      'color': Colors.orange,
    },
    {
      'icon': Icons.medical_information_outlined,
      'name': 'Health',
      'value': 'Health',
      'color': Colors.redAccent,
    },
    {
      'icon': Icons.menu_book_outlined,
      'name': 'Education',
      'value': 'Education',
      'color': Colors.blueAccent,
    },
    {
      'icon': Icons.directions_bus_outlined,
      'name': 'Transport',
      'value': 'Transport',
      'color': Colors.teal,
    },
    {
      'icon': Icons.lightbulb_circle_outlined,
      'name': 'Bills',
      'value': 'Bills',
      'color': Colors.amber,
    },
    {
      'icon': Icons.apartment_outlined,
      'name': 'Rent',
      'value': 'Rent',
      'color': Colors.indigo,
    },
    {
      'icon': Icons.credit_score_outlined,
      'name': 'Salaries',
      'value': 'Salaries',
      'color': Colors.green,
    },
    {
      'icon': Icons.volunteer_activism_outlined,
      'name': 'Charity',
      'value': 'Charity',
      'color': Colors.pink,
    },
    {
      'icon': Icons.shopping_cart_outlined,
      'name': 'Shopping',
      'value': 'Shopping',
      'color': Colors.purple,
    },
    {
      'icon': Icons.handyman_outlined,
      'name': 'Maintenance',
      'value': 'Maintenance',
      'color': Colors.brown,
    },
    {
      'icon': Icons.chair_outlined,
      'name': 'Household',
      'value': 'Household',
      'color': Colors.cyan,
    },
    {
      'icon': Icons.pets_outlined,
      'name': 'Pets',
      'value': 'Pets',
      'color': Colors.deepOrange,
    },
    {
      'icon': Icons.sports_tennis_outlined,
      'name': 'Sports',
      'value': 'Sports',
      'color': Colors.lightGreen,
    },
    {
      'icon': Icons.movie_filter_outlined,
      'name': 'Entertainment',
      'value': 'Entertainment',
      'color': Colors.deepPurple,
    },
    {
      'icon': Icons.card_giftcard_outlined,
      'name': 'Gifts',
      'value': 'Gifts',
      'color': Colors.red,
    },
    {
      'icon': Icons.beach_access,
      'name': 'Vacations',
      'value': 'Vacations',
      'color': Colors.lightBlue,
    },
    {
      'icon': Icons.restaurant_menu_outlined,
      'name': 'Restaurant',
      'value': 'Restaurant',
      'color': Colors.orangeAccent,
    },
    {
      'icon': Icons.note_alt_outlined,
      'name': 'Others',
      'value': 'Others',
      'color': Colors.blueGrey,
    },
  ];

  static IconData getCategoryIcon(String category) {
    for (final item in allCategoriesList) {
      if (item['name'] == category || item['value'] == category) {
        return item['icon'] as IconData;
      }
    }
    return Icons.more_horiz_rounded;
  }
}
