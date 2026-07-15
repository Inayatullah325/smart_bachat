import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:smart_bachat/core/app_utils.dart';
import 'package:smart_bachat/l10n/app_localizations.dart';
import 'package:smart_bachat/providers/settings_provider.dart';

/// Shared accordion list for income/expense screens.
/// Groups transactions by current month, this year, and previous years.
class GroupedTransactionList<T> extends StatefulWidget {
  const GroupedTransactionList({
    super.key,
    required this.items,
    required this.getDate,
    required this.getAmount,
    required this.itemBuilder,
  });

  final List<T> items;
  final String Function(T item) getDate;
  final int Function(T item) getAmount;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  @override
  State<GroupedTransactionList<T>> createState() =>
      _GroupedTransactionListState<T>();
}

class _GroupedTransactionListState<T> extends State<GroupedTransactionList<T>> {
  final Set<String> _expandedMonthKeys = {};
  final Set<int> _expandedYears = {};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final grouped = AppUtils.groupByMonth(widget.items, widget.getDate);
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

    final List<Widget> children = [];

    if (currentMonthKeys.isNotEmpty) {
      children.add(_sectionLabel('🌟 ${l10n.currentMonth}'));
      for (final key in currentMonthKeys) {
        children.add(_monthAccordion(key, grouped[key]!, _monthTheme));
      }
    }

    if (currentYearKeys.isNotEmpty) {
      children.add(_sectionLabel('📅 ${l10n.thisYear} (${now.year})'));
      for (final key in currentYearKeys) {
        children.add(_monthAccordion(key, grouped[key]!, _monthTheme));
      }
    }

    if (prevYearsMap.isNotEmpty) {
      children.add(_sectionLabel('🗂️ ${l10n.prevYears}'));
      for (final year in sortedPrevYears) {
        final monthKeys = prevYearsMap[year]!;
        final yearTotal = monthKeys.fold<int>(0, (sum, key) {
          return sum +
              grouped[key]!.fold<int>(
                0,
                (s, item) => s + widget.getAmount(item),
              );
        });
        children.add(_yearAccordion(year, monthKeys, grouped, yearTotal));
      }
    }

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      children: children,
    );
  }

  Widget _sectionLabel(String text) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.h, top: 0.5.h),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: const Color(0xffE0F4FC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w800,
          color: const Color(0xff0E7BB0),
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _yearAccordion(
    int year,
    List<String> monthKeys,
    Map<String, List<T>> grouped,
    int yearTotal,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final currencySymbol = settingsProvider.currencySymbol;
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
                      color: const Color(0xffE2E8F0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.calendar_today,
                      color: Color(0xff475569),
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
                            color: Color(0xff1E293B),
                          ),
                        ),
                        Text(
                          '${monthKeys.length} $monthWord  •  $currencySymbol${AppUtils.formatCurrency(yearTotal)}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xff475569),
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
                      color: Color(0xff1E293B),
                      size: 26,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
              child: Column(
                children: monthKeys
                    .map(
                      (key) => _monthAccordion(
                        key,
                        grouped[key]!,
                        _monthTheme,
                        compact: true,
                      ),
                    )
                    .toList(),
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
    List<T> items,
    _MonthTheme theme, {
    bool compact = false,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final currencySymbol = settingsProvider.currencySymbol;
    final isExpanded = _expandedMonthKeys.contains(key);
    final total = items.fold<int>(
      0,
      (sum, item) => sum + widget.getAmount(item),
    );
    final recordWord = items.length == 1 ? l10n.recordText : l10n.recordsText;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.only(bottom: compact ? 1.h : 2.h),
      decoration: BoxDecoration(
        color: const Color(0xffEEF2F5),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: theme.accentColor.withValues(alpha: compact ? 0.1 : 0.12),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
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
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
              child: Column(
                children: items.asMap().entries.map((entry) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 1.h),
                    child: widget.itemBuilder(context, entry.value, entry.key),
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

  static const _monthTheme = _MonthTheme(
    headerBg: Color(0xffEEF2F5),
    textPrimary: Color(0xff1E293B),
    textSecondary: Color(0xff64748B),
    badgeBg: Color(0xffDDE3EA),
    iconColor: Color(0xff475569),
    accentColor: Color(0xff475569),
  );
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
