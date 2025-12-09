import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BleService {
  static const deviceNamePrefix = 'BreakDesk';
  static const serviceUuid = Guid("0000FFF0-0000-1000-8000-00805F9B34FB");
  static const cmdCharUuid = Guid("0000FFF1-0000-1000-8000-00805F9B34FB");
  static const telemetryCharUuid = Guid("0000FFF2-0000-1000-8000-00805F9B34FB");

  BluetoothDevice? _device;
  BluetoothCharacteristic? _cmdChar;
  BluetoothCharacteristic? _telemetryChar;

  Stream<List<int>>? get telemetryStream => _telemetryChar?.lastValueStream;

  Future<List<ScanResult>> scan({Duration timeout = const Duration(seconds: 4)}) async {
    await FlutterBluePlus.startScan(timeout: timeout);
    final results = await FlutterBluePlus.scanResults.first;
    await FlutterBluePlus.stopScan();
    return results.where((r) => (r.device.platformName ?? r.device.remoteId.str).contains(deviceNamePrefix)).toList();
  }

  Future<bool> connect(BluetoothDevice device) async {
    try {
      _device = device;
      await device.connect(timeout: const Duration(seconds: 10));
      final services = await device.discoverServices();
      final svc = services.firstWhere((s) => s.uuid == serviceUuid, orElse: () => BluetoothService(Guid.empty()));
      if (svc.uuid == Guid.empty()) {
        await device.disconnect();
        return false;
      }
      _cmdChar = svc.characteristics.firstWhere((c) => c.uuid == cmdCharUuid, orElse: () => BluetoothCharacteristic.fake());
      _telemetryChar = svc.characteristics.firstWhere((c) => c.uuid == telemetryCharUuid, orElse: () => BluetoothCharacteristic.fake());
      if (_cmdChar == null || _telemetryChar == null || _cmdChar == BluetoothCharacteristic.fake() || _telemetryChar == BluetoothCharacteristic.fake()) {
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
    final known = FlutterBluePlus.connectedDevices;
    final device = (await known).firstWhere(
      (d) => d.remoteId.str == id,
      orElse: () => BluetoothDevice.fromId(id),
    );
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
