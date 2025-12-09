import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import '../../iot/ble_service.dart';
import '../../logic/break_controller.dart';

class PairingScreen extends StatefulWidget {
  const PairingScreen({super.key});

  @override
  State<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends State<PairingScreen> {
  final BleService _ble = BleService();
  List<ScanResult> _results = [];
  bool _scanning = false;
  String? _error;

  Future<void> _scan() async {
    setState(() { _scanning = true; _error = null; });
    try {
      final res = await _ble.scan();
      setState(() { _results = res; });
    } catch (e) {
      setState(() { _error = 'Scan failed: $e'; });
    } finally {
      setState(() { _scanning = false; });
    }
  }

  Future<void> _connect(BluetoothDevice d) async {
    setState(() { _error = null; });
    final ok = await _ble.connect(d);
    if (!ok) {
      setState(() { _error = 'Connection failed'; });
      return;
    }
    if (!mounted) return;
    context.read<BreakController>().start();
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    _scan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pair Device')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
            Row(
              children: [
                Expanded(child: const Text('Nearby BreakDesk devices')),
                IconButton(
                  onPressed: _scanning ? null : _scan,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Rescan',
                )
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _scanning
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      itemCount: _results.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final r = _results[i];
                        return ListTile(
                          title: Text(r.device.platformName.isNotEmpty ? r.device.platformName : r.device.remoteId.str),
                          subtitle: Text('RSSI ${r.rssi}'),
                          trailing: FilledButton(
                            onPressed: () => _connect(r.device),
                            child: const Text('Connect'),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
