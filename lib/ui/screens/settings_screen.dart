import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/break_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late int workMinutes;
  late int breakMinutes;
  late bool notificationsEnabled;

  @override
  void initState() {
    super.initState();
    final c = context.read<BreakController>();
    workMinutes = c.workInterval.inMinutes;
    breakMinutes = c.breakInterval.inMinutes;
    notificationsEnabled = c.notificationsEnabled;
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<BreakController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Intervals', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Work (min)'),
                    const Spacer(),
                    SizedBox(
                      width: 100,
                      child: TextFormField(
                        initialValue: workMinutes.toString(),
                        keyboardType: TextInputType.number,
                        onChanged: (v) => workMinutes = int.tryParse(v) ?? workMinutes,
                        decoration: const InputDecoration(suffixText: 'm'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Break (min)'),
                    const Spacer(),
                    SizedBox(
                      width: 100,
                      child: TextFormField(
                        initialValue: breakMinutes.toString(),
                        keyboardType: TextInputType.number,
                        onChanged: (v) => breakMinutes = int.tryParse(v) ?? breakMinutes,
                        decoration: const InputDecoration(suffixText: 'm'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _card(
            child: SwitchListTile(
              title: const Text('Enable notifications'),
              value: notificationsEnabled,
              onChanged: (v) => setState(() => notificationsEnabled = v),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () async {
              controller.workInterval = Duration(minutes: workMinutes);
              controller.breakInterval = Duration(minutes: breakMinutes);
              controller.notificationsEnabled = notificationsEnabled;
              await controller.savePrefs();
              if (!controller.isRunning) controller.start();
              if (mounted) Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) => Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(padding: const EdgeInsets.all(16), child: child),
      );
}
