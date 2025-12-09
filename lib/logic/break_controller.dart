import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../iot/ble_service.dart';

class BreakController extends ChangeNotifier {
  Duration workInterval = const Duration(minutes: 50);
  Duration breakInterval = const Duration(minutes: 10);
  bool notificationsEnabled = true;
  bool isRunning = false;
  bool isOnBreak = false;

  DateTime? _nextEvent; // next break or work resume
  Timer? _timer;
  final BleService _ble = BleService();

  BreakController() {
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    workInterval = Duration(minutes: prefs.getInt('workMinutes') ?? 50);
    breakInterval = Duration(minutes: prefs.getInt('breakMinutes') ?? 10);
    notificationsEnabled = prefs.getBool('notifications') ?? true;
    notifyListeners();
  }

  Future<void> savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('workMinutes', workInterval.inMinutes);
    await prefs.setInt('breakMinutes', breakInterval.inMinutes);
    await prefs.setBool('notifications', notificationsEnabled);
  }

  void start() {
    if (isRunning) return;
    isRunning = true;
    isOnBreak = false;
    _nextEvent = DateTime.now().add(workInterval);
    _startTicker();
    _ble.tryReconnectSaved();
    _ble.sendCommand({"type": "timer/start", "workMin": workInterval.inMinutes, "breakMin": breakInterval.inMinutes});
    notifyListeners();
  }

  void pause() {
    _timer?.cancel();
    isRunning = false;
    _ble.sendCommand({"type": "timer/pause"});
    notifyListeners();
  }

  void resume() {
    if (isRunning) return;
    isRunning = true;
    _startTicker();
    _ble.sendCommand({"type": "timer/resume"});
    notifyListeners();
  }

  void stop() {
    _timer?.cancel();
    isRunning = false;
    isOnBreak = false;
    _nextEvent = null;
    _ble.sendCommand({"type": "timer/stop"});
    notifyListeners();
  }

  void _startTicker() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_nextEvent == null) return;
      if (DateTime.now().isAfter(_nextEvent!)) {
        isOnBreak = !isOnBreak;
        _nextEvent = DateTime.now().add(isOnBreak ? breakInterval : workInterval);
        _ble.sendCommand({"type": isOnBreak ? "break/start" : "break/end"});
        notifyListeners();
      } else {
        notifyListeners();
      }
    });
  }

  Duration remaining() {
    if (_nextEvent == null) return Duration.zero;
    final diff = _nextEvent!.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }
}
