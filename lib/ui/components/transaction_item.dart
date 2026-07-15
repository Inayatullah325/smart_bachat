import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:smart_bachat/core/app_utils.dart';
import 'package:smart_bachat/core/constant_colors.dart';
import 'package:smart_bachat/database_model_class/expense_data_model.dart';
import 'package:smart_bachat/database_model_class/income_data_model.dart';
import 'package:provider/provider.dart';
import 'package:smart_bachat/providers/settings_provider.dart';
import 'package:smart_bachat/l10n/app_localizations.dart';

abstract class SlidableItemState {
  void close();
}

class SlidableManager {
  static SlidableItemState? activeItem;

  static void setActive(SlidableItemState? state) {
    if (activeItem != null && activeItem != state) {
      activeItem!.close();
    }
    activeItem = state;
  }

  static void clear() {
    activeItem = null;
  }
}

class SlidableTransactionItem extends StatefulWidget {
  final ExpenseDataModel transaction;
  final int index;
  final VoidCallback onDelete;
  final VoidCallback onUpdate;
  final VoidCallback? onTap;

  const SlidableTransactionItem({
    super.key,
    required this.transaction,
    required this.index,
    required this.onDelete,
    required this.onUpdate,
    this.onTap,
  });

  @override
  State<SlidableTransactionItem> createState() =>
      _SlidableTransactionItemState();
}

