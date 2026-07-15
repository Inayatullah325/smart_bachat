import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:smart_bachat/core/constant_colors.dart';
import 'package:smart_bachat/services/notification_service.dart';
import 'package:provider/provider.dart';
import 'package:smart_bachat/providers/settings_provider.dart';
import 'package:smart_bachat/ui/components/transaction_item.dart';
import 'package:smart_bachat/l10n/app_localizations.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  int _hour = 20;
  int _minute = 0;
  bool _enabled = true;
  List<Map<String, String>> _history = [];
  bool _loading = true;

  // ─── Selection mode ───────────────────────────────────────────────────────
  bool _selectionMode = false;
  final Set<int> _selected = {};

  // ─── AppBar animation ─────────────────────────────────────────────────────
  late AnimationController _appBarAnim;
  late Animation<double> _appBarFade;

  @override
  void initState() {
    super.initState();
    _appBarAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _appBarFade = CurvedAnimation(parent: _appBarAnim, curve: Curves.easeOut);
    _loadData();
    NotificationService.historyChanged.addListener(_onNewNotification);
  }

  void _onNewNotification() {
    if (mounted) _loadData();
  }

  @override
  void dispose() {
    NotificationService.historyChanged.removeListener(_onNewNotification);
    _appBarAnim.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final service = NotificationService();
    final enabled = await service.isEnabled();
    final history = await service.getHistory();
    final (hour, minute) = await service.getNotificationTime();
    if (mounted) {
      setState(() {
        _enabled = enabled;
        _hour = hour;
        _minute = minute;
        _history = history;
        _loading = false;
        _selectionMode = false;
        _selected.clear();
      });
    }
  }

  void _enterSelectionMode(int index) {
    setState(() {
      _selectionMode = true;
      _selected.add(index);
    });
    _appBarAnim.forward(from: 0);
  }

  void _exitSelectionMode() {
    setState(() {
      _selectionMode = false;
      _selected.clear();
    });
    _appBarAnim.reverse();
  }

  void _toggleSelect(int index) {
    setState(() {
      if (_selected.contains(index)) {
        _selected.remove(index);
        if (_selected.isEmpty) _exitSelectionMode();
      } else {
        _selected.add(index);
      }
    });
  }

  void _selectAll() {
    setState(() {
      _selected.addAll(List.generate(_history.length, (i) => i));
    });
  }

  Future<void> _deleteSelected() async {
    final l10n = AppLocalizations.of(context)!;
    final count = _selected.length;
    final confirmed = await _showDeleteConfirm(count);
    if (!confirmed) return;

    await NotificationService().deleteHistoryItemsByIndex(_selected.toList());
    Fluttertoast.showToast(
      msg: '$count ${l10n.notificationDeleted}',
      backgroundColor: AppColors.expenseColor,
    );
    await _loadData();
  }

  Future<void> _deleteSingle(int index) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await _showDeleteConfirm(1);
    if (!confirmed) return;

    await NotificationService().deleteHistoryItemsByIndex([index]);
    Fluttertoast.showToast(
      msg: l10n.notificationDeleted,
      backgroundColor: AppColors.expenseColor,
    );
    await _loadData();
  }

  Future<bool> _showDeleteConfirm(int count) async {
    final l10n = AppLocalizations.of(context)!;
    final gradientColors = [AppColors.primaryColor, AppColors.buttonsColor];
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              height: MediaQuery.of(ctx).size.height * 0.3,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradientColors),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.amber,
                    size: 8.h,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6.w),
                    child: Row(
                      children: [
                        Text(
                          l10n.deleteConfirmTitle,
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
                            l10n.deleteConfirmContent,
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
                          onTap: () => Navigator.pop(ctx, false),
                          child: Container(
                            height: MediaQuery.of(ctx).size.height * 0.05,
                            width: MediaQuery.of(ctx).size.width * 0.3,
                            decoration: BoxDecoration(
                              color: AppColors.incomeColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                l10n.no,
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
                          onTap: () => Navigator.pop(ctx, true),
                          child: Container(
                            height: MediaQuery.of(ctx).size.height * 0.05,
                            width: MediaQuery.of(ctx).size.width * 0.3,
                            decoration: BoxDecoration(
                              color: AppColors.expenseColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                l10n.yes,
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
        ) ??
        false;
  }

  Future<void> _toggleNotifications(bool value) async {
    final l10n = AppLocalizations.of(context)!;
    await NotificationService().setEnabled(value);
    setState(() => _enabled = value);
    Fluttertoast.showToast(
      msg: value
          ? l10n.dailyNotificationsEnabled
          : l10n.dailyNotificationsTurnedOff,
      backgroundColor: value ? AppColors.incomeColor : Colors.grey.shade700,
    );
    if (value) await _loadData();
  }

  Future<void> _changeTime() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_enabled) {
      Fluttertoast.showToast(
        msg: l10n.turnOnNotificationsFirst,
        backgroundColor: Colors.orange,
      );
      return;
    }
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _hour, minute: _minute),
    );
    if (picked != null) {
      final timeFormatted = picked.format(context);
      final reminderMsg = '${l10n.dailyReminderSet} $timeFormatted';
      await NotificationService().updateNotificationTime(
        picked.hour,
        picked.minute,
      );
      Fluttertoast.showToast(
        msg: reminderMsg,
        backgroundColor: AppColors.incomeColor,
      );
      await _loadData();
    }
  }

  String _formatDateTime(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return DateFormat('EEE, dd MMM yyyy  •  hh:mm a').format(dt);
    } catch (_) {
      return iso;
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final timeStr = TimeOfDay(hour: _hour, minute: _minute).format(context);
    final allSelected = _selected.length == _history.length;

    return PopScope(
      canPop: !_selectionMode,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _selectionMode) {
          _exitSelectionMode();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _selectionMode
            ? _buildSelectionAppBar(allSelected)
            : _buildNormalAppBar(),
        body: _loading
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
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── On/Off toggle ──────────────────────────────────────
                  if (!_selectionMode) ...[
                    Container(
                      margin: EdgeInsets.fromLTRB(4.w, 4.w, 4.w, 2.w),
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 1.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _enabled
                                ? Icons.notifications_active_rounded
                                : Icons.notifications_off_rounded,
                            color: _enabled
                                ? AppColors.primaryColor
                                : Colors.grey,
                            size: 26,
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.dailyNotifications,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  _enabled
                                      ? l10n.reminderWithSound
                                      : l10n.notificationsOff,
                                  style: TextStyle(
                                    fontSize: 11.5.sp,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _enabled,
                            activeTrackColor: AppColors.primaryColor.withValues(
                              alpha: 0.5,
                            ),
                            activeThumbColor: AppColors.primaryColor,
                            onChanged: _toggleNotifications,
                          ),
                        ],
                      ),
                    ),

                    // ── Reminder banner ───────────────────────────────────
                    if (_enabled)
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 1.5.h,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryColor,
                              AppColors.accent.withValues(alpha: 0.85),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.alarm_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.dailyReminderSet,
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    timeStr,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17.sp,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: _changeTime,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  l10n.change,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    SizedBox(height: 2.h),
                  ],

                  // ── Section header ─────────────────────────────────────
                  if (!_selectionMode)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Row(
                        children: [
                          Text(
                            l10n.recentNotifications,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          if (_history.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                if (_history.isNotEmpty) {
                                  _enterSelectionMode(0);
                                  _selectAll();
                                }
                              },
                              child: Text(
                                l10n.selectAll,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                  if (!_selectionMode) SizedBox(height: 1.h),

                  // ── List ───────────────────────────────────────────────
                  Expanded(
                    child: _history.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 40,
                                  backgroundColor: AppColors.primaryColor
                                      .withValues(alpha: 0.12),
                                  child: const Icon(
                                    Icons.notifications_none_rounded,
                                    color: AppColors.primaryColor,
                                    size: 38,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  l10n.noNotificationsYet,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14.sp,
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                Text(
                                  _enabled
                                      ? l10n.notificationsWillAppear
                                      : l10n.enableNotificationsHint,
                                  style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadData,
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: EdgeInsets.symmetric(
                                horizontal: 4.w,
                                vertical: 1.h,
                              ),
                              itemCount: _history.length,
                              itemBuilder: (context, index) {
                                final item = _history[index];
                                final formattedTime = _formatDateTime(
                                  item['time'] ?? '',
                                );
                                final isSelected = _selected.contains(index);

                                return Padding(
                                  padding: EdgeInsets.only(bottom: 1.5.h),
                                  child: SlidableNotificationItem(
                                    item: item,
                                    index: index,
                                    selectionMode: _selectionMode,
                                    isSelected: isSelected,
                                    formattedTime: formattedTime,
                                    onLongPress: () {
                                      if (!_selectionMode) {
                                        _enterSelectionMode(index);
                                      }
                                    },
                                    onTap: () {
                                      if (_selectionMode) {
                                        _toggleSelect(index);
                                      }
                                    },
                                    onDelete: () => _deleteSingle(index),
                                    onCheckboxChanged: (val) {
                                      _toggleSelect(index);
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
                ],
              ),
      ),
    );
  }

  // ─── Normal AppBar ────────────────────────────────────────────────────────
  AppBar _buildNormalAppBar() {
    final l10n = AppLocalizations.of(context)!;
    return AppBar(
      backgroundColor: AppColors.primaryColor,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.white),
      title: Text(
        l10n.notifications,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
      actions: const [],
    );
  }

  // ─── Selection AppBar ─────────────────────────────────────────────────────
  AppBar _buildSelectionAppBar(bool allSelected) {
    final l10n = AppLocalizations.of(context)!;
    return AppBar(
      backgroundColor: AppColors.primaryColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close, color: Colors.white),
        onPressed: _exitSelectionMode,
      ),
      title: FadeTransition(
        opacity: _appBarFade,
        child: Text(
          '${_selected.length} ${l10n.selected}',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      actions: [
        // Toggle select all / deselect all
        IconButton(
          icon: Icon(
            allSelected ? Icons.deselect : Icons.select_all,
            color: Colors.white,
          ),
          tooltip: allSelected ? l10n.deselectAll : l10n.selectAll,
          onPressed: () {
            if (allSelected) {
              setState(() => _selected.clear());
              _exitSelectionMode();
            } else {
              _selectAll();
            }
          },
        ),
        // Delete
        IconButton(
          icon: const Icon(Icons.delete_rounded, color: Colors.white),
          tooltip: l10n.delete,
          onPressed: _selected.isEmpty ? null : _deleteSelected,
        ),
        SizedBox(width: 1.w),
      ],
    );
  }
}

class SlidableNotificationItem extends StatefulWidget {
  final Map<String, String> item;
  final int index;
  final bool selectionMode;
  final bool isSelected;
  final String formattedTime;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onDelete;
  final ValueChanged<bool?> onCheckboxChanged;

  const SlidableNotificationItem({
    super.key,
    required this.item,
    required this.index,
    required this.selectionMode,
    required this.isSelected,
    required this.formattedTime,
    required this.onTap,
    required this.onLongPress,
    required this.onDelete,
    required this.onCheckboxChanged,
  });

  @override
  State<SlidableNotificationItem> createState() =>
      _SlidableNotificationItemState();
}

class _SlidableNotificationItemState extends State<SlidableNotificationItem>
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
  void didUpdateWidget(covariant SlidableNotificationItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectionMode && !oldWidget.selectionMode) {
      setState(() => _offset = 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final isRtl = settingsProvider.currentLanguage.isRTL;
    final l10n = AppLocalizations.of(context)!;

    return Stack(
      children: [
        // Action Background (Just only Delete Option)
        if (!widget.selectionMode)
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
                            () {
                              setState(() => _offset = 0.0);
                              widget.onDelete();
                            },
                          ),
                        ]
                      : [
                          _buildActionButton(
                            Icons.delete_sweep_rounded,
                            AppColors.expenseColor,
                            () {
                              setState(() => _offset = 0.0);
                              widget.onDelete();
                            },
                          ),
                          SizedBox(width: 3.w),
                        ],
                ),
              ),
            ),
          ),

        // Swipeable Container
        GestureDetector(
          onHorizontalDragUpdate: widget.selectionMode
              ? null
              : (details) {
                  SlidableManager.setActive(this);
                  setState(() {
                    _offset += details.delta.dx;
                    if (isRtl) {
                      if (_offset < 0) _offset = 0;
                      if (_offset > 80) _offset = 80;
                    } else {
                      if (_offset > 0) _offset = 0;
                      if (_offset < -80) _offset = -80;
                    }
                  });
                },
          onHorizontalDragEnd: widget.selectionMode
              ? null
              : (details) {
                  setState(() {
                    if (isRtl) {
                      if (_offset > 40) {
                        _offset = 80;
                      } else {
                        _offset = 0;
                      }
                    } else {
                      if (_offset < -40) {
                        _offset = -80;
                      } else {
                        _offset = 0;
                      }
                    }
                  });
                },
          child: Transform.translate(
            offset: Offset(_offset, 0),
            child: GestureDetector(
              onLongPress: widget.onLongPress,
              onTap: () {
                if (_offset != 0) {
                  setState(() => _offset = 0.0);
                } else {
                  widget.onTap();
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? AppColors.primaryColor.withValues(alpha: 0.08)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: widget.isSelected
                        ? AppColors.primaryColor.withValues(alpha: 0.4)
                        : Colors.black.withValues(alpha: 0.05),
                    width: widget.isSelected ? 1.5 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.selectionMode)
                      Padding(
                        padding: EdgeInsets.only(right: 2.w, top: 0.5.h),
                        child: Checkbox(
                          value: widget.isSelected,
                          activeColor: AppColors.primaryColor,
                          checkColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          onChanged: widget.onCheckboxChanged,
                        ),
                      )
                    else
                      Container(
                        margin: EdgeInsets.only(right: 3.w, top: 0.5.h),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.notifications_rounded,
                          color: AppColors.accent,
                          size: 20,
                        ),
                      ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          () {
                            final rawTitle = widget.item['title'] ?? '';
                            final displayTitle =
                                (rawTitle == 'Smart Bachat Reminder 💰')
                                ? l10n.notifTitle
                                : rawTitle;
                            return Text(
                              displayTitle,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            );
                          }(),
                          SizedBox(height: 0.4.h),
                          () {
                            final rawBody = widget.item['body'] ?? '';
                            final displayBody =
                                (rawBody.contains(
                                      "Don't forget to add today's income",
                                    ) ||
                                    rawBody.contains(
                                      "Smart tracking leads to smart savings",
                                    ))
                                ? l10n.notifBody
                                : rawBody;
                            return Text(
                              displayBody,
                              style: TextStyle(
                                fontSize: 12.5.sp,
                                color: AppColors.textSecondary,
                                height: 1.4,
                              ),
                            );
                          }(),
                          SizedBox(height: 0.8.h),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 12,
                                color: Colors.grey.shade400,
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                widget.formattedTime,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.grey.shade400,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        alignment: Alignment.center,
        child: Icon(icon, color: color, size: 26),
      ),
    );
  }
}
