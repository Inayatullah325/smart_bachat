import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:smart_bachat/core/constant_colors.dart';
import 'package:smart_bachat/ui/screens/ui/all_categories_screen/all_categories_screen.dart';
import 'package:smart_bachat/ui/screens/ui/all_expenses_screen/all_expenses_screen.dart';
import 'package:smart_bachat/ui/screens/ui/home_screen/home_screen.dart';
import 'package:smart_bachat/ui/screens/ui/income_screen/income_screen.dart';
import 'package:smart_bachat/ui/screens/ui/reports_screen/reports_screen.dart';

class MyBottomBar extends StatefulWidget {
  const MyBottomBar({super.key});

  @override
  State<MyBottomBar> createState() => _MyBottomBarState();
}

class _MyBottomBarState extends State<MyBottomBar> {
  final objColor = AppColors();

  int selectedIndex = 0;
  List<Widget> screens = [
    HomeScreen(),
    IncomeScreen(),
    AllExpensesScreen(),
    AllCategoriesScreen(),
    ReportsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: SalomonBottomBar(
        backgroundColor: AppColors.primaryColor,
        currentIndex: selectedIndex,
        onTap: (i) => setState(() => selectedIndex = i),
        items: [
          /// Home
          SalomonBottomBarItem(
            icon: Icon(Icons.home_outlined, color: Colors.white, size: 5.w),
            title: Text("Home", style: TextStyle(fontSize: 14.sp)),
            selectedColor: Colors.white,
          ),

          /// Income
          SalomonBottomBarItem(
            icon: Icon(
              Icons.account_balance_wallet_outlined,
              color: Colors.white,
              size: 5.w,
            ),
            title: Text("Income", style: TextStyle(fontSize: 14.sp)),
            selectedColor: Colors.white,
          ),

          /// Expenses
          SalomonBottomBarItem(
            icon: Icon(
              Icons.credit_score_outlined,
              color: Colors.white,
              size: 5.w,
            ),
            title: Text("Expenses", style: TextStyle(fontSize: 14.sp)),
            selectedColor: Colors.white,
          ),

          /// Categories
          SalomonBottomBarItem(
            icon: Icon(Icons.category_outlined, color: Colors.white, size: 5.w),
            title: Text("Categories", style: TextStyle(fontSize: 14.sp)),
            selectedColor: Colors.white,
          ),

          /// Statistics
          SalomonBottomBarItem(
            icon: Icon(Icons.bar_chart_sharp, color: Colors.white, size: 5.w),
            title: Text("Statistics", style: TextStyle(fontSize: 14.sp)),
            selectedColor: Colors.white,
          ),
        ],
      ),

      body: Center(child: screens[selectedIndex]),
    );
  }
}