class _SlidableTransactionItemState extends State<SlidableTransactionItem>
    implements SlidableItemState {
  double _offset = 0.0;

  @override
  void close() {
    if (mounted && _offset != 0.0) {
      setState(() {
        _offset = 0.0;
      });
    }
  }

  @override
  void dispose() {
    if (SlidableManager.activeItem == this) {
      SlidableManager.clear();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color categoryColor = AppColors.getCategoryColor(widget.transaction.name);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final currencySymbol = settingsProvider.currencySymbol;
    final isRtl = settingsProvider.currentLanguage.isRTL;

    return Stack(
      children: [
        // Action Background
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                mainAxisAlignment: isRtl
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.end,
                children: isRtl
                    ? [
                        SizedBox(width: 3.w),
                        _buildActionButton(
                          Icons.delete_sweep_rounded,
                          AppColors.expenseColor,
                          widget.onDelete,
                        ),
                        _buildActionButton(
                          Icons.edit_note_rounded,
                          AppColors.accent,
                          widget.onUpdate,
                        ),
                      ]
                    : [
                        _buildActionButton(
                          Icons.edit_note_rounded,
                          AppColors.accent,
                          widget.onUpdate,
                        ),
                        _buildActionButton(
                          Icons.delete_sweep_rounded,
                          AppColors.expenseColor,
                          widget.onDelete,
                        ),
                        SizedBox(width: 3.w),
                      ],
              ),
            ),
          ),
        ),
        // Swipeable Container
        GestureDetector(
          onHorizontalDragUpdate: (details) {
            SlidableManager.setActive(this);
            setState(() {
              _offset += details.delta.dx;
              if (isRtl) {
                if (_offset < 0) _offset = 0;
                if (_offset > 140) _offset = 140;
              } else {
                if (_offset > 0) _offset = 0;
                if (_offset < -140) _offset = -140;
              }
            });
          },
          onHorizontalDragEnd: (details) {
            setState(() {
              if (isRtl) {
                if (_offset > 70) {
                  _offset = 140;
                } else {
                  _offset = 0;
                }
              } else {
                if (_offset < -70) {
                  _offset = -140;
                } else {
                  _offset = 0;
                }
              }
            });
          },
          child: Transform.translate(
            offset: Offset(_offset, 0),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
              decoration: BoxDecoration(
                color: Colors.white, // white card on open
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.black.withValues(alpha: 0.05),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: InkWell(
                onTap: () {
                  if (_offset != 0) {
                    setState(() => _offset = 0);
                  } else if (widget.onTap != null) {
                    widget.onTap!();
                  }
                },
                child: Row(
                  children: [
                    Container(
                      width: 12.w,
                      height: 12.w,
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        AppUtils.getCategoryIcon(widget.transaction.name),
                        color: categoryColor,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppUtils.getCategoryLocalizedName(
                              widget.transaction.name,
                              context,
                            ),
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                              letterSpacing: 0.3,
                            ),
                          ),
                          SizedBox(height: 0.4.h),
                          Text(
                            widget.transaction.date,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '- $currencySymbol${AppUtils.formatCurrency(widget.transaction.expense)}',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w900,
                            color: AppColors.expenseColor,
                          ),
                        ),
                        SizedBox(height: 0.6.h),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 10,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: () {
        setState(() => _offset = 0.0);
        onTap();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }
}

class SlidableIncomeItem extends StatefulWidget {
  final IncomeDataModel transaction;
  final int index;
  final VoidCallback onDelete;
  final VoidCallback onUpdate;
  final VoidCallback? onTap;

  const SlidableIncomeItem({
    super.key,
    required this.transaction,
    required this.index,
    required this.onDelete,
    required this.onUpdate,
    this.onTap,
  });

  @override
  State<SlidableIncomeItem> createState() => _SlidableIncomeItemState();
}

class _SlidableIncomeItemState extends State<SlidableIncomeItem>
    implements SlidableItemState {
  double _offset = 0.0;

  @override
  void close() {
    if (mounted && _offset != 0.0) {
      setState(() {
        _offset = 0.0;
      });
    }
  }

  @override
  void dispose() {
    if (SlidableManager.activeItem == this) {
      SlidableManager.clear();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color categoryColor = AppColors.incomeColor;
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final currencySymbol = settingsProvider.currencySymbol;
    final isRtl = settingsProvider.currentLanguage.isRTL;

    return Stack(
      children: [
        // Action Background
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                mainAxisAlignment: isRtl
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.end,
                children: isRtl
                    ? [
                        SizedBox(width: 3.w),
                        _buildActionButton(
                          Icons.delete_sweep_rounded,
                          AppColors.expenseColor,
                          widget.onDelete,
                        ),
                        _buildActionButton(
                          Icons.edit_note_rounded,
                          AppColors.accent,
                          widget.onUpdate,
                        ),
                      ]
                    : [
                        _buildActionButton(
                          Icons.edit_note_rounded,
                          AppColors.accent,
                          widget.onUpdate,
                        ),
                        _buildActionButton(
                          Icons.delete_sweep_rounded,
                          AppColors.expenseColor,
                          widget.onDelete,
                        ),
                        SizedBox(width: 3.w),
                      ],
              ),
            ),
          ),
        ),
        // Swipeable Container
        GestureDetector(
          onHorizontalDragUpdate: (details) {
            SlidableManager.setActive(this);
            setState(() {
              _offset += details.delta.dx;
              if (isRtl) {
                if (_offset < 0) _offset = 0;
                if (_offset > 140) _offset = 140;
              } else {
                if (_offset > 0) _offset = 0;
                if (_offset < -140) _offset = -140;
              }
            });
          },
          onHorizontalDragEnd: (details) {
            setState(() {
              if (isRtl) {
                if (_offset > 70) {
                  _offset = 140;
                } else {
                  _offset = 0;
                }
              } else {
                if (_offset < -70) {
                  _offset = -140;
                } else {
                  _offset = 0;
                }
              }
            });
          },
          child: Transform.translate(
            offset: Offset(_offset, 0),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
              decoration: BoxDecoration(
                color: Colors.white, // white card on open
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.black.withValues(alpha: 0.05),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: InkWell(
                onTap: () {
                  if (_offset != 0) {
                    setState(() => _offset = 0);
                  } else if (widget.onTap != null) {
                    widget.onTap!();
                  }
                },
                child: Row(
                  children: [
                    Container(
                      width: 12.w,
                      height: 12.w,
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.arrow_downward_rounded,
                        color: categoryColor,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.income,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                              letterSpacing: 0.3,
                            ),
                          ),
                          SizedBox(height: 0.4.h),
                          Text(
                            widget.transaction.date.toString(),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '+ $currencySymbol${AppUtils.formatCurrency(widget.transaction.income ?? 0)}',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w900,
                            color: AppColors.incomeColor,
                          ),
                        ),
                        SizedBox(height: 0.6.h),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 10,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: () {
        setState(() => _offset = 0.0);
        onTap();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }
}
