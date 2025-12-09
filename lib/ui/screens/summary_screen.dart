import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../logic/storage_service.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  final StorageService _store = StorageService();
  List<Session> _sessions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final sessions = await _store.getSessions();
    setState(() {
      _sessions = sessions;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final todays = _sessions.where((s) => s.end.isAfter(startOfDay)).toList();
    final focusCount = todays.where((s) => s.type == 'focus').length;
    final focusSeconds = todays.where((s) => s.type == 'focus').fold<int>(0, (p, s) => p + s.durationSeconds);
    final breakSeconds = todays.where((s) => s.type == 'break').fold<int>(0, (p, s) => p + s.durationSeconds);

    String fmt(int seconds) {
      final d = Duration(seconds: seconds);
      final h = d.inHours;
      final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
      final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
      return h > 0 ? '$h:$m:$s' : '$m:$s';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Summary')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Today', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('Focus sessions: $focusCount'),
                        Text('Focus time: ${fmt(focusSeconds)}'),
                        Text('Break time: ${fmt(breakSeconds)}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('History'),
                const SizedBox(height: 8),
                ..._sessions.reversed.map((s) => ListTile(
                      leading: Icon(s.type == 'focus' ? Icons.work : Icons.free_breakfast),
                      title: Text('${s.type.toUpperCase()} • ${fmt(s.durationSeconds)}'),
                      subtitle: Text('${DateFormat('yyyy-MM-dd HH:mm').format(s.start)} → ${DateFormat('HH:mm').format(s.end)}'),
                    )),
              ],
            ),
    );
  }
}
