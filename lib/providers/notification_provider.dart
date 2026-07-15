import 'package:flutter/material.dart';
import 'package:smart_bachat/services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _service = NotificationService();

  int _hour = 20;
  int _minute = 0;
  bool _enabled = true;
  List<Map<String, String>> _history = [];
  bool _loading = true;

  // Selection mode
  bool _selectionMode = false;
  final Set<int> _selected = {};

  // Getters
  int get hour => _hour;
  int get minute => _minute;
  bool get enabled => _enabled;
  List<Map<String, String>> get history => _history;
  bool get loading => _loading;
  bool get selectionMode => _selectionMode;
  Set<int> get selected => _selected;

  Future<void> loadData() async {
    _loading = true;
    notifyListeners();

    try {
      final enabled = await _service.isEnabled();
      final history = await _service.getHistory();
      final (hour, minute) = await _service.getNotificationTime();

      _enabled = enabled;
      _hour = hour;
      _minute = minute;
      _history = history;
      _selectionMode = false;
      _selected.clear();
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void enterSelectionMode(int index) {
    _selectionMode = true;
    _selected.add(index);
    notifyListeners();
  }

  void exitSelectionMode() {
    _selectionMode = false;
    _selected.clear();
    notifyListeners();
  }

  void toggleSelect(int index) {
    if (_selected.contains(index)) {
      _selected.remove(index);
      if (_selected.isEmpty) {
        _selectionMode = false;
      }
    } else {
      _selected.add(index);
    }
    notifyListeners();
  }

  void selectAll() {
    _selected.addAll(List.generate(_history.length, (i) => i));
    notifyListeners();
  }

  void clearSelection() {
    _selected.clear();
    notifyListeners();
  }

  Future<void> toggleNotifications(bool value) async {
    await _service.setEnabled(value);
    _enabled = value;
    if (value) {
      await loadData();
    } else {
      notifyListeners();
    }
  }

  Future<void> updateNotificationTime(int hour, int minute) async {
    await _service.updateNotificationTime(hour, minute);
    _hour = hour;
    _minute = minute;
    if (_enabled) {
      await loadData();
    } else {
      notifyListeners();
    }
  }

  Future<void> deleteHistoryItems(List<int> indices) async {
    await _service.deleteHistoryItemsByIndex(indices);
    await loadData();
  }
}
