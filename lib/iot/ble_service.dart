import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BleService {
  static const deviceNamePrefix = 'BreakDesk';
  // Guid constructor is not const; use final
  static final serviceUuid = Guid("0000FFF0-0000-1000-8000-00805F9B34FB");
  static final cmdCharUuid = Guid("0000FFF1-0000-1000-8000-00805F9B34FB");
  static final telemetryCharUuid = Guid("0000FFF2-0000-1000-8000-00805F9B34FB");

  BluetoothDevice? _device;
  BluetoothCharacteristic? _cmdChar;
  BluetoothCharacteristic? _telemetryChar;

  Stream<List<int>>? get telemetryStream => _telemetryChar?.lastValueStream;

  Future<List<ScanResult>> scan({Duration timeout = const Duration(seconds: 4)}) async {
    await FlutterBluePlus.startScan(timeout: timeout);
    final results = await FlutterBluePlus.scanResults.first;
    await FlutterBluePlus.stopScan();
    return results.where((r) {
      final name = r.device.platformName;
      final id = r.device.remoteId.str;
      return (name.isNotEmpty ? name : id).contains(deviceNamePrefix);
    }).toList();
  }

  Future<bool> connect(BluetoothDevice device) async {
    try {
      _device = device;
      await device.connect(timeout: const Duration(seconds: 10));
      final services = await device.discoverServices();
      BluetoothService? svc;
      for (final s in services) {
        if (s.uuid == serviceUuid) { svc = s; break; }
      }
      if (svc == null) {
        await device.disconnect();
        return false;
      }
      BluetoothCharacteristic? cmd;
      BluetoothCharacteristic? tele;
      for (final c in svc.characteristics) {
        if (c.uuid == cmdCharUuid) cmd = c;
        if (c.uuid == telemetryCharUuid) tele = c;
      }
      _cmdChar = cmd;
      _telemetryChar = tele;
      if (_cmdChar == null || _telemetryChar == null) {
        await device.disconnect();
        return false;
      }
      await _telemetryChar!.setNotifyValue(true);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('bleDeviceId', device.remoteId.str);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> tryReconnectSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('bleDeviceId');
    if (id == null) return false;
    final refs = await FlutterBluePlus.connectedDevices;
    for (final d in refs) {
      if (d.remoteId.str == id) {
        return connect(d);
      }
    }
    // Fall back to constructing by id if supported in this version
    final device = BluetoothDevice.fromId(id);
    return connect(device);
  }

  Future<void> disconnect() async {
    try {
      await _device?.disconnect();
    } catch (_) {}
  }

  Future<bool> sendCommand(Map<String, dynamic> jsonCmd) async {
    if (_cmdChar == null) return false;
    final payload = utf8.encode(json.encode(jsonCmd));
    try {
      await _cmdChar!.write(payload, withoutResponse: true);
      return true;
    } catch (_) {
      return false;
    }
  }
}
