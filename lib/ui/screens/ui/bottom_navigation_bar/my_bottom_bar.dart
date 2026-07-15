import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:smart_bachat/core/constant_colors.dart';
import 'package:smart_bachat/providers/home_provider.dart';
import 'package:smart_bachat/ui/components/dialogs/add_income_dialog.dart';
import 'package:smart_bachat/ui/screens/ui/all_categories_screen/all_categories_screen.dart';
import 'package:smart_bachat/ui/screens/ui/all_expenses_screen/all_expenses_screen.dart';
import 'package:smart_bachat/ui/screens/ui/home_screen/home_screen.dart';
import 'package:smart_bachat/ui/screens/ui/income_screen/income_screen.dart';
import 'package:smart_bachat/ui/screens/ui/reports_screen/reports_screen.dart';
import 'package:smart_bachat/l10n/app_localizations.dart';

class MyBottomBar extends StatefulWidget {
  const MyBottomBar({super.key});

  @override
  State<MyBottomBar> createState() => _MyBottomBarState();
}

class _MyBottomBarState extends State<MyBottomBar>
    with SingleTickerProviderStateMixin {
  // ─── ORIGINAL LOGIC - UNCHANGED ──────────────────────────────────────────
  int selectedIndex = 0;

  final List<Widget> screens = const [
    HomeScreen(),
    IncomeScreen(),
    AllExpensesScreen(),
    AllCategoriesScreen(),
    ReportsScreen(),
  ];
  // ─────────────────────────────────────────────────────────────────────────

  bool _isFABOpen = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  late Animation<double> _fabRotate;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _fabRotate = Tween<double>(begin: 0.0, end: 0.375).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleFAB() {
    HapticFeedback.lightImpact();
    setState(() => _isFABOpen = !_isFABOpen);
    if (_isFABOpen) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _closeMenu() {
    if (_isFABOpen) {
      setState(() => _isFABOpen = false);
      _animationController.reverse();
    }
  }

  void _onNavTap(int index) {
    _closeMenu();
    if (index == selectedIndex) return;
    HapticFeedback.selectionClick();
    setState(() => selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final leftItems = [
      _NavItem(
        icon: Icons.home_rounded,
        outlinedIcon: Icons.home_outlined,
        label: l10n.home,
        index: 0,
      ),
      _NavItem(
        icon: Icons.account_balance_wallet_rounded,
        outlinedIcon: Icons.account_balance_wallet_outlined,
        label: l10n.income,
        index: 1,
      ),
    ];
    final rightItems = [
      _NavItem(
        icon: Icons.credit_card_rounded,
        outlinedIcon: Icons.credit_card_outlined,
        label: l10n.expenses,
        index: 2,
      ),
      _NavItem(
        icon: Icons.bar_chart_rounded,
        outlinedIcon: Icons.bar_chart_rounded,
        label: l10n.statistics,
        index: 4,
      ),
    ];

    return Stack(
      children: [
        // ── Main Scaffold ─────────────────────────────────────────────────
        Scaffold(
          extendBody: true,
          backgroundColor: AppColors.background,
          body: screens[selectedIndex],
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: _buildCenterFAB(),
          bottomNavigationBar: _buildNotchedBottomBar(leftItems, rightItems),
        ),

        // ── Backdrop dim ──────────────────────────────────────────────────
        if (_isFABOpen)
          FadeTransition(
            opacity: _expandAnimation,
            child: GestureDetector(
              onTap: _closeMenu,
              child: Container(
                color: Colors.black.withValues(alpha: 0.45),
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),

        // ── Speed-dial: close to FAB and centered horizontally ──
        Positioned(
          left: 30.w,
          right: 0,
          bottom: 16.h,
          child: IgnorePointer(
            ignoring: !_isFABOpen,
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Add Income
                  _buildSpeedDialItem(
                    label: l10n.addIncomeLabel,
                    icon: Icons.account_balance_wallet_rounded,
                    color: const Color(0xFF00C2FF),
                    onTap: () {
                      _closeMenu();
                      showAddIncomeDialog(
                        context: context,
                        onAdd: (model) async {
                          await Provider.of<HomeProvider>(
                            context,
                            listen: false,
                          ).addIncome(model);
                        },
                        successMessage: l10n.successIncomeAdded,
                      );
                    },
                  ),
                  if (_isFABOpen) const SizedBox(height: 14),

                  // Add Expense
                  _buildSpeedDialItem(
                    label: l10n.addExpenseLabel,
                    icon: Icons.credit_card_rounded,
                    color: const Color(0xFFFF4867),
                    onTap: () async {
                      final homeProvider = Provider.of<HomeProvider>(
                        context,
                        listen: false,
                      );
                      _closeMenu();
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AllCategoriesScreen(),
                        ),
                      );
                      if (mounted) homeProvider.fetchHomeData();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ───────────────────── SPEED DIAL ITEM (original design) ─────────────────

  Widget _buildSpeedDialItem({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizeTransition(
      sizeFactor: _expandAnimation,
      axisAlignment: 1,
      child: FadeTransition(
        opacity: _expandAnimation,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Label chip
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 10,
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
                const SizedBox(width: 16),
                // Squircle icon button
                Container(
                  height: 58,
                  width: 58,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ───────────────────── CENTER FAB ─────────────────────────────────────────

  Widget _buildCenterFAB() {
    return GestureDetector(
      onTap: _toggleFAB,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: _isFABOpen
                ? [const Color(0xFFFF6B6B), const Color(0xFFFF4867)]
                : [const Color(0xff1DC3F7), const Color(0xff27aae1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: RotationTransition(
          turns: _fabRotate,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: _isFABOpen
                ? const Icon(
                    Icons.calendar_month_rounded,
                    key: ValueKey('open'),
                    color: Colors.white,
                    size: 28,
                  )
                : const Icon(
                    Icons.add_rounded,
                    key: ValueKey('add'),
                    color: Colors.white,
                    size: 32,
                  ),
          ),
        ),
      ),
    );
  }

  // ───────────────────── NOTCHED BOTTOM APP BAR ─────────────────────────────

  Widget _buildNotchedBottomBar(
    List<_NavItem> leftItems,
    List<_NavItem> rightItems,
  ) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.zero,
      height: 80,
      color: AppColors.primaryColor,
      elevation: 0,
      child: Row(
        children: [
          ...leftItems.map((item) => _buildNavItem(item)),
          const SizedBox(width: 88), // space for FAB notch
          ...rightItems.map((item) => _buildNavItem(item)),
        ],
      ),
    );
  }

  // ───────────────────── SINGLE NAV ITEM ────────────────────────────────────

  Widget _buildNavItem(_NavItem item) {
    final bool isActive = selectedIndex == item.index;
    final Color activeColor = Colors.white;
    final Color inactiveColor = Colors.white.withValues(alpha: 0.60);
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onNavTap(item.index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.white.withValues(alpha: 0.25)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isActive ? item.icon : item.outlinedIcon,
                color: isActive ? activeColor : inactiveColor,
                size: 26,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              style: TextStyle(
                fontSize: 13.5.sp,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? activeColor : inactiveColor,
              ),
              child: Text(item.label, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────── NAV ITEM MODEL ──────────────────────────────────────

class _NavItem {
  final IconData icon;
  final IconData outlinedIcon;
  final String label;
  final int index;

  const _NavItem({
    required this.icon,
    required this.outlinedIcon,
    required this.label,
    required this.index,
  });
}
