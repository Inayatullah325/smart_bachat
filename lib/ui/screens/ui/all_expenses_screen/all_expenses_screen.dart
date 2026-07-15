import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:smart_bachat/providers/settings_provider.dart';
import '../../../../core/constant_colors.dart';
import '../../../../database_model_class/expense_data_model.dart';
import 'package:smart_bachat/providers/transaction_provider.dart';
import 'package:smart_bachat/ui/components/transaction_item.dart';

import 'package:smart_bachat/core/app_utils.dart';
import 'package:smart_bachat/ui/components/dialogs/confirmation_dialog.dart';
import 'package:smart_bachat/ui/components/dialogs/update_expense_dialog.dart';
import 'package:smart_bachat/l10n/app_localizations.dart';

class AllExpensesScreen extends StatefulWidget {
  const AllExpensesScreen({super.key});

  @override
  State<AllExpensesScreen> createState() => _AllExpensesScreenState();
}

class _AllExpensesScreenState extends State<AllExpensesScreen> {
  // Expanded state trackers
  final Set<String> _expandedMonthKeys = {}; // "yyyy-MM"
  final Set<int> _expandedYears = {}; // year numbers for prev-year section

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransactionProvider>(
        context,
        listen: false,
      ).fetchAllExpenses();
    });
  }

  Map<String, List<ExpenseDataModel>> _groupByMonth(
    List<ExpenseDataModel> list,
  ) {
    final Map<String, List<ExpenseDataModel>> map = {};
    for (final item in list) {
      final parts = item.date.split('-'); // dd-MM-yyyy
      if (parts.length == 3) {
        final key = '${parts[2]}-${parts[1]}'; // yyyy-MM
        map.putIfAbsent(key, () => []).add(item);
      }
    }
    final sorted = map.keys.toList()..sort((a, b) => b.compareTo(a));
    return {for (var k in sorted) k: map[k]!};
  }

  Widget _sectionLabel(String text, Color textColor, Color bgColor) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.h, top: 0.5.h),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w800,
          color: textColor,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _yearAccordion(
    int year,
    List<String> monthKeys,
    Map<String, List<ExpenseDataModel>> grouped,
    int yearTotal,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final currencySymbol = Provider.of<SettingsProvider>(
      context,
    ).currencySymbol;
    final isExpanded = _expandedYears.contains(year);
    final monthWord = monthKeys.length == 1 ? l10n.monthText : l10n.monthsText;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: const Color(0xffEEF2F5),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff566D7E).withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Year Header
          InkWell(
            onTap: () => setState(
              () => isExpanded
                  ? _expandedYears.remove(year)
                  : _expandedYears.add(year),
            ),
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(20),
              bottom: isExpanded ? Radius.zero : const Radius.circular(20),
            ),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
              decoration: BoxDecoration(
                color: const Color(0xffEEF2F5),
                borderRadius: BorderRadius.vertical(
                  top: const Radius.circular(20),
                  bottom: isExpanded ? Radius.zero : const Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xffE2E8F0), // slate 200
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.calendar_today,
                      color: Color(0xff475569), // slate 600
                      size: 18,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${l10n.yearText} $year',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff1E293B), // slate 800
                          ),
                        ),
                        Text(
                          '${monthKeys.length} $monthWord  •  $currencySymbol${AppUtils.formatCurrency(yearTotal)}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xff475569), // slate 600
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: const Icon(
                      Icons.expand_more_rounded,
                      color: Color(0xff1E293B), // slate 800
                      size: 26,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Expandable Month Cards
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
              child: Column(
                children: monthKeys.map((k) {
                  final items = grouped[k]!;
                  return _monthAccordion(
                    k,
                    items,
                    _prevYearTheme,
                    compact: true,
                  );
                }).toList(),
              ),
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _monthAccordion(
    String key,
    List<ExpenseDataModel> items,
    _MonthTheme theme, {
    bool compact = false,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final currencySymbol = Provider.of<SettingsProvider>(
      context,
    ).currencySymbol;
    final isExpanded = _expandedMonthKeys.contains(key);
    final total = items.fold<int>(0, (s, e) => s + e.expense);
    final recordWord = items.length == 1 ? l10n.recordText : l10n.recordsText;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.only(bottom: compact ? 1.h : 2.h),
      decoration: BoxDecoration(
        color: const Color(0xffEEF2F5),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: theme.accentColor.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Month Header
          InkWell(
            onTap: () => setState(
              () => isExpanded
                  ? _expandedMonthKeys.remove(key)
                  : _expandedMonthKeys.add(key),
            ),
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(18),
              bottom: isExpanded ? Radius.zero : const Radius.circular(18),
            ),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
              decoration: BoxDecoration(
                color: theme.headerBg,
                borderRadius: BorderRadius.vertical(
                  top: const Radius.circular(18),
                  bottom: isExpanded ? Radius.zero : const Radius.circular(18),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: theme.badgeBg,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(
                      Icons.calendar_month_rounded,
                      color: theme.iconColor,
                      size: 16,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppUtils.monthNameFromKey(key, context: context),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: theme.textPrimary,
                          ),
                        ),
                        Text(
                          '${items.length} $recordWord  •  $currencySymbol${AppUtils.formatCurrency(total)}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: theme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.expand_more_rounded,
                      color: theme.textPrimary,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Expense entries using SlidableTransactionItem
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
              child: Column(
                children: items.asMap().entries.map((entry) {
                  return _buildItemWidget(entry.value, entry.key);
                }).toList(),
              ),
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  static const _currentMonthTheme = _MonthTheme(
    headerBg: Color(0xffEEF2F5),
    textPrimary: Color(0xff1E293B),
    textSecondary: Color(0xff64748B),
    badgeBg: Color(0xffDDE3EA),
    iconColor: Color(0xff475569),
    accentColor: Color(0xff475569),
  );

  static const _currentYearTheme = _MonthTheme(
    headerBg: Color(0xffEEF2F5),
    textPrimary: Color(0xff1E293B),
    textSecondary: Color(0xff64748B),
    badgeBg: Color(0xffDDE3EA),
    iconColor: Color(0xff475569),
    accentColor: Color(0xff475569),
  );

  static const _prevYearTheme = _MonthTheme(
    headerBg: Color(0xffEEF2F5),
    textPrimary: Color(0xff1E293B),
    textSecondary: Color(0xff64748B),
    badgeBg: Color(0xffDDE3EA),
    iconColor: Color(0xff475569),
    accentColor: Color(0xff475569),
  );

  Widget _buildItemWidget(ExpenseDataModel transaction, int index) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: SlidableTransactionItem(
        transaction: transaction,
        index: index,
        onTap: () {},
        onDelete: () {
          showConfirmationDialog(
            context: context,
            message: l10n.deleteExpenseConfirm,
            onConfirm: () async {
              await Provider.of<TransactionProvider>(
                context,
                listen: false,
              ).deleteExpense(transaction.id!);
              if (mounted) {
                Fluttertoast.showToast(
                  msg: l10n.recordDeleted,
                  backgroundColor: AppColors.color_red,
                );
              }
            },
          );
        },
        onUpdate: () {
          showConfirmationDialog(
            context: context,
            message: l10n.editExpenseConfirm,
            onConfirm: () async {
              showUpdateExpenseDialog(
                context: context,
                id: transaction.id!,
                categoryName: transaction.name,
                date: transaction.date,
                expense: transaction.expense,
                onUpdate: (id, model) async {
                  await Provider.of<TransactionProvider>(
                    context,
                    listen: false,
                  ).updateExpense(id, model);
                },
                successMessage: l10n.updatedSuccessfully,
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          l10n.allExpensesTitle,
          style: TextStyle(
            fontSize: 19.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
      ),
      body: transactionProvider.isLoadingExpenses
          ? Center(
              child: CircleAvatar(
                radius: 35,
                backgroundColor: AppColors.primaryColor.withValues(alpha: 0.12),
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
          : transactionProvider.expenses.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primaryColor.withValues(alpha: 0.12),
                    child: const Icon(
                      Icons.credit_card_off_rounded,
                      color: AppColors.primaryColor,
                      size: 38,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noData,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : _buildExpenseList(transactionProvider.expenses),
    );
  }

  Widget _buildExpenseList(List<ExpenseDataModel> expenses) {
    final l10n = AppLocalizations.of(context)!;
    final grouped = _groupByMonth(expenses);
    final now = DateTime.now();
    final currentKey = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final currentYearPrefix = '${now.year}-';

    final List<String> currentMonthKeys = [];
    final List<String> currentYearKeys = [];
    final Map<int, List<String>> prevYearsMap = {};

    for (final key in grouped.keys) {
      if (key == currentKey) {
        currentMonthKeys.add(key);
      } else if (key.startsWith(currentYearPrefix)) {
        currentYearKeys.add(key);
      } else {
        final year = int.tryParse(key.split('-')[0]) ?? 0;
        prevYearsMap.putIfAbsent(year, () => []).add(key);
      }
    }

    final sortedPrevYears = prevYearsMap.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    final List<Widget> widgets = [];

    // ── Current Month Section ──
    if (currentMonthKeys.isNotEmpty) {
      widgets.add(
        _sectionLabel(
          '🌟 ${l10n.currentMonth}',
          const Color(0xff0E7BB0), // primary dark
          const Color(0xffE0F4FC), // primary light tint
        ),
      );
      for (final k in currentMonthKeys) {
        widgets.add(_monthAccordion(k, grouped[k]!, _currentMonthTheme));
      }
    }

    // ── This Year Section ──
    if (currentYearKeys.isNotEmpty) {
      widgets.add(
        _sectionLabel(
          '📅 ${l10n.thisYear} (${now.year})',
          const Color(0xff0E7BB0),
          const Color(0xffE0F4FC),
        ),
      );
      for (final k in currentYearKeys) {
        widgets.add(_monthAccordion(k, grouped[k]!, _currentYearTheme));
      }
    }

    // ── Previous Years Section ──
    if (prevYearsMap.isNotEmpty) {
      widgets.add(
        _sectionLabel(
          '🗂️ ${l10n.prevYears}',
          const Color(0xff0E7BB0),
          const Color(0xffE0F4FC),
        ),
      );
      for (final year in sortedPrevYears) {
        final monthKeys = prevYearsMap[year]!;
        final yearTotal = monthKeys.fold<int>(0, (sum, k) {
          return sum + grouped[k]!.fold<int>(0, (s, e) => s + e.expense);
        });
        widgets.add(_yearAccordion(year, monthKeys, grouped, yearTotal));
      }
    }

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      children: widgets,
    );
  }
}

class _MonthTheme {
  final Color headerBg;
  final Color textPrimary;
  final Color textSecondary;
  final Color badgeBg;
  final Color iconColor;
  final Color accentColor;

  const _MonthTheme({
    required this.headerBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.badgeBg,
    required this.iconColor,
    required this.accentColor,
  });
}
