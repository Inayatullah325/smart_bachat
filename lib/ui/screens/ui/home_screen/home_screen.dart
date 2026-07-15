import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:smart_bachat/core/constant_colors.dart';
import 'package:smart_bachat/l10n/app_localizations.dart';

import 'package:smart_bachat/providers/home_provider.dart';
import 'package:smart_bachat/providers/settings_provider.dart';
import 'package:smart_bachat/ui/components/transaction_item.dart';
import 'package:smart_bachat/ui/screens/ui/all_categories_screen/all_categories_screen.dart';
import 'package:smart_bachat/ui/screens/ui/all_expenses_screen/all_expenses_screen.dart';
import 'package:smart_bachat/ui/screens/ui/navigation_drawer/navigation_drawer.dart';

import 'package:smart_bachat/core/app_utils.dart';
import 'package:smart_bachat/ui/screens/ui/notifications_screen/notifications_screen.dart';
import 'package:smart_bachat/ui/components/dialogs/confirmation_dialog.dart';
import 'package:smart_bachat/ui/components/dialogs/update_expense_dialog.dart';
import 'package:smart_bachat/ui/components/dialogs/add_income_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  bool _isFABOpen = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HomeProvider>(context, listen: false).fetchHomeData();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleFAB() {
    setState(() {
      _isFABOpen = !_isFABOpen;
      if (_isFABOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = Provider.of<HomeProvider>(context);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.background,
          drawer: const MyNavigationDrawer(),
          appBar: _buildAppBar(),
          body: homeProvider.isLoading
              ? Center(
                  child: CircleAvatar(
                    radius: 35,
                    backgroundColor: AppColors.primaryColor.withValues(
                      alpha: 0.12,
                    ),
                    child: const SizedBox(
                      width: 35,
                      height: 35,
                      child: CircularProgressIndicator(
                        color: AppColors.primaryColor,
                        strokeWidth: 3,
                      ),
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async => homeProvider.fetchHomeData(),
                  color: AppColors.accent,
                  backgroundColor: AppColors.surface,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 2.h),
                          _buildDynamicHeroCard(homeProvider),
                          SizedBox(height: 3.h),
                          // Current Month Summary Card - only shown if data exists for the current month
                          if (homeProvider.hasCurrentMonthData) ...[
                            _buildCurrentMonthCard(homeProvider),
                            SizedBox(height: 3.h),
                          ],
                          _buildQuickAnalytics(homeProvider),
                          SizedBox(height: 4.h),
                          _buildSectionHeader(
                            AppLocalizations.of(context)!.recentTransactions,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AllExpensesScreen(),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 1.5.h),
                          _buildSmartTransactionList(homeProvider),
                          SizedBox(height: 15.h),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
        // Global Background Dimming
        if (_isFABOpen)
          GestureDetector(
            onTap: _toggleFAB,
            child: Container(
              color: Colors.black.withValues(alpha: 0.5),
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        // Centralized FAB - Always rendered here, above everything
        Positioned(right: 16, bottom: 16, child: _buildAnimatedSpeedDial()),
      ],
    );
  }

  Widget _buildAnimatedSpeedDial() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Add Income
        _buildSpeedDialItem(
          label: AppLocalizations.of(context)!.addIncomeLabel,
          icon: Icons.account_balance_wallet_rounded,
          color: const Color(0xFF00C2FF),
          onTap: () {
            _toggleFAB();
            showAddIncomeDialog(
              context: context,
              onAdd: (model) async {
                await Provider.of<HomeProvider>(
                  context,
                  listen: false,
                ).addIncome(model);
              },
              successMessage: AppLocalizations.of(context)!.successIncomeAdded,
            );
          },
        ),
        if (_isFABOpen) const SizedBox(height: 12),
        // Add Expense
        _buildSpeedDialItem(
          label: AppLocalizations.of(context)!.addExpenseLabel,
          icon: Icons.credit_card_rounded,
          color: const Color(0xFFFF4867),
          onTap: () async {
            _toggleFAB();
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AllCategoriesScreen()),
            );
            if (mounted) {
              Provider.of<HomeProvider>(context, listen: false).fetchHomeData();
            }
          },
        ),
        if (_isFABOpen) const SizedBox(height: 16),
        // Main Toggle Button
        GestureDetector(
          onTap: _toggleFAB,
          child: Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: _isFABOpen
                  ? const Icon(
                      Icons.calendar_month_rounded,
                      key: ValueKey('open'),
                      color: Colors.white,
                      size: 30,
                    )
                  : const Icon(
                      Icons.add,
                      key: ValueKey('closed'),
                      color: Colors.white,
                      size: 30,
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpeedDialItem({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizeTransition(
      sizeFactor: _expandAnimation,
      child: FadeTransition(
        opacity: _expandAnimation,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Label Box
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontSize: 15.sp,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Squircle Icon Button
              GestureDetector(
                onTap: onTap,
                child: Container(
                  height: 58, // Precise size to match image
                  width: 58,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(
                      18,
                    ), // Squircle-like shape
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primaryColor,
      elevation: 0,
      centerTitle: true,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.grid_view_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: Column(
        children: [
          Text(
            AppLocalizations.of(context)!.appTitle,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            AppLocalizations.of(context)!.personalFinanceManager,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            );
          },
          icon: Stack(
            children: [
              const Icon(
                Icons.notifications_outlined,
                color: Colors.white,
                size: 26,
              ),
              Positioned(
                right: 2,
                top: 2,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 2.w),
      ],
    );
  }

  Widget _buildDynamicHeroCard(HomeProvider provider) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accent,
            AppColors.accent.withValues(alpha: 0.85),
            AppColors.primaryColor.withValues(alpha: 0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: -2,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              Icons.account_balance_wallet_rounded,
              size: 150,
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(7.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.totalAvailableBalance,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 0.8.h),
                        Text(
                          '${settingsProvider.currencySymbol}${AppUtils.formatCurrency(provider.balance)}',
                          style: const TextStyle(
                            fontSize: 26,
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        settingsProvider.currencyCode,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Expanded(
                      child: _buildHeroStat(
                        label:
                            '${DateTime.now().year} ${AppLocalizations.of(context)!.yearIncome}',
                        amount: provider.currentYearIncome,
                        icon: Icons.arrow_downward_rounded,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                    Expanded(
                      child: _buildHeroStat(
                        label:
                            '${DateTime.now().year} ${AppLocalizations.of(context)!.yearSaving}',
                        amount: provider.currentYearBalance,
                        icon: Icons.savings_rounded,
                        color: Colors.white,
                        amountColor: provider.currentYearBalance < 0
                            ? const Color(0xFFFF4867)
                            : Colors.white,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                    Expanded(
                      child: _buildHeroStat(
                        label:
                            '${DateTime.now().year} ${AppLocalizations.of(context)!.yearExpenses}',
                        amount: provider.currentYearExpense,
                        icon: Icons.arrow_upward_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStat({
    required String label,
    required int amount,
    required IconData icon,
    required Color color,
    Color? amountColor,
  }) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 1.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 13),
              SizedBox(width: 1.w),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          SizedBox(height: 0.5.h),
          Text(
            '${settingsProvider.currencySymbol}${AppUtils.formatCurrency(amount)}',
            style: TextStyle(
              fontSize: 13,
              color: amountColor ?? Colors.white,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentMonthCard(HomeProvider provider) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final monthName = AppUtils.monthNameFromKey(
      '${now.year}-${now.month.toString().padLeft(2, '0')}',
      context: context,
    );
    final saving = provider.currentMonthBalance;
    final savingColor = saving >= 0
        ? AppColors.incomeColor
        : AppColors.expenseColor;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xffEEF2F5), // light cool grey
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with background color
          Container(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.calendar_today_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          monthName,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          l10n.currentMonthSummary,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.white.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    settingsProvider.currencyCode,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.all(5.w),
            child: Column(
              children: [
                // Income & Expense Row
                Row(
                  children: [
                    Expanded(
                      child: _buildMonthStatItem(
                        label: l10n.income,
                        amount: provider.currentMonthIncome,
                        icon: Icons.arrow_downward_rounded,
                        color: AppColors.incomeColor,
                        bgColor: AppColors.incomeColor.withValues(alpha: 0.1),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Container(
                      width: 1,
                      height: 50,
                      color: Colors.black.withValues(alpha: 0.05),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: _buildMonthStatItem(
                        label: l10n.expenses,
                        amount: provider.currentMonthExpense,
                        icon: Icons.arrow_upward_rounded,
                        color: AppColors.expenseColor,
                        bgColor: AppColors.expenseColor.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                // Savings Row
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 4.w,
                    vertical: 1.2.h,
                  ),
                  decoration: BoxDecoration(
                    color: savingColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            saving >= 0
                                ? Icons.savings_rounded
                                : Icons.warning_amber_rounded,
                            color: savingColor,
                            size: 20,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            saving >= 0
                                ? l10n.thisMonthSaving
                                : l10n.overBudget,
                            style: TextStyle(
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.w800,
                              color: savingColor,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${settingsProvider.currencySymbol}${AppUtils.formatCurrency(saving.abs())}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w900,
                          color: savingColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthStatItem({
    required String label,
    required int amount,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        SizedBox(height: 1.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.5.sp,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 0.3.h),
        Text(
          '${settingsProvider.currencySymbol}${AppUtils.formatCurrency(amount)}',
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAnalytics(HomeProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    final subtitle = provider.usesCurrentMonthForAnalytics
        ? l10n.thisMonth
        : l10n.overall;

    return Row(
      children: [
        Expanded(
          child: _buildModernAnalysisCard(
            title: l10n.quickAnalyticsSavings,
            ratio: provider.savingsRatio,
            color: AppColors.incomeColor,
            subtitle: subtitle,
          ),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: _buildModernAnalysisCard(
            title: l10n.quickAnalyticsSpending,
            ratio: provider.spendingRatio,
            color: AppColors.expenseColor,
            subtitle: subtitle,
          ),
        ),
      ],
    );
  }

  Widget _buildModernAnalysisCard({
    required String title,
    required double ratio,
    required Color color,
    required String subtitle,
  }) {
    int percentage = (ratio * 100).round().clamp(0, 100);
    return Container(
      padding: EdgeInsets.all(3.5.w),
      decoration: BoxDecoration(
        color: const Color(0xffEEF2F5), // light cool grey
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(
                Icons.more_horiz_rounded,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
                size: 18,
              ),
            ],
          ),
          SizedBox(height: 1.5.h),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 50,
                width: 50,
                child: CircularProgressIndicator(
                  value: ratio.clamp(0.0, 1.0),
                  backgroundColor: color.withValues(alpha: 0.1),
                  color: color,
                  strokeWidth: 5,
                  strokeCap: StrokeCap.round,
                ),
              ),
              Text(
                '$percentage%',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.5.h),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12.sp,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onSeeAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: 0.2,
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(50, 30),
          ),
          child: Row(
            children: [
              Text(
                AppLocalizations.of(context)!.seeAll,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.accent,
                size: 20,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSmartTransactionList(HomeProvider provider) {
    if (provider.recentExpenses.isEmpty) {
      return Container(
        height: 150,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long_rounded,
                color: AppColors.textSecondary.withValues(alpha: 0.3),
                size: 40,
              ),
              SizedBox(height: 1.h),
              Text(
                AppLocalizations.of(context)!.noActivityYet,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.recentExpenses.length,
      itemBuilder: (context, index) {
        final transaction = provider.recentExpenses[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 1.5.h),
          child: SlidableTransactionItem(
            transaction: transaction,
            index: index,
            onTap: () {
              // Do nothing on tap as per user request
            },
            onDelete: () {
              showConfirmationDialog(
                context: context,
                message: AppLocalizations.of(context)!.deleteRecordConfirm,
                onConfirm: () async {
                  final recordDeletedMsg = AppLocalizations.of(
                    context,
                  )!.recordDeleted;
                  await Provider.of<HomeProvider>(
                    context,
                    listen: false,
                  ).deleteExpense(transaction.id!);
                  Fluttertoast.showToast(
                    msg: recordDeletedMsg,
                    backgroundColor: AppColors.expenseColor,
                  );
                },
              );
            },
            onUpdate: () {
              showConfirmationDialog(
                context: context,
                message: AppLocalizations.of(context)!.editTransactionConfirm,
                onConfirm: () async {
                  showUpdateExpenseDialog(
                    context: context,
                    id: transaction.id!,
                    categoryName: transaction.name,
                    date: transaction.date,
                    expense: transaction.expense,
                    onUpdate: (id, model) async {
                      await Provider.of<HomeProvider>(
                        context,
                        listen: false,
                      ).updateExpense(id, model);
                    },
                    successMessage: AppLocalizations.of(context)!.recordUpdated,
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
